-- Base highlight groups for chalk.nvim
-- Combines editor UI and syntax highlighting
local M = {}

---Setup base highlight groups
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights Highlight groups
function M.setup(colors, opts)
	local c = colors

	local highlights = {
		-- Editor colors
		Normal = { fg = c.fg, bg = "#010e29" },
		NormalFloat = { fg = c.fg, bg = c.bg_2 },
		NormalNC = { fg = c.fg_dark, bg = c.bg_3 },

		-- Cursor
		Cursor = { fg = c.bg_3, bg = c.fg },
		CursorLine = { bg = c.bg_5 },
		CursorColumn = { bg = c.bg_2 },
		CursorLineNr = { fg = c.fg, bold = true, bg = c.bg_3 },

		-- Line numbers
		LineNr = { fg = c.comment, bg = c.bg_3 },
		SignColumn = { fg = c.comment, bg = c.bg_3 },

		-- Folds
		Folded = { fg = c.comment, bg = c.bg_2, italic = true },
		FoldColumn = { fg = c.comment, bg = c.bg_3 },

		-- Selection and search
		Visual = { bg = c.selection },
		VisualNOS = { bg = c.selection },
		Search = { fg = c.none, bg = c.bg_3 },
		IncSearch = { fg = c.none, bg = c.bg_3, bold = true },
		CurSearch = { fg = c.none, bg = c.bg_3, bold = true },

		-- Messages and command line
		MsgArea = { fg = c.fg },
		MsgSeparator = { fg = c.comment },
		MoreMsg = { fg = c.success, bold = true },
		Question = { fg = c.info, bold = true },
		WarningMsg = { fg = c.warning, bold = true },
		ErrorMsg = { fg = c.error, bold = true },

		-- Status line
		StatusLine = { fg = c.fg, bg = c.bg_2 },
		StatusLineNC = { fg = c.comment, bg = c.bg_4 },

		-- Tab line
		TabLine = { fg = c.comment, bg = c.bg_4 },
		TabLineFill = { bg = c.bg_4 },
		TabLineSel = { fg = c.fg, bg = c.bg_3, bold = true },

		-- Windows and splits
		WinBar = { fg = c.fg_light, bg = c.bg_3 },
		WinBarNC = { fg = c.comment, bg = c.bg_3 },
		WinSeparator = { fg = c.bg_1 },
		VertSplit = { fg = c.bg_1 }, -- Legacy

		-- Popup menus
		Pmenu = { fg = c.fg, bg = c.bg_2 },
		PmenuSel = { fg = c.fg, bg = c.bg_1, bold = true },
		PmenuSbar = { bg = c.bg_1 },
		PmenuThumb = { bg = c.fg },

		-- Wild menu
		WildMenu = { fg = c.fg, bg = c.bg_2, bold = true },

		-- Floating windows
		FloatBorder = { fg = c.comment, bg = c.bg_2 },
		FloatTitle = { fg = c.fg, bg = c.bg_2, bold = true },

		-- Columns and guides
		ColorColumn = { bg = c.bg_2 },
		Conceal = { fg = c.comment },

		-- Diff (Standar git diff highlighting)
		DiffDelete = { bg = c.none, fg = c.diff_delete },
		DiffAdd = { bg = c.none, fg = c.diff_add },
		DiffChange = { bg = c.none },
		DiffText = { bg = c.diff_text_bg },

		-- Spelling
		SpellBad = { fg = c.error, undercurl = true, sp = c.error },
		SpellCap = { fg = c.warning, undercurl = true, sp = c.warning },
		SpellLocal = { fg = c.info, undercurl = true, sp = c.info },
		SpellRare = { fg = c.hint, undercurl = true, sp = c.hint },

		-- Diagnostics
		DiagnosticError = { fg = c.error },
		DiagnosticWarn = { fg = c.warning },
		DiagnosticInfo = { fg = c.info },
		DiagnosticHint = { fg = c.hint },
		DiagnosticOk = { fg = c.success },

		-- Diagnostic virtual text
		DiagnosticVirtualTextError = { fg = c.error, bg = c.bg_2 },
		DiagnosticVirtualTextWarn = { fg = c.warning, bg = c.bg_2 },
		DiagnosticVirtualTextInfo = { fg = c.info, bg = c.bg_2 },
		DiagnosticVirtualTextHint = { fg = c.hint, bg = c.bg_2 },
		DiagnosticVirtualTextOk = { fg = c.success, bg = c.bg_2 },

		-- Diagnostic underlines
		DiagnosticUnderlineError = { undercurl = true, sp = c.error },
		DiagnosticUnderlineWarn = { undercurl = true, sp = c.warning },
		DiagnosticUnderlineInfo = { undercurl = true, sp = c.info },
		DiagnosticUnderlineHint = { undercurl = true, sp = c.hint },
		DiagnosticUnderlineOk = { undercurl = true, sp = c.success },

		-- Diagnostic signs
		DiagnosticSignError = { fg = c.error, bg = c.bg_3 },
		DiagnosticSignWarn = { fg = c.warning, bg = c.bg_3 },
		DiagnosticSignHint = { fg = c.hint, bg = c.bg_3 },
		DiagnosticSignOk = { fg = c.success, bg = c.bg_3 },
		DiagnosticSignInfo = { fg = c.info, bg = c.bg_3 },

		-- Directory
		Directory = { fg = c.info, bold = true },

		-- Special keys
		SpecialKey = { fg = c.comment },
		NonText = { fg = c.comment },
		Whitespace = { fg = c.comment },

		-- Match and parentheses
		MatchParen = { fg = c.secondary, bold = true, underline = true },

		-- Title
		Title = { fg = c.primary, bold = true },

		-- Health check
		healthError = { fg = c.error },
		healthSuccess = { fg = c.success },
		healthWarning = { fg = c.warning },

		-- Terminal
		TermCursor = { fg = c.bg_3, bg = c.fg },
		TermCursorNC = { fg = c.bg_3, bg = c.fg },

		-- Quickfix
		QuickFixLine = { bg = c.bg_2, bold = true },

		-- Substitute
		Substitute = { fg = c.bg_3, bg = c.secondary, bold = true },

		-- Modes
		ModeMsg = { fg = c.fg_light, bold = true },

		-- End of buffer
		EndOfBuffer = { fg = c.bg_3, bg = c.bg_3 },

		-- === SYNTAX HIGHLIGHTING ===

		-- Comments
		Comment = { fg = c.comment, italic = opts.styles.comments and opts.styles.comments.italic },

		-- Constants
		Constant = {
			fg = c.orange,
			italic = opts.styles.constants and opts.styles.constants.italic,
			bold = opts.styles.constants and opts.styles.constants.bold,
		},
		String = { fg = c.green, italic = opts.styles.strings and opts.styles.strings.italic },
		Character = { fg = c.green },
		Number = { fg = c.orange },
		Boolean = { fg = c.orange },
		Float = { fg = c.orange },

		-- Identifiers
		Identifier = { fg = c.red, italic = opts.styles.variables and opts.styles.variables.italic },
		Function = {
			fg = c.blue,
			italic = opts.styles.functions and opts.styles.functions.italic,
			bold = opts.styles.functions and opts.styles.functions.bold,
		},

		-- Statements
		Statement = {
			fg = c.purple,
			italic = opts.styles.keywords and opts.styles.keywords.italic,
			bold = opts.styles.keywords and opts.styles.keywords.bold,
		},
		Conditional = { fg = c.purple },
		Repeat = { fg = c.purple },
		Label = { fg = c.red },
		Operator = {
			fg = c.cyan,
			italic = opts.styles.operators and opts.styles.operators.italic,
			bold = opts.styles.operators and opts.styles.operators.bold,
		},
		Keyword = {
			fg = c.purple,
			italic = opts.styles.keywords and opts.styles.keywords.italic,
			bold = opts.styles.keywords and opts.styles.keywords.bold,
		},
		Exception = { fg = c.purple },

		-- PreProcessor
		PreProc = { fg = c.yellow },
		Include = { fg = c.purple },
		Define = { fg = c.purple },
		Macro = { fg = c.purple },
		PreCondit = { fg = c.yellow },

		-- Types
		Type = {
			fg = c.yellow,
			italic = opts.styles.types and opts.styles.types.italic,
			bold = opts.styles.types and opts.styles.types.bold,
		},
		StorageClass = { fg = c.yellow },
		Structure = { fg = c.yellow },
		Typedef = { fg = c.yellow },

		-- Special
		Special = { fg = c.blue },
		SpecialChar = { fg = c.cream, bold = true },
		Tag = { fg = c.red },
		Delimiter = { fg = c.light_gray },
		SpecialComment = { fg = c.comment, bold = true },
		Debug = { fg = c.red },

		-- Underlined
		Underlined = { underline = true },

		-- Ignore
		Ignore = { fg = c.bg_3 },

		-- Error
		Error = { fg = c.error, bold = true },

		-- Todo
		Todo = { fg = c.warning, bg = c.bg_3, bold = true },
	}

	return highlights
end

return M
