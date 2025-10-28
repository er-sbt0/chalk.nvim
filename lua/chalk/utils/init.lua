-- Chalk utilities module
-- Simplified and consolidated utility system for chalk.nvim

local M = {}

-- Direct module access (no lazy loading needed for simplified structure)

---Access to enhanced color utilities
---@return table Colors module with advanced color manipulation
function M.colors()
	return require("chalk.utils.colors")
end

---Access to dynamic color adjustment system
---@return table Dynamic module for real-time color changes
function M.dynamic()
	return require("chalk.utils.dynamic")
end

---Access to transparency management
---@return table Transparency module
function M.transparency()
	return require("chalk.utils.transparency")
end

---Access to analysis and debugging tools
---@return table Analyzer module for debugging highlights
function M.analyzer()
	return require("chalk.utils.analyzer")
end

-- Convenient top-level functions

---Setup all utility commands
---@param opts? table Options for setup
function M.setup_commands(opts)
	opts = opts or {}

	-- Setup all commands
	M.dynamic().setup_commands()
	M.transparency().setup_commands()
	M.analyzer().setup_commands()

	vim.notify("[Utils] All chalk utility commands enabled", vim.log.levels.INFO)
end

---Quick setup with sensible defaults
---@param opts? table Setup options
function M.quick_setup(opts)
	opts = vim.tbl_extend("force", {
		-- Chalk options
		variant = "default",
		transparent = false,
		terminal_colors = true,
		-- Utils options
		enable_dynamic = false,
		enable_transparency_commands = false,
		enable_analyzer = false,
	}, opts or {})

	-- Setup chalk colorscheme
	require("chalk").setup(opts)

	-- Setup utilities based on options
	if opts.enable_dynamic then
		M.dynamic().setup_commands()
	end

	if opts.enable_transparency_commands then
		M.transparency().setup_commands()
	end

	if opts.enable_analyzer then
		M.analyzer().setup_commands()
	end

	-- Show completion message
	vim.defer_fn(function()
		local enabled_features = {}
		if opts.enable_dynamic then
			table.insert(enabled_features, "dynamic colors")
		end
		if opts.enable_transparency_commands then
			table.insert(enabled_features, "transparency")
		end
		if opts.enable_analyzer then
			table.insert(enabled_features, "analyzer")
		end

		local message = "🎨 Chalk colorscheme enabled!"
		if #enabled_features > 0 then
			message = message .. " Features: " .. table.concat(enabled_features, ", ")
		end

		vim.notify(message, vim.log.levels.INFO)
	end, 100)
end

---Enable all utilities
---@param opts? table Setup options
function M.enable_all(opts)
	opts = opts or {}

	M.setup_commands(opts)
	vim.notify("[Utils] All chalk utilities enabled!", vim.log.levels.INFO)
end

-- Export commonly used functions for convenience
M.adjust_brightness = function(...)
	return M.colors().adjust_brightness(...)
end
M.shift_hue = function(...)
	return M.colors().shift_hue(...)
end
M.apply_color_family = function(...)
	return M.colors().apply_color_family(...)
end

return M
