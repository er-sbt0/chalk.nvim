-- Main entry point for chalk.nvim colorscheme
-- Follows TokyoNight.nvim architectural patterns

local Config = require("chalk.config")

local M = {}

---@type {light?: string, dark?: string}
M.variants = {}

---Load chalk colorscheme with specified options
---@param opts? chalk.Config Configuration options
---@return chalk.ColorScheme, chalk.Highlights, chalk.Config
function M.load(opts)
	opts = Config.extend(opts)

	-- Handle background/variant logic similar to TokyoNight
	local bg = vim.o.background
	local variant_bg = opts.variant == "light" and "light" or "dark"

	-- Auto-switch variant based on background setting
	if bg ~= variant_bg then
		-- If chalk is already loaded and background changed, switch variant
		if vim.g.colors_name and vim.g.colors_name:match("^chalk") then
			if bg == "light" then
				opts.variant = M.variants.light or opts.light_variant or "light"
			else
				opts.variant = M.variants.dark or "default"
			end
		else
			-- Set background to match variant
			vim.o.background = variant_bg
		end
	end

	-- Remember variant for background
	M.variants[vim.o.background] = opts.variant

	-- Load theme through orchestrator
	return require("chalk.theme").setup(opts)
end

---Setup chalk colorscheme configuration
---@param opts? chalk.Config Configuration options
function M.setup(opts)
	Config.setup(opts)
end

---Get current colors for the active or specified variant
---@param variant? string Variant to get colors for
---@return chalk.ColorScheme Color scheme
function M.get_colors(variant)
	return require("chalk.theme").get_colors(variant)
end

---Toggle between light and dark variants
---@return chalk.ColorScheme, chalk.Highlights, chalk.Config
function M.toggle()
	return require("chalk.theme").toggle()
end

---Preview a variant without applying it
---@param variant string Variant to preview
---@return chalk.ColorScheme Color scheme for preview
function M.preview(variant)
	return require("chalk.theme").preview(variant)
end

---Get theme information and status
---@return table Theme metadata
function M.info()
	return require("chalk.theme").info()
end

---Access to chalk dynamic color utilities (dynamic adjustment, transparency, etc.)
---@return table Dynamic module
function M.dynamic()
	return require("chalk.dynamic")
end

return M
