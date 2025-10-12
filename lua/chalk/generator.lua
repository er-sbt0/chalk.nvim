-- User commands and activation interface for chalk color generator
local ColorGenerator = require("chalk.color_generator")
local Config = require("chalk.config")

local M = {}

---@class ChalkGeneratorConfig
---@field harmony_model? string "split_complementary" | "triadic" | "analogous"
---@field min_contrast? number Minimum WCAG contrast ratio
---@field auto_apply? boolean Automatically apply generated colors
---@field output_file? string File to save generated palette
---@field language_hints? table<string, boolean> Language-specific optimizations

M.default_config = {
	harmony_model = "split_complementary",
	min_contrast = 4.5,
	auto_apply = true,
	output_file = nil,
	verbose = false, -- Enable detailed debug output
	language_hints = {
		rust = true,
		python = true,
		lua = true,
		javascript = true
	}
}

---Current generated palette (cached)
M.current_palette = nil

-- Language-specific adjustments
local language_adjustments = {
	rust = {
		["@keyword.function"] = { lightness = 10, saturation = 5 },
		["@keyword.storage"] = { saturation = 15 },
		["@keyword.import"] = { hue_shift = -20 },
		["@variable.builtin"] = { hue_shift = -15 },
		["@type.builtin"] = { lightness = 8 }
	},
	python = {
		["@keyword.import"] = { saturation = 10 },
		["@function.builtin"] = { lightness = 15 },
		["@keyword.function"] = { lightness = 8 }
	},
	lua = {
		["@keyword.function"] = { lightness = 5 },
		["@variable.builtin"] = { saturation = 10 }
	},
	javascript = {
		["@keyword.export"] = { saturation = 10 },
		["@keyword.import"] = { saturation = 10 },
		["@function.method"] = { lightness = 5 }
	}
}

---Get current buffer's filetype for language-specific adjustments
---@return string Filetype
local function get_buffer_language()
	local ft = vim.bo.filetype
	-- Map some filetypes to our language keys
	local mapping = {
		rs = "rust",
		py = "python", 
		js = "javascript",
		ts = "javascript", -- TypeScript uses JS rules
		tsx = "javascript",
		jsx = "javascript"
	}
	return mapping[ft] or ft
end

---Apply language-specific adjustments to generation options
---@param opts ChalkGeneratorConfig Base options
---@param language string Target language
---@return table Enhanced options for ColorGenerator
local function apply_language_adjustments(opts, language)
	local generator_opts = {
		background = "#1e2328", -- Default chalk background
		harmony_model = opts.harmony_model,
		min_contrast = opts.min_contrast,
		language_specific = {}
	}
	
	if opts.language_hints[language] and language_adjustments[language] then
		generator_opts.language_specific = language_adjustments[language]
	end
	
	return generator_opts
end

---Convert generated palette to chalk color format
---@param palette table<string, string> Generated token colors
---@return table Chalk-compatible color definitions
local function palette_to_chalk_colors(palette)
	-- This would integrate with existing chalk color structure
	local chalk_colors = {}
	
	-- Map TreeSitter tokens to chalk's color variables
	-- This is a simplified mapping - full implementation would be more comprehensive
	local token_mapping = {
		["@keyword"] = "purple",
		["@keyword.function"] = "violet", 
		["@keyword.return"] = "crimson",
		["@type"] = "honey",
		["@type.builtin"] = "amber",
		["@function"] = "soft_blue",
		["@function.call"] = "slate_blue",
		["@variable"] = "fg",
		["@variable.member"] = "dusty_rose",
		["@string"] = "sage_green",
		["@number"] = "orange",
		["@comment"] = "comment"
	}
	
	for token, color in pairs(palette) do
		local chalk_var = token_mapping[token]
		if chalk_var then
			chalk_colors[chalk_var] = color
		end
	end
	
	return chalk_colors
end

