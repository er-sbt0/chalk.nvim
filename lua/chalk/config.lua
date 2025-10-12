local Util = require("chalk.util")

---@class chalk.Config
local M = {}

---Default configuration
---@type chalk.Config
M.defaults = {
	-- Theme variants
	variant = "default", -- "default", "light", "oled"
	light_variant = "light", -- Light variant when vim.o.background = "light"

	-- Visual options
	transparent = false,
	terminal_colors = true,

	-- Style configurations for syntax elements
	styles = {
		comments = { italic = true },
		keywords = { bold = false, italic = false },
		functions = { bold = false, italic = false },
		variables = { italic = false },
		strings = { italic = false },
		types = { bold = false, italic = false },
		constants = { bold = false },
		operators = { bold = false },
	},

	-- Dimming
	dim_inactive = false, -- Dim inactive windows

	-- Dynamic color adjustment
	enable_dynamic_colors = true, -- Enable real-time color adjustments
	dynamic_keymaps = true, -- Auto-setup keymaps for dynamic colors
	dynamic_prefix = "<leader>c", -- Key prefix for dynamic color operations
	dynamic_step = 0.1, -- Brightness adjustment step size (0.0-1.0)

	-- Caching for performance
	cache = true,

	-- Color generator options
	enable_generator = false, -- Enable TreeSitter color generator
	generator_keymaps = false, -- Setup generator keymaps
	generator_config = {
		harmony_model = "split_complementary", -- "triadic", "analogous"
		min_contrast = 4.5, -- WCAG contrast ratio
		auto_apply = true, -- Automatically apply generated colors
		language_hints = true, -- Use language-specific optimizations
	},

	-- Plugin integrations with auto-detection
	plugins = {
		-- Enable all plugins by default when detected
		all = false,
		-- Auto-detect available plugins
		auto = true,

		-- Individual plugin controls
		treesitter = true,
		telescope = true,
		nvim_cmp = true,
		gitsigns = true,
		lualine = true,
		which_key = true,
		indent_blankline = true,
		nvim_tree = true,
		neo_tree = true,
		bufferline = true,
		dashboard = true,
		alpha = true,
		noice = true,
		notify = true,
		mini = true,
		leap = true,
		flash = true,
		navic = true,
		aerial = true,
	},

	-- Callback functions
	---@type fun(colors: chalk.ColorScheme): nil
	on_colors = function(colors) end,

	---@type fun(highlights: chalk.Highlights, colors: chalk.ColorScheme): nil
	on_highlights = function(highlights, colors) end,

	-- Legacy support (will be deprecated)
	integrations = {},
	custom_highlights = nil,
}

---Current configuration storage
---@type chalk.Config
M.options = {}

---Plugin name mappings for auto-detection
M.plugin_map = {
	["nvim-treesitter"] = "treesitter",
	["telescope.nvim"] = "telescope",
	["nvim-cmp"] = "nvim_cmp",
	["gitsigns.nvim"] = "gitsigns",
	["lualine.nvim"] = "lualine",
	["which-key.nvim"] = "which_key",
	["indent-blankline.nvim"] = "indent_blankline",
	["nvim-tree.lua"] = "nvim_tree",
	["neo-tree.nvim"] = "neo_tree",
	["bufferline.nvim"] = "bufferline",
	["dashboard-nvim"] = "dashboard",
	["alpha-nvim"] = "alpha",
	["noice.nvim"] = "noice",
	["nvim-notify"] = "notify",
	["mini.nvim"] = "mini",
	["leap.nvim"] = "leap",
	["flash.nvim"] = "flash",
	["nvim-navic"] = "navic",
	["aerial.nvim"] = "aerial",
}

