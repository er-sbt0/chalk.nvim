-- Dynamic color adjustment for chalk.nvim
-- Allows real-time color changes for TreeSitter groups under cursor

local M = {}
local Util = require("chalk.util")

-- Cache for current colors and highlights
M._cache = {
	colors = nil,
	highlights = nil,
	config = nil,
}

-- Default values
local DEFAULT_BRIGHTNESS_STEP = 0.1
local MIN_BRIGHTNESS = 0.1
local MAX_BRIGHTNESS = 1.0

---Initialize the dynamic color system
---@param colors? chalk.ColorScheme
---@param highlights? chalk.Highlights
---@param config? chalk.Config
function M.init(colors, highlights, config)
	M._cache.colors = colors or require("chalk.colors").setup()
	M._cache.highlights = highlights or {}
	M._cache.config = config or require("chalk.config").extend()
end

---Get configured brightness step size
---@return number step_size
local function get_brightness_step()
	if M._cache.config and M._cache.config.dynamic_step then
		return M._cache.config.dynamic_step
	end
	return DEFAULT_BRIGHTNESS_STEP
end

---Get TreeSitter capture name at cursor position
---@param bufnr? number Buffer number (0 for current)
---@param row? number Row (0-indexed, defaults to cursor row)
---@param col? number Column (0-indexed, defaults to cursor col)
---@return string|nil capture_name TreeSitter capture name (e.g., "@function", "@variable")
function M.get_ts_capture_at_cursor(bufnr, row, col)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	row = row or (cursor[1] - 1) -- Convert to 0-indexed
	col = col or cursor[2]

	-- Check if TreeSitter is available for this buffer
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return nil
	end

	-- Get the syntax tree
	local tree = parser:parse()[1]
	if not tree then
		return nil
	end

	-- Find the node at cursor position
	local node = tree:root():descendant_for_range(row, col, row, col)
	if not node then
		return nil
	end

	-- Get TreeSitter highlights for this position
	local captures = vim.treesitter.get_captures_at_pos(bufnr, row, col)
	
	if captures and #captures > 0 then
		-- Return the most specific capture (usually the last one)
		local capture = captures[#captures]
		return "@" .. capture.capture
	end

	-- Fallback: try to get highlight group under cursor
	local synID = vim.fn.synID(row + 1, col + 1, 1)
	if synID > 0 then
		local group_name = vim.fn.synIDattr(synID, "name")
		if group_name and group_name:match("^@") then
			return group_name
		end
	end

	return nil
end

---Get current color value for a highlight group
---@param group_name string Highlight group name
---@return string|nil color Current foreground color (hex)
function M.get_group_color(group_name)
	if not group_name then
		return nil
	end

	-- First check our cached highlights
	if M._cache.highlights and M._cache.highlights[group_name] then
		local hl = M._cache.highlights[group_name]
		if type(hl) == "table" and hl.fg then
			return hl.fg
		elseif type(hl) == "string" then
			-- Handle links
			return M.get_group_color(hl)
		end
	end

	-- Check current Neovim highlight
	local hl = vim.api.nvim_get_hl(0, { name = group_name })
	if hl and hl.fg then
		return string.format("#%06x", hl.fg)
	end

	return nil
end

---Adjust brightness of a color
---@param color string Hex color
---@param adjustment number Brightness adjustment (-1.0 to 1.0)
---@return string adjusted_color Adjusted hex color
function M.adjust_brightness(color, adjustment)
	if not color or not color:match("^#%x%x%x%x%x%x$") then
		return color
	end

	local r, g, b = Util.hex_to_rgb(color)
	
	-- Convert to HSL for better brightness control
	local function rgb_to_hsl(r, g, b)
		r, g, b = r / 255, g / 255, b / 255
		local max = math.max(r, g, b)
		local min = math.min(r, g, b)
		local h, s, l = 0, 0, (max + min) / 2

		if max == min then
			h, s = 0, 0 -- achromatic
		else
			local d = max - min
			s = l > 0.5 and d / (2 - max - min) or d / (max + min)
			if max == r then
				h = (g - b) / d + (g < b and 6 or 0)
			elseif max == g then
				h = (b - r) / d + 2
			elseif max == b then
				h = (r - g) / d + 4
			end
			h = h / 6
		end

		return h, s, l
	end

	local function hsl_to_rgb(h, s, l)
		local function hue_to_rgb(p, q, t)
			if t < 0 then t = t + 1 end
			if t > 1 then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
			return p
		end

		local r, g, b
		if s == 0 then
			r, g, b = l, l, l -- achromatic
		else
			local q = l < 0.5 and l * (1 + s) or l + s - l * s
			local p = 2 * l - q
			r = hue_to_rgb(p, q, h + 1/3)
			g = hue_to_rgb(p, q, h)
			b = hue_to_rgb(p, q, h - 1/3)
		end

		return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
	end

	local h, s, l = rgb_to_hsl(r, g, b)
	
	-- Adjust lightness
	l = math.max(MIN_BRIGHTNESS, math.min(MAX_BRIGHTNESS, l + adjustment))
	
	local new_r, new_g, new_b = hsl_to_rgb(h, s, l)
	return Util.rgb_to_hex(new_r, new_g, new_b)
end

---Apply color change to a TreeSitter group
---@param group_name string TreeSitter group name
---@param new_color string New hex color
function M.apply_color_change(group_name, new_color)
	if not group_name or not new_color then
		return
	end

	-- Update cached highlights
	if not M._cache.highlights then
		M._cache.highlights = {}
	end

	-- Get current highlight definition or create new one
	local current_hl = M._cache.highlights[group_name]
	if type(current_hl) == "string" then
		-- Handle link - create new definition
		current_hl = { fg = new_color }
	elseif type(current_hl) == "table" then
		-- Update existing definition
		current_hl = vim.deepcopy(current_hl)
		current_hl.fg = new_color
	else
		-- Create new definition
		current_hl = { fg = new_color }
	end

	-- Update cache
	M._cache.highlights[group_name] = current_hl

	-- Apply to Neovim
	vim.api.nvim_set_hl(0, group_name, current_hl)

	-- Notify user
	local color_preview = string.format("■", new_color) -- Color block for preview
	vim.notify(string.format("Updated %s: %s %s", group_name, color_preview, new_color), vim.log.levels.INFO)
end

---Increase brightness of TreeSitter group under cursor
function M.increase_brightness()
	local group_name = M.get_ts_capture_at_cursor()
	if not group_name then
		vim.notify("No TreeSitter group found under cursor", vim.log.levels.WARN)
		return
	end

	local current_color = M.get_group_color(group_name)
	if not current_color then
		vim.notify(string.format("No color found for group: %s", group_name), vim.log.levels.WARN)
		return
	end

	local step = get_brightness_step()
	local new_color = M.adjust_brightness(current_color, step)
	M.apply_color_change(group_name, new_color)
end

---Decrease brightness of TreeSitter group under cursor
function M.decrease_brightness()
	local group_name = M.get_ts_capture_at_cursor()
	if not group_name then
		vim.notify("No TreeSitter group found under cursor", vim.log.levels.WARN)
		return
	end

	local current_color = M.get_group_color(group_name)
	if not current_color then
		vim.notify(string.format("No color found for group: %s", group_name), vim.log.levels.WARN)
		return
	end

	local step = get_brightness_step()
	local new_color = M.adjust_brightness(current_color, -step)
	M.apply_color_change(group_name, new_color)
end

---Cycle to next color from palette for TreeSitter group under cursor
function M.change_color()
	local group_name = M.get_ts_capture_at_cursor()
	if not group_name then
		vim.notify("No TreeSitter group found under cursor", vim.log.levels.WARN)
		return
	end

	local current_color = M.get_group_color(group_name)
	
	-- Get available colors from the palette
	local colors = M._cache.colors
	if not colors then
		vim.notify("No color palette available. Initialize chalk first.", vim.log.levels.ERROR)
		return
	end

	-- Create a list of semantic colors from the active color scheme
	local color_list = {
		colors.red,
		colors.orange, 
		colors.yellow,
		colors.green,
		colors.cyan,
		colors.blue,
		colors.purple,
		colors.comment,
		colors.light_gray,
		colors.primary,
		colors.secondary,
		colors.accent,
	}

	-- Filter out nil colors and ensure they're valid hex colors
	local valid_colors = {}
	for _, color in ipairs(color_list) do
		if color and type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
			table.insert(valid_colors, color)
		end
	end

	if #valid_colors == 0 then
		vim.notify("No valid colors found in palette", vim.log.levels.ERROR)
		return
	end

	-- Find current color index or start from beginning
	local current_index = 1
	if current_color then
		for i, color in ipairs(valid_colors) do
			if color == current_color then
				current_index = i
				break
			end
		end
	end

	-- Get next color (cycle back to first if at end)
	local next_index = (current_index % #valid_colors) + 1
	local next_color = valid_colors[next_index]

	M.apply_color_change(group_name, next_color)
end

---Reset all dynamic color changes (reload theme)
function M.reset_colors()
	-- Reload the theme to reset all changes
	local config = M._cache.config or require("chalk.config").extend()
	local colors, highlights = require("chalk.theme").setup(config)
	
	-- Update cache
	M._cache.colors = colors
	M._cache.highlights = highlights
	
	vim.notify("Colors reset to theme defaults", vim.log.levels.INFO)
end

---Get information about TreeSitter group under cursor
function M.inspect_group()
	local group_name = M.get_ts_capture_at_cursor()
	if not group_name then
		vim.notify("No TreeSitter group found under cursor", vim.log.levels.WARN)
		return
	end

	local current_color = M.get_group_color(group_name)
	local hl = vim.api.nvim_get_hl(0, { name = group_name })
	
	local info = {
		string.format("Group: %s", group_name),
		string.format("Color: %s", current_color or "none"),
	}
	
	if hl then
		if hl.bold then table.insert(info, "Style: bold") end
		if hl.italic then table.insert(info, "Style: italic") end
		if hl.underline then table.insert(info, "Style: underline") end
		if hl.bg then
			table.insert(info, string.format("Background: #%06x", hl.bg))
		end
	end
	
	vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

---Dump TreeSitter structure of current buffer to a new buffer
---Creates a new buffer with TreeSitter group names replacing the actual text
---@param bufnr? number Source buffer number (0 for current)
function M.dump_treesitter_structure(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	
	-- Validate buffer number
	if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
		bufnr = vim.api.nvim_get_current_buf()
	end
	
	-- Get buffer info for diagnostics
	local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local filename = vim.fn.fnamemodify(bufname, ":t")
	
	-- Check if TreeSitter is available for this buffer
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		local error_msg = {
			"TreeSitter parser not available for this buffer.",
			string.format("Buffer: %s", filename ~= "" and filename or "[No Name]"),
			string.format("Filetype: %s", filetype ~= "" and filetype or "[No filetype]"),
			"",
			"Possible solutions:",
			"1. Set the correct filetype: :set filetype=<language>",
			"2. Install TreeSitter parser: :TSInstall <language>",
			"3. Check available parsers: :TSInstallInfo"
		}
		vim.notify(table.concat(error_msg, "\n"), vim.log.levels.WARN)
		return
	end
	
	-- Check if the parser actually has a tree
	local trees = parser:parse()
	if not trees or #trees == 0 then
		vim.notify(string.format("TreeSitter parser exists but no syntax tree available for %s", filetype), vim.log.levels.WARN)
		return
	end

	-- Get buffer content
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local total_lines = #lines
	
	-- Create result lines with same structure but TS group names
	local result_lines = {}
	for i = 1, total_lines do
		result_lines[i] = ""
	end
	
	-- Get the syntax tree
	local tree = trees[1]
	if not tree then
		vim.notify("Failed to get TreeSitter syntax tree", vim.log.levels.ERROR)
		return
	end
	
	-- Function to recursively process nodes
	local function process_node(node, depth)
		depth = depth or 0
		local start_row, start_col, end_row, end_col = node:range()
		
		-- Get captures for this node position
		local captures = {}
		local ts_captures = vim.treesitter.get_captures_at_pos(bufnr, start_row, start_col)
		
		if ts_captures and #ts_captures > 0 then
			for _, capture in ipairs(ts_captures) do
				table.insert(captures, "@" .. capture.capture)
			end
		end
		
		-- If no captures, use the node type
		if #captures == 0 then
			local node_type = node:type()
			if node_type and node_type ~= "" and not node_type:match("^[%s%p]*$") then
				table.insert(captures, "@" .. node_type)
			end
		end
		
		-- If we have captures, mark this range for replacement
		if #captures > 0 then
			local capture_text = table.concat(captures, ",")
			
			-- Only replace if this is a leaf node or small node to avoid overlaps
			local is_small_node = (end_row - start_row < 2) or 
			                     (start_row == end_row and end_col - start_col < 50)
			
			if is_small_node then
				-- Handle single line nodes
				if start_row == end_row then
					local line = lines[start_row + 1] or ""
					local original_text = string.sub(line, start_col + 1, end_col)
					
					-- Skip whitespace-only or punctuation-only nodes
					if original_text:match("^[%s%p]*$") then
						return
					end
					
					local before = string.sub(line, 1, start_col)
					local after = string.sub(line, end_col + 1)
					
					-- Create replacement text
					local replacement = "[" .. capture_text .. "]"
					
					-- Only replace if we haven't already processed this line position
					if result_lines[start_row + 1] == "" or 
					   string.sub(result_lines[start_row + 1], start_col + 1, end_col) == string.sub(lines[start_row + 1], start_col + 1, end_col) then
						result_lines[start_row + 1] = before .. replacement .. after
					end
				else
					-- Handle small multi-line nodes
					local replacement = "[" .. capture_text .. "]"
					for row = start_row, math.min(end_row, start_row + 1) do
						local line_idx = row + 1
						if result_lines[line_idx] == "" then
							result_lines[line_idx] = replacement
						end
					end
				end
			end
		end
		
		-- Process child nodes
		for child in node:iter_children() do
			process_node(child, depth + 1)
		end
	end
	
	-- Start processing from root
	process_node(tree:root())
	
	-- Fill empty lines with original content (for lines without TS groups)
	for i = 1, total_lines do
		if result_lines[i] == "" then
			result_lines[i] = lines[i]
		end
	end
	
	-- Create new buffer
	local new_bufnr = vim.api.nvim_create_buf(false, true)
	
	-- Set buffer content
	vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, result_lines)
	
	-- Set buffer options
	local original_name = vim.api.nvim_buf_get_name(bufnr)
	local base_name = vim.fn.fnamemodify(original_name, ":t")
	if base_name == "" then
		base_name = "untitled"
	end
	
	vim.api.nvim_buf_set_name(new_bufnr, base_name .. ".treesitter-dump")
	vim.api.nvim_buf_set_option(new_bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(new_bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(new_bufnr, "swapfile", false)
	vim.api.nvim_buf_set_option(new_bufnr, "filetype", "treesitter-dump")
	
	-- Open in a new split
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, new_bufnr)
	
	vim.notify(string.format("TreeSitter structure dumped to new buffer: %s", base_name .. ".treesitter-dump"), vim.log.levels.INFO)
end

---Setup keymaps for dynamic color adjustment
---@param opts? table Keymap options
function M.setup_keymaps(opts)
	opts = opts or {}
	local prefix = opts.prefix or ""
	
	local keymaps = {
		{ "!", M.increase_brightness, "Increase brightness" },
		{ "@", M.decrease_brightness, "Decrease brightness" },
		{ "#", M.change_color, "Change color" },
		{ "$", M.reset_colors, "Reset colors" },
		{ "%", M.inspect_group, "Inspect group" },
	}
	
	for _, keymap in ipairs(keymaps) do
		vim.keymap.set("n", keymap[1], keymap[2], { 
			desc = "Chalk: " .. keymap[3],
			silent = true,
		})
	end
	
	vim.notify("Chalk dynamic color keymaps activated: ! (brighter), @ (dimmer), # (change color), $ (reset), % (inspect)", vim.log.levels.INFO)
end

---Setup Ex commands for dynamic color adjustment
function M.setup_commands()
	-- Main command with subcommands
	vim.api.nvim_create_user_command("ChalkDynamic", function(opts)
		local action = opts.fargs[1]
		local arg = opts.fargs[2]
		
		if action == "brighter" or action == "increase" then
			M.increase_brightness()
		elseif action == "darker" or action == "decrease" then
			M.decrease_brightness()
		elseif action == "change" or action == "set" then
			if arg then
				-- Direct color setting
				local group = M.get_ts_capture_at_cursor()
				if group then
					M.apply_color_change(group, arg)
				end
			else
				M.change_color()
			end
		elseif action == "reset" then
			M.reset_colors()
		elseif action == "inspect" or action == "info" then
			M.inspect_group()
		else
			vim.notify("Usage: ChalkDynamic {brighter|darker|change|reset|inspect} [color]", vim.log.levels.ERROR)
		end
	end, {
		nargs = "*",
		complete = function(arglead, cmdline, cursorpos)
			local actions = { "brighter", "darker", "change", "reset", "inspect" }
			if #vim.split(cmdline, " ") <= 2 then
				return vim.tbl_filter(function(action)
					return action:find(arglead, 1, true) == 1
				end, actions)
			end
			return {}
		end,
		desc = "Dynamic color adjustment for TreeSitter groups"
	})
	
	-- Convenience commands
	vim.api.nvim_create_user_command("ChalkBrighter", M.increase_brightness, {
		desc = "Make TreeSitter group under cursor brighter"
	})
	
	vim.api.nvim_create_user_command("ChalkDarker", M.decrease_brightness, {
		desc = "Make TreeSitter group under cursor darker"
	})
	
	vim.api.nvim_create_user_command("ChalkChangeColor", M.change_color, {
		desc = "Change color of TreeSitter group under cursor"
	})
	
	vim.api.nvim_create_user_command("ChalkResetColors", M.reset_colors, {
		desc = "Reset all dynamic color changes"
	})
	
	vim.api.nvim_create_user_command("ChalkInspect", M.inspect_group, {
		desc = "Inspect TreeSitter group under cursor"
	})
	
	vim.api.nvim_create_user_command("DumpTreesitterStructure", function()
		M.dump_treesitter_structure()
	end, {
		desc = "Dump TreeSitter structure of current buffer to new buffer"
	})
end

return M
