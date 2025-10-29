local M = {}

local languages = require("chalk.groups.languages")

---Setup TreeSitter highlight groups
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights TreeSitter highlight groups
function M.setup(colors, opts)
	local c = colors

	local highlights = {
		-- Annotations
		["@annotation"] = { fg = c.azure },
		["@annotation.builtin"] = { fg = c.azure, bold = true },

		-- Attributes
		["@attribute"] = { fg = c.azure },
		["@attribute.builtin"] = { fg = c.azure, bold = true },

		-- Booleans
		["@boolean"] = { fg = c.azure },

		-- Characters
		["@character"] = { fg = c.emerald },

		-- Comments
		["@comment"] = {},
		["@comment.documentation"] = { fg = c.azure, italic = true },
		["@comment.error"] = { fg = c.azure, bold = true },
		["@comment.warning"] = { fg = c.azure, bold = true },
		["@comment.todo"] = { fg = c.azure, bg = c.bg_3, bold = true },
		["@comment.note"] = { fg = c.azure, bg = c.bg_3, bold = true },

		-- Constants
		["@constant"] = { fg = c.coral },
		["@constant.builtin"] = { fg = c.copper, bold = true },
		["@constant.macro"] = { fg = c.azure, italic = true },

		-- Functions
		["@function"] = { fg = c.indigo },
		["@function.builtin"] = { fg = c.azure, bold = true },
		["@function.call"] = { fg = c.blue },
		["@function.macro"] = { fg = c.azure, bold = true },
		["@function.method"] = { fg = c.azure },
		["@function.method.call"] = { fg = c.azure },

		-- Keywords
		["@keyword"] = { fg = c.mauve_medium },
		["@keyword.type"] = { fg = c.turquoise },
		["@keyword.conditional"] = { fg = c.mauve },
		["@keyword.conditional.ternary"] = { fg = c.azure },
		["@keyword.coroutine"] = { fg = c.azure, italic = true },
		["@keyword.debug"] = { fg = c.azure, bold = true },
		["@keyword.directive"] = { fg = c.azure },
		["@keyword.directive.define"] = { fg = c.azure },
		["@keyword.exception"] = { fg = c.azure, bold = true },
		["@keyword.function"] = { fg = c.mauve_light },
		["@keyword.import"] = { fg = c.mauve_dark, italic = true },
		["@keyword.modifier"] = { fg = c.mauve },
		["@keyword.operator"] = { fg = c.azure },
		["@keyword.repeat"] = { fg = c.mauve },
		["@keyword.return"] = { fg = c.mauve_light },
		["@keyword.storage"] = { fg = c.azure },

		-- Labels
		["@label"] = { fg = c.azure },
		["@spell"] = { fg = c.stone_3 },

		-- Literals
		["@markup"] = { fg = c.azure },
		["@markup.emphasis"] = { italic = true },
		["@markup.strong"] = { bold = true },
		["@markup.environment"] = { fg = c.azure },
		["@markup.link"] = { fg = c.azure, underline = true },
		["@markup.link.label"] = { fg = c.azure },
		["@markup.list"] = { fg = c.azure },
		["@markup.list.checked"] = { fg = c.azure },
		["@markup.list.unchecked"] = { fg = c.azure },
		["@markup.math"] = { fg = c.azure },
		["@markup.quote"] = { fg = c.azure, italic = true },
		["@markup.raw"] = { fg = c.azure },
		["@markup.underline"] = { underline = true },

		-- Math
		["@math"] = { fg = c.azure },

		-- Modules
		["@module"] = { fg = c.steel_blue },
		["@module.builtin"] = { fg = c.azure, bold = true },

		-- Namespace
		["@namespace"] = { fg = c.azure },

		-- Numbers
		["@number"] = { fg = "#de8a7c", bold = false },
		["@number.float"] = { fg = c.azure },

		-- Operators
		["@operator"] = { fg = c.stone_2 },

		-- Parameters
		["@parameter"] = { fg = c.stone_2 },
		["@parameter.builtin"] = { fg = c.azure, italic = true },
		["@parameter.reference"] = { fg = c.azure },

		-- Properties
		["@property"] = { fg = c.rose },

		-- Punctuation
		["@punctuation.bracket"] = { fg = c.azure },

		-- Strings
		["@string"] = { fg = c.emerald },
		["@string.documentation"] = { fg = c.azure, italic = true },
		["@string.escape"] = { fg = c.azure },
		["@string.regex"] = { fg = c.azure },
		["@string.special"] = { fg = c.azure },
		["@string.special.path"] = { fg = c.azure, underline = true },
		["@string.special.url"] = { fg = c.azure, underline = true },

		-- Tags
		["@tag"] = { fg = c.azure },

		-- Types
		["@type"] = { fg = c.indigo },
		["@type.builtin"] = { fg = c.azure, bold = true },
		["@type.definition"] = { fg = c.azure, bold = true },
		["@type.qualifier"] = { fg = c.azure },

		-- Variables
		["@variable"] = { fg = c.stone_1 },
		["@variable.builtin"] = { fg = c.azure, italic = true },
		["@variable.member"] = { fg = c.stone_1 },
		["@variable.parameter"] = { fg = c.stone_3 },

		-- LSP semantic tokens
		["@lsp.type.class"] = {},
		["@lsp.type.decorator"] = {},
		["@lsp.type.enum"] = {},
		["@lsp.type.enumMember"] = {},
		["@lsp.type.function"] = {},
		["@lsp.type.interface"] = {},
		["@lsp.type.macro"] = {},
		["@lsp.type.method"] = {},
		["@lsp.type.namespace"] = {},
		["@lsp.type.property"] = {},
		["@lsp.type.struct"] = {},
		["@lsp.type.type"] = {},
		["@lsp.type.typeParameter"] = {},
		["@lsp.type.variable"] = {},
		["@lsp.type.keyword"] = {},
		["@lsp.type.parameter"] = { fg = c.stone_1 },

		-- LSP semantic token modifiers
		["@lsp.mod.deprecated"] = {},
		["@lsp.mod.readonly"] = {},
		["@lsp.mod.static"] = {},

		-- LSP UI elements
		LspCodeLens = { link = "NonText" },
		LspCodeLensSeparator = { link = "LspCodeLens" },
		LspInlayHint = { link = "NonText" },
		LspSignatureActiveParameter = { link = "Visual" },

		-- LSP reference highlighting
		LspReferenceRead = { bg = c.bg_3 },
		LspReferenceText = { bg = c.bg_3 },
		LspReferenceWrite = { bg = c.bg_3 },
		LspReferenceTarget = { bg = c.bg_3 },
	}

	-- Load language-specific highlights and merge them
	local language_highlights = languages.load_all(colors, opts)
	for group, config in pairs(language_highlights) do
		highlights[group] = config
	end

	return highlights
end

return M