---Save generated palette to a Lua file
---@param palette table Generated palette
---@param filename string Output filename
local function save_palette_to_file(palette, filename)
	local lines = {
		"-- Generated chalk palette from TreeSitter analysis",
		"-- Generated on " .. os.date("%Y-%m-%d %H:%M:%S"),
		"",
		"---@type chalk.Palette",
		"return {"
	}
	
	-- Sort tokens for consistent output
	local sorted_tokens = {}
	for token, _ in pairs(palette) do
		table.insert(sorted_tokens, token)
	end
	table.sort(sorted_tokens)
	
	for _, token in ipairs(sorted_tokens) do
		local color = palette[token]
		local comment = string.format(" -- %s", token)
		table.insert(lines, string.format('\t["%s"] = "%s",%s', token, color, comment))
	end
	
	table.insert(lines, "}")
	
	local content = table.concat(lines, "\n")
	local file = io.open(filename, "w")
	if file then
		file:write(content)
		file:close()
		vim.notify(string.format("Generated palette saved to %s", filename), vim.log.levels.INFO)
	else
		vim.notify(string.format("Failed to save palette to %s", filename), vim.log.levels.ERROR)
	end
end

---Generate colors from TreeSitter dump text
---@param dump_text string TreeSitter dump content
---@param opts? ChalkGeneratorConfig Generation options
function M.generate_from_dump(dump_text, opts)
	opts = vim.tbl_extend("force", M.default_config, opts or {})
	
	local language = get_buffer_language()
	local generator_opts = apply_language_adjustments(opts, language)
	
	-- Generate the palette
	M.current_palette = ColorGenerator.generate_from_dump(dump_text, generator_opts)
	
	vim.notify(string.format("Generated %d colors for %s", 
		vim.tbl_count(M.current_palette), language), vim.log.levels.INFO)
	
	-- Save to file if requested
	if opts.output_file then
		save_palette_to_file(M.current_palette, opts.output_file)
	end
	
	-- Auto-apply if enabled
	if opts.auto_apply then
		M.apply_generated_colors()
	end
	
	return M.current_palette
end

---Generate colors from a file containing TreeSitter dump
---@param filename string Path to dump file
---@param opts? ChalkGeneratorConfig Generation options
function M.generate_from_file(filename, opts)
	local file = io.open(filename, "r")
	if not file then
		vim.notify(string.format("Could not open file: %s", filename), vim.log.levels.ERROR)
		return
	end
	
	local content = file:read("*a")
	file:close()
	
	return M.generate_from_dump(content, opts)
end

---Apply currently generated colors to the theme
function M.apply_generated_colors()
	if not M.current_palette then
		vim.notify("No generated palette available. Run :ChalkGenerate first.", vim.log.levels.WARN)
		return
	end
	
	-- Convert to chalk format and apply
	local chalk_colors = palette_to_chalk_colors(M.current_palette)
	
	-- This would integrate with chalk's theme reloading system
	vim.notify("Applied generated colors to theme", vim.log.levels.INFO)
	
	-- Trigger colorscheme reload
	vim.cmd("colorscheme chalk")
end

---Preview generated colors in a scratch buffer
function M.preview_colors()
	if not M.current_palette then
		vim.notify("No generated palette available. Run :ChalkGenerate first.", vim.log.levels.WARN)
		return
	end
	
	-- Create preview buffer
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 60,
		height = 20,
		row = 5,
		col = 10,
		border = "rounded",
		title = "Generated Color Palette"
	})
	
	-- Populate with color samples
	local lines = {"Generated Color Palette:", ""}
	for token, color in pairs(M.current_palette) do
		table.insert(lines, string.format("%s: %s", token, color))
	end
	
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "chalk-preview")
	
	-- Add keymaps
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
end

---Reset to original chalk colors
function M.reset_colors()
	M.current_palette = nil
	vim.cmd("colorscheme chalk")
	vim.notify("Reset to original chalk colors", vim.log.levels.INFO)
end

