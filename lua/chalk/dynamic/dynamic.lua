-- Dynamic color adjustment system for chalk.nvim
-- Consolidated from multiple sub-modules for simplicity

local M = {}
local colors = require("chalk.dynamic.colors")

-- State management
local _state = {
	overrides = {},
	override_file = vim.fn.stdpath("config") .. "/chalk-overrides.lua",
}

-- Utility functions

---Notify with consistent formatting
---@param message string Message to display
---@param level? number Log level (default: INFO)
---@param title? string Optional title prefix
local function notify(message, level, title)
	level = level or vim.log.levels.INFO
	title = title or "Dynamic"
	vim.notify(string.format("[%s] %s", title, message), level)
end

---Safe module loading
---@param name string Module name
---@return table|nil Module or nil if failed
local function safe_require(name)
	local ok, result = pcall(require, name)
	return ok and result or nil
end

---Reload chalk colorscheme with current config
local function reload_colorscheme()
	local Config = safe_require("chalk.config")
	if Config then
		vim.cmd("colorscheme chalk")
		M.apply_overrides()
	end
end

-- TreeSitter integration

---Get TreeSitter capture at cursor position
---@param bufnr? number Buffer number (default: current)
---@param row? number Row position (default: cursor row)
---@param col? number Column position (default: cursor col)
---@return string|nil capture TreeSitter capture name
function M.get_ts_capture_at_cursor(bufnr, row, col)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not row or not col then
		local cursor = vim.api.nvim_win_get_cursor(0)
		row, col = cursor[1] - 1, cursor[2] -- Convert to 0-indexed
	end

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

	-- Get capture names for this node
	local query = vim.treesitter.query.get(parser:lang(), "highlights")
	if not query then
		return nil
	end

	-- Find captures that match this node
	for capture_id, capture_node in query:iter_captures(tree:root(), bufnr, row, row + 1) do
		if capture_node == node then
			local capture_name = query.captures[capture_id]
			return "@" .. capture_name
		end
	end

	return nil
end

---Get highlight group name for TreeSitter capture
---@param capture string TreeSitter capture (e.g., "@keyword")
---@return string|nil Highlight group name
local function get_highlight_group_for_capture(capture)
	-- In Neovim 0.10+, TreeSitter highlight groups use the @ prefix directly
	-- We should use the capture name as-is, which is the actual highlight group
	-- The capture is already the highlight group name (e.g., "@type.builtin")
	return capture
end

-- Override management

---Load overrides from file
---@return table Overrides table
function M.load_overrides()
	if vim.fn.filereadable(_state.override_file) == 0 then
		return {}
	end

	local ok, result = pcall(dofile, _state.override_file)
	if ok and type(result) == "table" then
		_state.overrides = result
		return result
	end

	return {}
end

---Save override for a highlight group
---@param group_name string Highlight group name
---@param color string Hex color value
function M.save_override(group_name, color)
	_state.overrides[group_name] = color
	M.write_overrides()
end

---Write current overrides to file
function M.write_overrides()
	local lines = {
		"-- Chalk.nvim dynamic color overrides",
		"-- Generated automatically by dynamic color system",
		"",
		"return {",
	}

	for group, color in pairs(_state.overrides) do
		table.insert(lines, string.format('  ["%s"] = "%s",', group, color))
	end

	table.insert(lines, "}")

	-- Write to file
	local file = io.open(_state.override_file, "w")
	if file then
		file:write(table.concat(lines, "\n"))
		file:close()
	else
		notify("Failed to write overrides file", vim.log.levels.ERROR)
	end
end

---Clear all overrides
function M.clear_overrides()
	_state.overrides = {}

	-- Remove the file
	if vim.fn.filereadable(_state.override_file) == 1 then
		vim.fn.delete(_state.override_file)
	end

	-- Reload colorscheme to remove overrides
	reload_colorscheme()
	notify("All overrides cleared")
end

---Clear cache only (for use during theme loading to avoid recursion)
function M.clear_cache()
	_state.overrides = {}
	-- Don't reload colorscheme or delete file during theme loading
end

