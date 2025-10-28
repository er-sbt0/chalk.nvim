local Util = require("chalk.util")
local Config = require("chalk.config")

local M = {}

---Apply terminal colors based on color scheme
---@param colors chalk.ColorScheme Color scheme with terminal colors
local function apply_terminal_colors(colors)
	local c = colors
	if not c.terminal then
		return
	end

	-- Set standard 16-color terminal palette
	vim.g.terminal_color_0 = c.terminal.black
	vim.g.terminal_color_1 = c.terminal.red
	vim.g.terminal_color_2 = c.terminal.green
	vim.g.terminal_color_3 = c.terminal.yellow
	vim.g.terminal_color_4 = c.terminal.blue
	vim.g.terminal_color_5 = c.terminal.magenta
	vim.g.terminal_color_6 = c.terminal.cyan
	vim.g.terminal_color_7 = c.terminal.white
	vim.g.terminal_color_8 = c.terminal.bright_black
	vim.g.terminal_color_9 = c.terminal.bright_red
	vim.g.terminal_color_10 = c.terminal.bright_green
	vim.g.terminal_color_11 = c.terminal.bright_yellow
	vim.g.terminal_color_12 = c.terminal.bright_blue
	vim.g.terminal_color_13 = c.terminal.bright_magenta
	vim.g.terminal_color_14 = c.terminal.bright_cyan
	vim.g.terminal_color_15 = c.terminal.bright_white
end

---Apply highlight groups to Neovim
---@param highlights chalk.Highlights Resolved highlight groups
local function apply_highlights(highlights)
	-- Clear existing highlights first
	if vim.g.colors_name then
		vim.cmd("highlight clear")
	end

	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	-- Enable true color support
	vim.o.termguicolors = true

	-- Apply each highlight group
	for group, definition in pairs(highlights) do
		-- Handle both table definitions and string links
		if type(definition) == "string" then
			definition = { link = definition }
		end

		vim.api.nvim_set_hl(0, group, definition)
	end
end

---Setup and load the complete theme
---@param opts? chalk.Config Configuration options
---@return chalk.ColorScheme, chalk.Highlights, chalk.Config
function M.setup(opts)
	-- Get complete configuration
	opts = Config.extend(opts)

	-- Generate color scheme
	local colors = require("chalk.colors").setup(opts)

	-- Generate highlight groups
	local groups = require("chalk.groups").setup(colors, opts)

	-- Resolve any highlight group links
	local highlights = Util.resolve(groups)

	-- Apply user highlight customizations
	if opts.on_highlights and type(opts.on_highlights) == "function" then
		opts.on_highlights(highlights, colors)
	end

	-- Set colorscheme name with variant
	local colorscheme_name = "chalk"
	if opts.variant ~= "default" then
		colorscheme_name = colorscheme_name .. "-" .. opts.variant
	end
	vim.g.colors_name = colorscheme_name

	-- Set background option based on variant
	if opts.variant == "light" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end

	-- Apply highlights to Neovim
	apply_highlights(highlights)

	-- Apply dynamic color overrides (after highlights are set)
	local dynamic = require("chalk.dynamic.dynamic")
	dynamic.apply_overrides()

	-- Apply additional Neovim options for optimal theme experience
	-- Optional: win/popup blends so "shadow" groups aren't needed
	vim.opt.winblend = 0
	vim.opt.pumblend = 0
	-- termguicolors is already set in apply_highlights function

	-- Apply terminal colors if enabled
	if opts.terminal_colors then
		apply_terminal_colors(colors)
	end

	-- Setup dynamic color system if enabled
	if opts.enable_dynamic_colors ~= false then -- Default to enabled
		-- Setup Ex commands
		dynamic.setup_commands()

		-- Setup keymaps if enabled
		if opts.dynamic_keymaps then
			local dynamic_module = require("chalk.dynamic")
			dynamic_module.setup_keymaps({
				prefix = opts.dynamic_prefix or "<leader>c",
			})
		end
	end

	-- Emit autocmd for theme loaded event
	vim.api.nvim_exec_autocmds("ColorScheme", {
		pattern = colorscheme_name,
		modeline = false,
	})

	return colors, highlights, opts
end

---Reload the current theme (useful for development)
function M.reload()
	-- Clear any cached modules
	for module_name, _ in pairs(package.loaded) do
		if module_name:match("^chalk%.") then
			package.loaded[module_name] = nil
		end
	end

	-- Reload with current configuration
	local config = Config.get()
	return M.setup(config)
end

---Get current theme colors without applying
---@param variant? string Specific variant to get colors for
---@return chalk.ColorScheme Current color scheme
function M.get_colors(variant)
	local opts = Config.get()
	if variant then
		opts = vim.deepcopy(opts)
		opts.variant = variant
	end

	return require("chalk.colors").setup(opts)
end

---Get current theme highlights without applying
---@param variant? string Specific variant to get highlights for
---@return chalk.Highlights Current highlights
function M.get_highlights(variant)
	local opts = Config.get()
	if variant then
		opts = vim.deepcopy(opts)
		opts.variant = variant
	end

	local colors = require("chalk.colors").setup(opts)
	local groups = require("chalk.groups").setup(colors, opts)
	return Util.resolve(groups)
end

---Toggle between light and dark variants
function M.toggle()
	local config = Config.get()
	local current_bg = vim.o.background

	if current_bg == "light" then
		-- Switch to dark
		vim.o.background = "dark"
		config.variant = "default" -- or could use a config option for preferred dark variant
	else
		-- Switch to light
		vim.o.background = "light"
		config.variant = config.light_variant or "light"
	end

	return M.setup(config)
end

---Preview a variant without applying it (returns colors only)
---@param variant string Variant to preview
---@return chalk.ColorScheme Color scheme for preview
function M.preview(variant)
	return require("chalk.colors").preview(variant)
end

---Check if chalk theme is currently loaded
---@return boolean Whether chalk is the current colorscheme
function M.is_loaded()
	return vim.g.colors_name and vim.g.colors_name:match("^chalk")
end

---Get theme information
---@return table Theme metadata
function M.info()
	local config = Config.get()

	return {
		name = "chalk.nvim",
		current_variant = config.variant,
		background = vim.o.background,
		available_variants = { "default", "light", "oled" },
		colors_name = vim.g.colors_name,
		terminal_colors = config.terminal_colors,
		transparent = config.transparent,
		enabled_plugins = Config.get_enabled_plugins(),
	}
end

return M