---Detect available plugins using lazy.nvim or packer
---@return table<string, boolean> Available plugins
function M.get_available_plugins()
	local available = {}

	-- Try lazy.nvim first
	local lazy_ok, lazy = pcall(require, "lazy")
	if lazy_ok and lazy.plugins then
		for _, plugin in pairs(lazy.plugins()) do
			local name = plugin.name
			local mapped_name = M.plugin_map[name]
			if mapped_name then
				available[mapped_name] = true
			end
		end
		return available
	end

	-- Try packer.nvim
	local packer_ok, packer = pcall(require, "packer")
	if packer_ok and packer.plugin_list then
		for name, _ in pairs(packer.plugin_list) do
			local mapped_name = M.plugin_map[name]
			if mapped_name then
				available[mapped_name] = true
			end
		end
		return available
	end

	-- Fallback: try to require plugins directly
	for plugin_name, mapped_name in pairs(M.plugin_map) do
		if Util.plugin_available(plugin_name) then
			available[mapped_name] = true
		end
	end

	return available
end

---Resolve plugin configuration with auto-detection
---@param user_plugins table User plugin configuration
---@return table<string, boolean> Resolved plugin settings
function M.resolve_plugins(user_plugins)
	local resolved = {}

	-- Start with user configuration
	for plugin, enabled in pairs(user_plugins) do
		if type(enabled) == "table" then
			resolved[plugin] = enabled.enabled ~= false
		else
			resolved[plugin] = enabled
		end
	end

	-- Auto-detect plugins if enabled
	if resolved.auto ~= false then
		local available = M.get_available_plugins()

		for plugin, is_available in pairs(available) do
			-- Only enable if not explicitly disabled and all plugins are enabled
			if resolved[plugin] == nil then
				resolved[plugin] = is_available and (resolved.all ~= false)
			end
		end
	end

	return resolved
end

---Setup configuration with user options
---@param opts? chalk.Config User configuration options
function M.setup(opts)
	opts = opts or {}

	-- Handle legacy configuration format
	if opts.integrations and not opts.plugins then
		vim.notify("chalk.nvim: 'integrations' is deprecated, use 'plugins' instead", vim.log.levels.WARN)
		opts.plugins = opts.integrations
	end

	if opts.custom_highlights and not opts.on_highlights then
		vim.notify("chalk.nvim: 'custom_highlights' is deprecated, use 'on_highlights' instead", vim.log.levels.WARN)
		opts.on_highlights = function(hl, colors)
			if type(opts.custom_highlights) == "function" then
				local custom = opts.custom_highlights(colors)
				for group, definition in pairs(custom) do
					hl[group] = definition
				end
			end
		end
	end

	-- Deep merge with defaults
	M.options = vim.tbl_deep_extend("force", M.defaults, opts)

	-- Resolve plugin configuration
	M.options.plugins = M.resolve_plugins(M.options.plugins)
end

---Extend configuration with additional options
---@param opts? chalk.Config Additional options to merge
---@return chalk.Config Complete configuration
function M.extend(opts)
	if not M.options or vim.tbl_isempty(M.options) then
		M.setup(opts)
	else
		if opts then
			M.options = vim.tbl_deep_extend("force", M.options, opts)
			M.options.plugins = M.resolve_plugins(M.options.plugins)
		end
	end

	return M.options
end

---Get current configuration
---@return chalk.Config Current configuration
function M.get()
	if not M.options or vim.tbl_isempty(M.options) then
		M.setup()
	end
	return M.options
end

---Check if a specific plugin is enabled
---@param plugin_name string Plugin name to check
---@return boolean Whether the plugin is enabled
function M.is_plugin_enabled(plugin_name)
	local config = M.get()
	return config.plugins[plugin_name] == true
end

---Get enabled plugins list
---@return table<string, boolean> Enabled plugins
function M.get_enabled_plugins()
	local config = M.get()
	local enabled = {}

	for plugin, is_enabled in pairs(config.plugins) do
		if is_enabled and plugin ~= "all" and plugin ~= "auto" then
			enabled[plugin] = true
		end
	end

	return enabled
end

return M
