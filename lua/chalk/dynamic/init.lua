-- Chalk dynamic color system module
-- Provides real-time color adjustments and utilities
--
-- API PATTERN: All functions return modules (no state caching)
-- This ensures fresh module state and avoids stale references

local M = {}

---Access to enhanced color utilities
---Pure utility functions for color manipulation (no state)
---@return table Colors module with advanced color manipulation
function M.colors()
	return require("chalk.dynamic.colors")
end

---Access to dynamic color adjustment system
---Manages real-time color changes with persistent storage
---@return table Dynamic module for real-time color changes
function M.dynamic()
	return require("chalk.dynamic.dynamic")
end

-- Convenient top-level functions

---Setup all utility commands
---@param opts? table Options for setup
function M.setup_commands(opts)
	opts = opts or {}

	-- Setup all commands
	M.dynamic().setup_commands()

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
	}, opts or {})

	-- Setup chalk colorscheme
	require("chalk").setup(opts)

	-- Setup utilities based on options
	if opts.enable_dynamic then
		M.dynamic().setup_commands()
	end

	-- Show completion message
	vim.defer_fn(function()
		local enabled_features = {}
		if opts.enable_dynamic then
			table.insert(enabled_features, "dynamic colors")
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
	vim.notify("[Dynamic] All chalk dynamic features enabled!", vim.log.levels.INFO)
end

---Setup keymaps for dynamic color commands
---@param opts? table Keymap options
function M.setup_keymaps(opts)
	opts = vim.tbl_extend("force", {
		prefix = "<leader>c", -- Default key prefix for dynamic color operations
		silent = true,
		noremap = true,
	}, opts or {})

	-- Ensure commands are set up first
	M.setup_commands()

	local keymap = vim.keymap.set

	-- Define keymaps for dynamic color commands
	local keymaps = {
		-- Brightness adjustments
		{ "H", ":ChalkIncreaseBrightness<CR>", "Increase brightness" },
		{ "J", ":ChalkDecreaseBrightness<CR>", "Decrease brightness" },

		-- Color wheel navigation
		{ "K", ":ChalkNextColor<CR>", "Next color" },
		{ "L", ":ChalkPrevColor<CR>", "Previous color" },

		-- -- Color families
		-- { "cw", ":ChalkWarmColor<CR>", "Warm color" },
		-- { "cc", ":ChalkCoolColor<CR>", "Cool color" },
		-- { "cs", ":ChalkSaturated<CR>", "Saturated color" },
		-- { "cm", ":ChalkMuted<CR>", "Muted color" },

		-- -- Utility commands
		-- { "cr", ":ChalkReset<CR>", "Reset colors" },
		-- { "cl", ":ChalkClear<CR>", "Clear overrides" },
		-- { "ci", ":ChalkInspect<CR>", "Inspect group" },
		-- { "cv", ":ChalkShow<CR>", "View overrides" },
	}

	-- Create keymaps with prefix
	for _, map in ipairs(keymaps) do
		local key, cmd, desc = map[1], map[2], map[3]
		-- Apply prefix to key
		keymap("n", key, cmd, {
			desc = "Chalk: " .. desc,
			silent = opts.silent,
			noremap = opts.noremap,
		})
	end
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