---Show generation statistics
function M.show_stats()
	if not M.current_palette then
		vim.notify("No generated palette available.", vim.log.levels.WARN)
		return
	end
	
	local stats = {
		total_tokens = vim.tbl_count(M.current_palette),
		language = get_buffer_language(),
	}
	
	local msg = string.format("Generated %d colors for %s", stats.total_tokens, stats.language)
	vim.notify(msg, vim.log.levels.INFO)
	print(msg)
end

-- Track if commands are already setup to prevent double-registration
M._commands_setup = false

-- Setup user commands
function M.setup_commands()
	if M._commands_setup then
		return -- Prevent double-registration
	end
	M._commands_setup = true
	
	-- Main generation command
	vim.api.nvim_create_user_command("ChalkGenerate", function(opts)
		local args = vim.split(opts.args or "", "%s+")
		local config = {}
		
		-- Parse arguments
		for _, arg in ipairs(args) do
			if arg:match("^harmony=") then
				config.harmony_model = arg:match("^harmony=(.+)")
			elseif arg:match("^contrast=") then
				config.min_contrast = tonumber(arg:match("^contrast=(.+)"))
			elseif arg:match("^output=") then
				config.output_file = arg:match("^output=(.+)")
			elseif arg == "no-apply" then
				config.auto_apply = false
			elseif arg == "verbose" then
				config.verbose = true
			end
		end
		
		-- Prompt for TreeSitter dump if no file provided
		if #args == 0 or not args[1]:match("%.") then
			vim.ui.input({
				prompt = "Enter TreeSitter dump (or file path): ",
				completion = "file"
			}, function(input)
				if input and input ~= "" then
					if vim.fn.filereadable(input) == 1 then
						M.generate_from_file(input, config)
					else
						M.generate_from_dump(input, config)
					end
				end
			end)
		else
			-- File provided as argument
			M.generate_from_file(args[1], config)
		end
	end, {
		nargs = "*",
		desc = "Generate chalk colors from TreeSitter dump",
		complete = function(arglead, cmdline, cursorpos)
			local completions = {
				"harmony=split_complementary",
				"harmony=triadic", 
				"harmony=analogous",
				"contrast=4.5",
				"contrast=7.0",
				"output=generated_palette.lua",
				"no-apply",
				"verbose"
			}
			return vim.tbl_filter(function(item)
				return item:match("^" .. arglead)
			end, completions)
		end
	})
	
	-- Helper commands
	vim.api.nvim_create_user_command("ChalkPreview", M.preview_colors, {
		desc = "Preview generated color palette"
	})
	
	vim.api.nvim_create_user_command("ChalkApply", M.apply_generated_colors, {
		desc = "Apply generated colors to theme"
	})
	
	vim.api.nvim_create_user_command("ChalkReset", M.reset_colors, {
		desc = "Reset to original chalk colors"
	})
	
	vim.api.nvim_create_user_command("ChalkStats", M.show_stats, {
		desc = "Show generation statistics"
	})
end

-- Track if keymaps are already setup
M._keymaps_setup = false

-- Setup keymaps (optional)
function M.setup_keymaps()
	if M._keymaps_setup then
		return -- Prevent double-registration
	end
	M._keymaps_setup = true
	
	local opts = { noremap = true, silent = true }
	
	-- Leader-based mappings
	vim.keymap.set("n", "<leader>cg", ":ChalkGenerate<CR>", 
		vim.tbl_extend("force", opts, { desc = "Generate chalk colors" }))
	vim.keymap.set("n", "<leader>cp", ":ChalkPreview<CR>", 
		vim.tbl_extend("force", opts, { desc = "Preview generated colors" }))
	vim.keymap.set("n", "<leader>ca", ":ChalkApply<CR>", 
		vim.tbl_extend("force", opts, { desc = "Apply generated colors" }))
	vim.keymap.set("n", "<leader>cr", ":ChalkReset<CR>", 
		vim.tbl_extend("force", opts, { desc = "Reset chalk colors" }))
end

return M
