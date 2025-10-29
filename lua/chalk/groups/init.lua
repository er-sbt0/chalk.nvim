local Util = require("chalk.util")
local Config = require("chalk.config")

local M = {}

---Available highlight groups for fast lookup
M.available_groups = {
	-- Base groups (always available)
	base = true,
	treesitter = true,

	-- Plugin groups (with dedicated files)
	telescope = true,
	nvim_cmp = true,
	gitsigns = true,
	which_key = true,
	bufferline = true,
	treesitter_context = true,
	nvim_tree = true,
	noice = true,
}

---Plugin to group mapping for organized plugin support
M.plugins = {
	-- Plugins with dedicated highlight support files
	["telescope.nvim"] = "telescope",
	["nvim-cmp"] = "nvim_cmp",
	["gitsigns.nvim"] = "gitsigns",
	["which-key.nvim"] = "which_key",
	["bufferline.nvim"] = "bufferline",
	["nvim-treesitter-context"] = "treesitter_context",
	["nvim-tree.lua"] = "nvim_tree",
}

---Get a highlight group module
---@param name string Group name (base, treesitter, or plugin name)
---@return table|nil Group module or nil if not found
function M.get_group(name)
	-- Try plugins directory first (silently to avoid spam)
	local plugin_module = Util.mod("chalk.groups.plugins." .. name, true)
	if plugin_module then
		return plugin_module
	end

	-- Try base groups directory (silently for plugins, with errors for base groups)
	local is_base_group = name == "base" or name == "treesitter"
	local base_module = Util.mod("chalk.groups." .. name, not is_base_group)
	return base_module
end

---Load highlight groups from a module
---@param name string Group name
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights|nil Highlight groups or nil if failed
function M.get(name, colors, opts)
	local mod = M.get_group(name)
	if not mod then
		return nil
	end

	-- Ensure mod is a table or function
	if type(mod) ~= "table" and type(mod) ~= "function" then
		Util.error(string.format("Invalid module type for '%s': expected table or function, got %s", name, type(mod)))
		return nil
	end

	-- Call the module's setup/get function
	if type(mod) == "table" then
		if type(mod.setup) == "function" then
			return mod.setup(colors, opts)
		elseif type(mod.get) == "function" then
			return mod.get(colors, opts)
		end
		-- Module should export highlight groups directly
		return mod
	elseif type(mod) == "function" then
		return mod(colors, opts)
	end

	return nil
end

---Setup all highlight groups based on configuration
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights, table<string, boolean> All highlights and loaded groups
function M.setup(colors, opts)
	local highlights = {}
	local loaded_groups = {}

	-- Always load base groups
	local base_groups = { "base", "treesitter" }

	for _, group_name in ipairs(base_groups) do
		local group_highlights = M.get(group_name, colors, opts)
		if group_highlights then
			for hl_name, hl_def in pairs(group_highlights) do
				highlights[hl_name] = hl_def
			end
			loaded_groups[group_name] = true
		else
			vim.notify("chalk.nvim: Failed to load base group '" .. group_name .. "'", vim.log.levels.WARN)
		end
	end

	-- Load plugin-specific groups based on configuration
	local enabled_plugins = Config.get_enabled_plugins()

	for plugin_name, enabled in pairs(enabled_plugins) do
		if enabled and plugin_name ~= "treesitter" then -- treesitter handled above
			-- Only try to load if the highlight group module actually exists
			if M.has_group(plugin_name) then
				local group_highlights = M.get(plugin_name, colors, opts)
				if group_highlights then
					for hl_name, hl_def in pairs(group_highlights) do
						highlights[hl_name] = hl_def
					end
					loaded_groups[plugin_name] = true
				end
			end
			-- Don't show warnings for missing plugin highlights - it's normal
			-- Most plugins don't need custom highlight groups
		end
	end

	-- Apply transparency AFTER all groups (base + plugins) have been loaded
	-- NOTE: Plugin-specific transparency is now handled by each plugin's setup function
	-- This section only handles core UI transparency groups
	if opts.transparent then
		-- Helper function to make a highlight group transparent
		local function make_transparent(group)
			if highlights[group] then
				highlights[group].bg = colors.none
				highlights[group].ctermbg = colors.none
			end
		end

		-- Core UI elements that should always be transparent when enabled
		local core_transparent_groups = {
			"ColorColumn",
			"CursorColumn",
			"CursorLine",
			"CursorLineNr",
			"DiagnosticSignError",
			"DiagnosticSignHint",
			"DiagnosticSignInfo",
			"DiagnosticSignOk",
			"DiagnosticSignWarn",
			"DiagnosticVirtualTextError",
			"DiagnosticVirtualTextHint",
			"DiagnosticVirtualTextInfo",
			"DiagnosticVirtualTextOk",
			"DiagnosticVirtualTextWarn",
			"EndOfBuffer",
			"FloatBorder",
			"FloatShadow",
			"FloatShadowThrough",
			"FloatTitle",
			"FoldColumn",
			"Folded",
			"LineNr",
			"MsgSeparator",
			"Normal",
			"NormalFloat",
			"NormalNC",
			"NotifyBackground",
			"Pmenu",
			"PmenuSbar",
			"PmenuThumb",
			"SignColumn",
			"StatusLine",
			"StatusLineNC",
			"StatusLineTerm",
			"StatusLineTermNC",
			"TabLine",
			"TabLineFill",
			"TabLineSel",
			"VertSplit",
			"WhichKeyFloat",
			"WinBar",
			"WinBarNC",
			"WinSeparator",
			-- "QuickFixLine",  -- Removed: needs background for visibility
			-- "MatchParen",    -- Removed: needs background to highlight matching brackets
			-- "MiniSurround",  -- Removed: should be handled by plugin module

			-- Trouble (no dedicated plugin module yet)
			"TroubleNormal",
			"TroubleCount",
		}

		-- Apply transparency to core UI groups only
		-- Plugin-specific transparency is now handled by each plugin's setup function
		for _, group in ipairs(core_transparent_groups) do
			make_transparent(group)
		end
	end

	return highlights, loaded_groups
end

---Check if a group module exists
---@param name string Group name to check
---@return boolean Whether the group exists
function M.has_group(name)
	-- Fast path: check known groups first
	if M.available_groups[name] ~= nil then
		return M.available_groups[name]
	end

	-- Fallback: try to load (for dynamic/future groups)
	return M.get_group(name) ~= nil
end

---Preview groups without applying them
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@param groups? string[] Specific groups to preview (optional)
---@return chalk.Highlights Preview highlights
function M.preview(colors, opts, groups)
	if groups then
		local highlights = {}
		for _, group_name in ipairs(groups) do
			local group_highlights = M.get(group_name, colors, opts)
			if group_highlights then
				for hl_name, hl_def in pairs(group_highlights) do
					highlights[hl_name] = hl_def
				end
			end
		end
		return highlights
	else
		local highlights, _ = M.setup(colors, opts)
		return highlights
	end
end

return M
