-- NvimTree plugin highlights for chalk.nvim
-- Based on the sophisticated chalk color scheme with earth tones and refined jewel accents
local M = {}

---Get base NvimTree highlight groups
---@param colors chalk.ColorScheme Color scheme
---@return chalk.Highlights Base NvimTree highlight groups
local function get_base_highlights(colors)
	local c = colors

	return {
		-- === BASIC UI ELEMENTS ===
		-- Window and layout
		NvimTreeNormal = { link = "Normal" },
		NvimTreeNormalFloat = { link = "NormalFloat" },
		NvimTreeNormalFloatBorder = { link = "FloatBorder" },
		NvimTreeNormalNC = { link = "NvimTreeNormal" },
		NvimTreeLineNr = { link = "LineNr" },
		NvimTreeWinSeparator = { link = "WinSeparator" },
		NvimTreeEndOfBuffer = { link = "EndOfBuffer" },
		NvimTreePopup = { link = "Normal" },
		NvimTreeSignColumn = { link = "NvimTreeNormal" },
		NvimTreeCursorColumn = { link = "CursorColumn" },
		NvimTreeCursorLine = { link = "CursorLine" },
		NvimTreeCursorLineNr = { link = "CursorLineNr" },
		NvimTreeStatusLine = { link = "StatusLine" },
		NvimTreeStatusLineNC = { link = "StatusLineNC" },

		-- === FOLDER AND FILE ICONS ===
		-- Main folder icon - using azure family for sophisticated blue folder appearance
		NvimTreeFolderIcon = { fg = c.steel_blue }, -- Base steel blue for folder icons
		NvimTreeFileIcon = { link = "NvimTreeNormal" },
		NvimTreeSymlinkIcon = { link = "NvimTreeNormal" },
		NvimTreeOpenedFolderIcon = { link = "NvimTreeFolderIcon" },
		NvimTreeClosedFolderIcon = { link = "NvimTreeFolderIcon" },

		-- Folder arrows and indent markers
		NvimTreeFolderArrowClosed = { link = "NvimTreeIndentMarker" },
		NvimTreeIndentMarker = { link = "NvimTreeFolderIcon" },
		NvimTreeFolderArrowOpen = { link = "NvimTreeIndentMarker" },

		-- === FILE AND FOLDER NAMES ===
		-- File types
		NvimTreeExecFile = { link = "Question" },
		NvimTreeImageFile = { link = "Question" },
		NvimTreeSpecialFile = { link = "Title" },
		NvimTreeSymlink = { link = "Underlined" },

		-- Folder names
		NvimTreeRootFolder = { link = "Title" },
		NvimTreeFolderName = { link = "Directory" },
		NvimTreeEmptyFolderName = { link = "Directory" },
		NvimTreeOpenedFolderName = { link = "Directory" },
		NvimTreeSymlinkFolderName = { link = "Directory" },

		-- === WINDOW PICKER ===
		-- Sophisticated window picker with enhanced contrast
		NvimTreeWindowPicker = { fg = c.fg_light, bg = c.ocean_blue, bold = true },

		-- === DIAGNOSTIC HIGHLIGHTS ===
		-- Diagnostic folder highlights - link to corresponding file highlights
		NvimTreeDiagnosticWarnFolderHL = { link = "NvimTreeDiagnosticWarnFileHL" },
		NvimTreeDiagnosticErrorFolderHL = { link = "NvimTreeDiagnosticErrorFileHL" },
		NvimTreeDiagnosticHintFolderHL = { link = "NvimTreeDiagnosticHintFileHL" },
		NvimTreeDiagnosticInfoFolderHL = { link = "NvimTreeDiagnosticInfoFileHL" },

		-- Diagnostic file highlights - link to standard diagnostic underlines
		NvimTreeDiagnosticHintFileHL = { link = "DiagnosticUnderlineHint" },
		NvimTreeDiagnosticInfoFileHL = { link = "DiagnosticUnderlineInfo" },
		NvimTreeDiagnosticWarnFileHL = { link = "DiagnosticUnderlineWarn" },
		NvimTreeDiagnosticErrorFileHL = { link = "DiagnosticUnderlineError" },

		-- Diagnostic icons - link to standard diagnostic highlights
		NvimTreeDiagnosticHintIcon = { link = "DiagnosticHint" },
		NvimTreeDiagnosticInfoIcon = { link = "DiagnosticInfo" },
		NvimTreeDiagnosticWarnIcon = { link = "DiagnosticWarn" },
		NvimTreeDiagnosticErrorIcon = { link = "DiagnosticError" },

		-- Legacy LSP diagnostic groups (cleared as per original spec)
		NvimTreeLspDiagnosticsWarningFolderText = {},
		NvimTreeLspDiagnosticsErrorFolderText = {},
		NvimTreeLspDiagnosticsHintText = {},
		NvimTreeLspDiagnosticsInformationText = {},
		NvimTreeLspDiagnosticsWarningText = {},
		NvimTreeLspDiagnosticsErrorText = {},
		NvimTreeLspDiagnosticsHint = {},
		NvimTreeLspDiagnosticsInformation = {},
		NvimTreeLspDiagnosticsWarning = {},
		NvimTreeLspDiagnosticsError = {},
		NvimTreeLspDiagnosticsHintFolderText = {},
		NvimTreeLspDiagnosticsInformationFolderText = {},

		-- === GIT INTEGRATION ===
		-- Git folder highlights - link to corresponding file highlights
		NvimTreeGitFolderStagedHL = { link = "NvimTreeGitFileStagedHL" },
		NvimTreeGitFolderRenamedHL = { link = "NvimTreeGitFileRenamedHL" },
		NvimTreeGitFolderNewHL = { link = "NvimTreeGitFileNewHL" },
		NvimTreeGitFolderMergeHL = { link = "NvimTreeGitFileMergeHL" },
		NvimTreeGitFolderIgnoredHL = { link = "NvimTreeGitFileIgnoredHL" },
		NvimTreeGitFolderDirtyHL = { link = "NvimTreeGitFileDirtyHL" },
		NvimTreeGitFolderDeletedHL = { link = "NvimTreeGitFileDeletedHL" },

		-- Git file highlights - link to corresponding icon highlights
		NvimTreeGitFileStagedHL = { link = "NvimTreeGitStagedIcon" },
		NvimTreeGitFileRenamedHL = { link = "NvimTreeGitRenamedIcon" },
		NvimTreeGitFileNewHL = { link = "NvimTreeGitNewIcon" },
		NvimTreeGitFileMergeHL = { link = "NvimTreeGitMergeIcon" },
		NvimTreeGitFileIgnoredHL = { link = "NvimTreeGitIgnoredIcon" },
		NvimTreeGitFileDirtyHL = { link = "NvimTreeGitDirtyIcon" },
		NvimTreeGitFileDeletedHL = { link = "NvimTreeGitDeletedIcon" },

		-- Git status icons - using semantic highlight group mappings
		NvimTreeGitStagedIcon = { link = "Constant" }, -- Orange for staged files
		NvimTreeGitRenamedIcon = { link = "PreProc" }, -- Yellow for renamed files
		NvimTreeGitNewIcon = { link = "PreProc" }, -- Yellow for new files
		NvimTreeGitMergeIcon = { link = "Constant" }, -- Orange for merge conflicts
		NvimTreeGitIgnoredIcon = { link = "Comment" }, -- Muted for ignored files
		NvimTreeGitDeletedIcon = { link = "Statement" }, -- Purple for deleted files
		NvimTreeGitDirtyIcon = { link = "Statement" }, -- Purple for modified files

		-- Legacy git status groups (cleared as per original spec)
		NvimTreeFolderStaged = {},
		NvimTreeFolderRenamed = {},
		NvimTreeFolderNew = {},
		NvimTreeFolderMerge = {},
		NvimTreeFolderIgnored = {},
		NvimTreeFolderDirty = {},
		NvimTreeFolderDeleted = {},
		NvimTreeFileStaged = {},
		NvimTreeFileRenamed = {},
		NvimTreeFileNew = {},
		NvimTreeFileMerge = {},
		NvimTreeFileIgnored = {},
		NvimTreeFileDirty = {},
		NvimTreeFileDeleted = {},
		NvimTreeGitStaged = {},
		NvimTreeGitRenamed = {},
		NvimTreeGitNew = {},
		NvimTreeGitMerge = {},
		NvimTreeGitIgnored = {},
		NvimTreeGitDeleted = {},
		NvimTreeGitDirty = {},

		-- === FILE STATE INDICATORS ===
		-- Special file states
		NvimTreeOpenedHL = { link = "Special" },
		NvimTreeModifiedIcon = { link = "Type" },
		NvimTreeBookmarkIcon = { link = "NvimTreeFolderIcon" },

		-- File state highlights
		NvimTreeModifiedFileHL = { link = "NvimTreeModifiedIcon" },
		NvimTreeModifiedFolderHL = { link = "NvimTreeModifiedFileHL" },
		NvimTreeBookmarkHL = { link = "SpellLocal" },

		-- Legacy file state groups (cleared as per original spec)
		NvimTreeOpenedFile = {},
		NvimTreeModifiedFile = {},
		NvimTreeBookmark = {},

		-- === HIDDEN FILES ===
		-- Hidden file handling
		NvimTreeHiddenIcon = { link = "Conceal" },
		NvimTreeHiddenFileHL = { link = "NvimTreeHiddenIcon" },
		NvimTreeHiddenFolderHL = { link = "NvimTreeHiddenFileHL" },
		NvimTreeHiddenDisplay = { link = "Conceal" },

		-- === FILTER AND SEARCH ===
		-- Live filter functionality
		NvimTreeLiveFilterPrefix = { link = "PreProc" },
		NvimTreeLiveFilterValue = { link = "ModeMsg" },

		-- === COPY/CUT OPERATIONS ===
		-- Visual feedback for file operations
		NvimTreeCutHL = { link = "SpellBad" },
		NvimTreeCopiedHL = { link = "SpellRare" },
	}
end

---Apply transparency to NvimTree highlight groups
---@param highlights chalk.Highlights NvimTree highlight groups
---@param colors chalk.ColorScheme Color scheme
---@return chalk.Highlights Updated highlights with transparency
local function apply_transparency(highlights, colors)
	-- Groups that should become transparent for NvimTree
	local transparent_groups = {
		"NvimTreeNormal",
		"NvimTreeNormalFloat",
		"NvimTreeNormalNC",
		"NvimTreeSignColumn",
		"NvimTreeEndOfBuffer",
	}

	for _, group in ipairs(transparent_groups) do
		if highlights[group] and highlights[group].bg then
			---@diagnostic disable-next-line: inject-field
			highlights[group].bg = colors.none
		end
	end

	return highlights
end

---Setup NvimTree highlight groups
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights NvimTree highlight groups
function M.setup(colors, opts)
	local highlights = get_base_highlights(colors)

	-- Apply transparency if enabled
	if opts.transparent then
		highlights = apply_transparency(highlights, colors)
	end

	return highlights
end

return M
