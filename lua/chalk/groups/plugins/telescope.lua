-- Telescope plugin highlights for chalk.nvim
local M = {}

---Get base Telescope highlight groups
---@param colors chalk.ColorScheme Color scheme
---@return chalk.Highlights Base Telescope highlight groups
local function get_base_highlights(colors)
	local c = colors

	return {
		-- Telescope window
		TelescopeNormal = { bg = c.bg_float, fg = c.fg },
		TelescopeBorder = { bg = c.bg_float, fg = c.border },
		TelescopeTitle = { fg = c.fg, bold = true },

		-- Telescope prompts
		TelescopePromptNormal = { bg = c.bg_4 },
		TelescopePromptBorder = { bg = c.bg_4, fg = c.bg_4 },
		TelescopePromptTitle = { bg = c.peach, fg = c.fg_darker, bold = true },
		TelescopePromptPrefix = { bg = c.bg_4, fg = c.red },
		TelescopePromptCounter = { fg = c.comment },

		-- Telescope results
		TelescopeResultsNormal = { bg = c.bg_float, fg = c.fg },
		TelescopeResultsBorder = { bg = c.bg_float, fg = c.bg_float },
		TelescopeResultsTitle = { bg = c.bg_float, fg = c.fg },

		-- Telescope preview
		TelescopePreviewNormal = { bg = c.bg_4, fg = c.fg },
		TelescopePreviewBorder = { bg = c.bg_4, fg = c.bg_4 },
		TelescopePreviewTitle = { bg = c.green, fg = c.fg_darker, bold = true },

		-- Telescope selections
		TelescopeSelection = { bg = c.bg_2, fg = c.fg },
		TelescopeSelectionCaret = { bg = c.bg_2, fg = c.red },
		TelescopeMultiSelection = { bg = c.bg_2er, fg = c.fg },
		TelescopeMultiIcon = { fg = c.blue },

		-- Telescope matching
		TelescopeMatching = { fg = c.blue, bold = true },

		-- Telescope directory/file types
		TelescopeResultsClass = { fg = c.yellow },
		TelescopeResultsConstant = { fg = c.orange },
		TelescopeResultsField = { fg = c.green },
		TelescopeResultsFunction = { fg = c.blue },
		TelescopeResultsMethod = { fg = c.blue },
		TelescopeResultsOperator = { fg = c.cyan },
		TelescopeResultsStruct = { fg = c.yellow },
		TelescopeResultsVariable = { fg = c.red },
		TelescopeResultsLineNr = { fg = c.orange },
		TelescopeResultsIdentifier = { fg = c.red },
		TelescopeResultsNumber = { fg = c.orange },
		TelescopeResultsComment = { fg = c.comment },
		TelescopeResultsSpecialComment = { fg = c.comment, italic = true },

		-- Telescope file browser
		TelescopeResultsDiffAdd = { fg = c.green },
		TelescopeResultsDiffChange = { fg = c.yellow },
		TelescopeResultsDiffDelete = { fg = c.red },
	}
end

---Apply transparency to Telescope highlight groups
---@param highlights chalk.Highlights Telescope highlight groups
---@param colors chalk.ColorScheme Color scheme
---@return chalk.Highlights Updated highlights with transparency
local function apply_transparency(highlights, colors)
	-- Groups that should become transparent for Telescope
	local transparent_groups = {
		"TelescopeNormal",
		"TelescopeBorder",
		"TelescopePromptNormal",
		"TelescopePromptBorder",
		"TelescopeResultsNormal",
		"TelescopeResultsBorder",
		"TelescopePreviewNormal",
		"TelescopePreviewBorder",
	}

	for _, group in ipairs(transparent_groups) do
		if highlights[group] then
			highlights[group].bg = colors.none
		end
	end

	return highlights
end

---Setup Telescope highlight groups
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights Telescope highlight groups
function M.setup(colors, opts)
	local highlights = get_base_highlights(colors)

	-- Apply transparency if enabled
	if opts.transparent then
		highlights = apply_transparency(highlights, colors)
	end

	return highlights
end

return M
