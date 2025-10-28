-- Transparency utilities for chalk.nvim
-- Provides functions to enable/disable/toggle transparency

local M = {}

---Notify with consistent formatting
---@param message string Message to display
---@param level? number Log level (default: INFO)
local function notify(message, level)
	level = level or vim.log.levels.INFO
	vim.notify(string.format("[Transparency] %s", message), level)
end

---Safe module loading
---@param name string Module name
---@return table|nil Module or nil if failed
local function safe_require(name)
	local ok, result = pcall(require, name)
	return ok and result or nil
end

---Get current chalk config
---@return table|nil Config table
local function get_chalk_config()
	local Config = safe_require("chalk.config")
	return Config and Config.get() or nil
end

---Reload chalk colorscheme with new config
---@param new_config table Config overrides
local function reload_colorscheme(new_config)
	local chalk = safe_require("chalk")
	if chalk then
		chalk.setup(new_config)
		vim.cmd("colorscheme chalk")
	end
end

---Apply transparency to specific highlight groups
---This function applies the transparency overrides you requested
function M.apply_transparency()
	-- Make base UI transparent
	vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "VertSplit", { bg = "NONE" })

	-- Floating windows / popups / borders
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "PmenuSel", { bg = "NONE" })
end

---Enable transparency through colorscheme config and reload
function M.enable()
	local current_config = get_chalk_config() or {}
	reload_colorscheme(vim.tbl_extend("force", current_config, { transparent = true }))
	notify("Transparency enabled")
end

---Disable transparency through colorscheme config and reload
function M.disable()
	local current_config = get_chalk_config() or {}
	reload_colorscheme(vim.tbl_extend("force", current_config, { transparent = false }))
	notify("Transparency disabled")
end

---Toggle transparency on/off
function M.toggle()
	local current_config = get_chalk_config()
	if current_config and current_config.transparent then
		M.disable()
	else
		M.enable()
	end
end

---Apply transparency overrides without reloading entire colorscheme
---This is the lightweight version that just applies the highlight overrides
function M.apply_overrides()
	M.apply_transparency()
	vim.notify("Transparency overrides applied", vim.log.levels.INFO)
end

---Remove transparency overrides (restore backgrounds)
function M.remove_overrides()
	local Theme = safe_require("chalk.theme")
	local Config = safe_require("chalk.config")

	if not Theme or not Config then
		notify("Failed to load chalk modules", vim.log.levels.ERROR)
		return
	end

	-- Get current colors without transparency
	local config = Config.get()
	local original_transparent = config.transparent
	config.transparent = false

	local colors = Theme.get_colors()

	-- Restore backgrounds
	vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "NormalNC", { fg = colors.fg_darker, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "SignColumn", { fg = colors.comment, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = colors.bg_3, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "LineNr", { fg = colors.comment, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.bg_2 })
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.fg, bold = true, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.comment, bg = colors.bg_3 })
	vim.api.nvim_set_hl(0, "VertSplit", { fg = colors.bg_1, bg = colors.bg_3 })

	-- Floating windows / popups / borders
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg, bg = colors.bg_2 })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.comment, bg = colors.bg_2 })
	vim.api.nvim_set_hl(0, "FloatTitle", { fg = colors.fg, bg = colors.bg_2, bold = true })
	vim.api.nvim_set_hl(0, "Pmenu", { fg = colors.fg, bg = colors.bg_2 })
	vim.api.nvim_set_hl(0, "PmenuSel", { fg = colors.fg, bg = colors.bg_1, bold = true })

	-- Restore original setting
	config.transparent = original_transparent

	notify("Transparency overrides removed")
end

---Setup transparency commands
function M.setup_commands()
	local commands = {
		ChalkTransparencyEnable = {
			callback = M.enable,
			opts = { desc = "Enable transparency in Chalk colorscheme" },
		},
		ChalkTransparencyDisable = {
			callback = M.disable,
			opts = { desc = "Disable transparency in Chalk colorscheme" },
		},
		ChalkTransparencyToggle = {
			callback = M.toggle,
			opts = { desc = "Toggle transparency in Chalk colorscheme" },
		},
		ChalkTransparencyApply = {
			callback = M.apply_overrides,
			opts = { desc = "Apply transparency overrides without reloading colorscheme" },
		},
		ChalkTransparencyRemove = {
			callback = M.remove_overrides,
			opts = { desc = "Remove transparency overrides" },
		},
	}

	for name, def in pairs(commands) do
		vim.api.nvim_create_user_command(name, def.callback, def.opts)
	end

	notify("Transparency commands enabled")
end

---Get current transparency status
---@return boolean Whether transparency is currently enabled
function M.is_enabled()
	local config = get_chalk_config()
	return config and config.transparent or false
end

return M