---Apply current overrides to highlight groups
function M.apply_overrides()
	local overrides = M.load_overrides()

	for group_name, color in pairs(overrides) do
		-- Convert hex color to number (remove # and convert to number)
		local color_num = tonumber(color:gsub("#", ""), 16)

		local current_hl = vim.api.nvim_get_hl(0, { name = group_name })

		-- If the group is a link, we need to break the link and copy the linked attributes
		if current_hl.link then
			-- Get the linked group's attributes
			local linked_hl = vim.api.nvim_get_hl(0, { name = current_hl.link, link = false })
			-- Copy all attributes from the linked group
			current_hl = vim.tbl_extend("force", linked_hl, {})
			-- Remove the link
			current_hl.link = nil
		end

		if current_hl then
			-- Preserve other attributes, just change the foreground color
			current_hl.fg = color_num
			vim.api.nvim_set_hl(0, group_name, current_hl)
		else
			-- Create new highlight group if it doesn't exist
			vim.api.nvim_set_hl(0, group_name, { fg = color_num })
		end
	end
end

-- Color adjustment functions

---Get current foreground color for a highlight group
---@param group_name string Highlight group name
---@return string|nil Hex color or nil if not found
local function get_group_color(group_name)
	local hl = vim.api.nvim_get_hl(0, { name = group_name })
	if hl and hl.fg then
		return string.format("#%06x", hl.fg)
	end
	return nil
end

---Apply color change to highlight group
---@param group_name string Highlight group name
---@param new_color string New hex color
local function apply_color_change(group_name, new_color)
	-- Get current highlight group
	local current_hl = vim.api.nvim_get_hl(0, { name = group_name })

	-- Convert hex color to number (remove # and convert to number)
	local color_num = tonumber(new_color:gsub("#", ""), 16)

	-- If the group is a link, we need to break the link and copy the linked attributes
	if current_hl.link then
		-- Get the linked group's attributes
		local linked_hl = vim.api.nvim_get_hl(0, { name = current_hl.link, link = false })
		-- Copy all attributes from the linked group
		current_hl = vim.tbl_extend("force", linked_hl, {})
		-- Remove the link
		current_hl.link = nil
	end

	-- Apply the new color
	current_hl.fg = color_num
	vim.api.nvim_set_hl(0, group_name, current_hl)

	-- Save override
	M.save_override(group_name, new_color)
end

-- Interactive functions

---Increase brightness of TreeSitter group under cursor
function M.increase_brightness()
	local capture = M.get_ts_capture_at_cursor()
	if not capture then
		notify("No TreeSitter capture found at cursor", vim.log.levels.WARN)
		return
	end

	local group_name = get_highlight_group_for_capture(capture)
	local current_color = get_group_color(group_name)

	if not current_color then
		notify(string.format("No color found for group: %s", group_name), vim.log.levels.WARN)
		return
	end

	local new_color = colors.adjust_brightness(current_color, 10)
	apply_color_change(group_name, new_color)

	notify(string.format("Increased brightness: %s → %s", group_name, new_color))
end

---Decrease brightness of TreeSitter group under cursor
function M.decrease_brightness()
	local capture = M.get_ts_capture_at_cursor()
	if not capture then
		notify("No TreeSitter capture found at cursor", vim.log.levels.WARN)
		return
	end

	local group_name = get_highlight_group_for_capture(capture)
	local current_color = get_group_color(group_name)

	if not current_color then
		notify(string.format("No color found for group: %s", group_name), vim.log.levels.WARN)
		return
	end

	local new_color = colors.adjust_brightness(current_color, -10)
	apply_color_change(group_name, new_color)

	notify(string.format("Decreased brightness: %s → %s", group_name, new_color))
end

---Change color in wheel direction
---@param direction number Direction (1 for next, -1 for previous)
function M.change_color(direction)
	local capture = M.get_ts_capture_at_cursor()
	if not capture then
		notify("No TreeSitter capture found at cursor", vim.log.levels.WARN)
		return
	end

	local group_name = get_highlight_group_for_capture(capture)
	local current_color = get_group_color(group_name)

	if not current_color then
		notify(string.format("No color found for group: %s", group_name), vim.log.levels.WARN)
		return
	end

	local new_color = colors.get_wheel_color(current_color, direction)
	apply_color_change(group_name, new_color)

	local direction_text = direction > 0 and "next" or "previous"
	notify(string.format("Changed to %s color: %s → %s", direction_text, group_name, new_color))
end

---Change color by family
---@param family string Color family ("warm", "cool", "saturated", "muted")
---@param direction number Direction (1 or -1)
function M.change_color_by_family(family, direction)
	local capture = M.get_ts_capture_at_cursor()
	if not capture then
		notify("No TreeSitter capture found at cursor", vim.log.levels.WARN)
		return
	end

	local group_name = get_highlight_group_for_capture(capture)
	local current_color = get_group_color(group_name)

	if not current_color then
		notify(string.format("No color found for group: %s", group_name), vim.log.levels.WARN)
		return
	end

	local new_color = colors.apply_color_family(current_color, family, direction)
	apply_color_change(group_name, new_color)

	notify(string.format("Applied %s color family: %s → %s", family, group_name, new_color))
end

---Reset colors by clearing overrides and reloading
function M.reset_colors()
	M.clear_overrides()
	notify("Colors reset to original")
end

---Inspect TreeSitter group under cursor
function M.inspect_group()
	local capture = M.get_ts_capture_at_cursor()
	if not capture then
		notify("No TreeSitter capture found at cursor", vim.log.levels.WARN)
		return
	end

	local group_name = get_highlight_group_for_capture(capture)
	local current_color = get_group_color(group_name)

	local info = {
		string.format("TreeSitter capture: %s", capture),
		string.format("Highlight group: %s", group_name),
		string.format("Current color: %s", current_color or "none"),
	}

	if current_color then
		local h, s, l = colors.hex_to_hsl(current_color)
		table.insert(info, string.format("HSL: %.0f, %.0f%%, %.0f%%", h, s, l))
	end

	notify(table.concat(info, " | "))
end

---Show current overrides
function M.show_overrides()
	local overrides = M.load_overrides()

	if vim.tbl_isempty(overrides) then
		notify("No active overrides")
		return
	end

	local lines = {
		"Active Color Overrides:",
		string.rep("-", 50),
	}

	for group, color in pairs(overrides) do
		table.insert(lines, string.format("%-25s %s", group, color))
	end

	table.insert(lines, string.rep("-", 50))
	table.insert(lines, string.format("Total: %d overrides", vim.tbl_count(overrides)))

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Command setup

---Setup all dynamic color commands
function M.setup_commands()
	local commands = {
		ChalkIncreaseBrightness = {
			callback = M.increase_brightness,
			opts = { desc = "Increase brightness of TreeSitter group under cursor" },
		},
		ChalkDecreaseBrightness = {
			callback = M.decrease_brightness,
			opts = { desc = "Decrease brightness of TreeSitter group under cursor" },
		},
		ChalkNextColor = {
			callback = function()
				M.change_color(1)
			end,
			opts = { desc = "Change to next color in color wheel" },
		},
		ChalkPrevColor = {
			callback = function()
				M.change_color(-1)
			end,
			opts = { desc = "Change to previous color in color wheel" },
		},
		ChalkWarmColor = {
			callback = function()
				M.change_color_by_family("warm", 1)
			end,
			opts = { desc = "Apply warm color family" },
		},
		ChalkCoolColor = {
			callback = function()
				M.change_color_by_family("cool", 1)
			end,
			opts = { desc = "Apply cool color family" },
		},
		ChalkSaturated = {
			callback = function()
				M.change_color_by_family("saturated", 1)
			end,
			opts = { desc = "Make color more saturated" },
		},
		ChalkMuted = {
			callback = function()
				M.change_color_by_family("muted", 1)
			end,
			opts = { desc = "Make color more muted" },
		},
		ChalkReset = {
			callback = M.reset_colors,
			opts = { desc = "Reset all colors to original" },
		},
		ChalkClear = {
			callback = M.clear_overrides,
			opts = { desc = "Clear all color overrides" },
		},
		ChalkShow = {
			callback = M.show_overrides,
			opts = { desc = "Show current color overrides" },
		},
		ChalkInspect = {
			callback = M.inspect_group,
			opts = { desc = "Inspect TreeSitter group under cursor" },
		},
	}

	for name, def in pairs(commands) do
		vim.api.nvim_create_user_command(name, def.callback, def.opts)
	end
end

-- Initialize by loading existing overrides
M.load_overrides()

return M
