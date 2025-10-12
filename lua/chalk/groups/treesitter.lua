-- TreeSitter highlight groups for chalk.nvim
local M = {}

---Setup TreeSitter highlight groups
---@param colors chalk.ColorScheme Color scheme
---@param opts chalk.Config Configuration
---@return chalk.Highlights TreeSitter highlight groups
function M.setup(colors, opts)
	local c = colors

	local highlights = {
		-- Annotations
		["@annotation"] = { fg = c.orange },
		["@annotation.builtin"] = { fg = c.orange },

		-- Attributes
		["@attribute"] = { fg = c.orange },
		["@attribute.builtin"] = { fg = c.orange },

		-- Booleans
		["@boolean"] = { fg = c.mahogany }, -- Distinctive boolean color

		-- Characters
		["@character"] = { fg = c.green },
		["@character.special"] = { fg = c.cyan },

		-- Comments
		["@comment"] = { fg = c.comment, italic = true },
		["@comment.documentation"] = { fg = c.comment, italic = true },
		["@comment.error"] = { fg = c.error, bold = true },
		["@comment.warning"] = { fg = c.warning, bold = true },
		["@comment.todo"] = {
			fg = c.warning,
			bg = c.bg,
			bold = true,
		},
		["@comment.note"] = {
			fg = c.info,
			bg = c.bg,
			bold = true,
		},

		-- Constants - Enhanced Golden Family for Rust
		["@constant"] = { fg = c.bronze }, -- Constants - warm bronze
		["@constant.builtin"] = { fg = c.amber, bold = true }, -- true, false, None
		["@constant.macro"] = { fg = c.copper }, -- Macro-defined constants

		-- Functions - Refined Blue Family for Better Rust Support
		["@function"] = { fg = c.soft_blue }, -- Function definitions - soft blue
		["@function.builtin"] = { fg = c.primary }, -- Builtin functions - prominent
		["@function.call"] = { fg = c.slate_blue }, -- Function calls - muted blue
		["@function.macro"] = { fg = c.purple }, -- Macros - distinctive purple
		["@function.method"] = { fg = c.soft_blue }, -- Methods match functions
		["@function.method.call"] = { fg = c.slate_blue }, -- Method calls muted

		-- Keywords - Refined Purple Family with Better Rust Support
		["@keyword"] = { fg = c.mauve }, -- General keywords (let, mut, if, etc.)
		["@keyword.conditional"] = { fg = c.plum }, -- if, else, match
		["@keyword.conditional.ternary"] = { fg = c.plum },
		["@keyword.coroutine"] = { fg = c.violet, italic = true },
		["@keyword.debug"] = { fg = c.error },
		["@keyword.directive"] = { fg = c.indigo }, -- #[derive], etc.
		["@keyword.directive.define"] = { fg = c.indigo },
		["@keyword.exception"] = { fg = c.burgundy },
		["@keyword.function"] = { fg = c.violet }, -- fn keyword - more prominent
		["@keyword.import"] = { fg = c.navy }, -- use statements - distinct blue
		["@keyword.operator"] = { fg = c.slate_blue },
		["@keyword.repeat"] = { fg = c.plum }, -- for, while, loop
		["@keyword.return"] = { fg = c.crimson }, -- return - prominent red
		["@keyword.storage"] = { fg = c.burgundy }, -- mut, const, static
		["@keyword.type"] = { fg = c.indigo }, -- struct, enum, impl, trait

		-- Labels
		["@label"] = { fg = c.cyan },

		-- Literals
		["@markup"] = { fg = c.fg },
		["@markup.emphasis"] = { italic = true },
		["@markup.environment"] = { fg = c.purple },
		["@markup.environment.name"] = { fg = c.yellow },
		["@markup.heading"] = { fg = c.purple, bold = true },
		["@markup.heading.1"] = { fg = c.purple, bold = true },
		["@markup.heading.2"] = { fg = c.blue, bold = true },
		["@markup.heading.3"] = { fg = c.green, bold = true },
		["@markup.heading.4"] = { fg = c.yellow, bold = true },
		["@markup.heading.5"] = { fg = c.red, bold = true },
		["@markup.heading.6"] = { fg = c.comment, bold = true },
		["@markup.link"] = { fg = c.info, underline = true },
		["@markup.link.label"] = { fg = c.green },
		["@markup.link.url"] = { fg = c.info, underline = true },
		["@markup.list"] = { fg = c.cyan },
		["@markup.list.checked"] = { fg = c.success },
		["@markup.list.unchecked"] = { fg = c.comment },
		["@markup.math"] = { fg = c.cyan },
		["@markup.quote"] = { fg = c.comment, italic = true },
		["@markup.raw"] = { fg = c.green },
		["@markup.raw.block"] = { fg = c.green },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.strong"] = { bold = true },
		["@markup.underline"] = { underline = true },

		-- Math
		["@math"] = { fg = c.cyan },

		-- Modules - Enhanced for Rust Module System
		["@module"] = { fg = c.slate_blue }, -- Module references (std::io)
		["@module.builtin"] = { fg = c.teal_gray, bold = true }, -- Built-in modules
		
		-- Namespace support
		["@namespace"] = { fg = c.slate_blue }, -- Namespace references

		-- Numbers - Enhanced Orange Family
		["@number"] = { fg = c.orange }, -- Integer numbers - clear orange
		["@number.float"] = { fg = c.burnt_orange }, -- Float numbers - muted

		-- Operators
		["@operator"] = { fg = c.pewter }, -- Neutral operator color

		-- Parameters - Enhanced for Function Signatures
		["@parameter"] = { fg = c.terracotta }, -- Function parameters
		["@parameter.builtin"] = { fg = c.rust, italic = true }, -- Built-in parameters
		["@parameter.reference"] = { fg = c.indian_red }, -- Parameter references

		-- Properties - Enhanced for Rust Fields
		["@property"] = { fg = c.dusty_rose }, -- Struct fields, object properties

		-- Punctuation - Subtle Gray Family
		["@punctuation.bracket"] = { fg = c.steel }, -- Structural elements
		["@punctuation.delimiter"] = { fg = c.stone }, -- Delimiters slightly different
		["@punctuation.special"] = { fg = c.slate }, -- Special punctuation

		-- Strings - Natural Green Family
		["@string"] = { fg = c.sage_green }, -- Main string color
		["@string.documentation"] = { fg = c.comment, italic = true },
		["@string.escape"] = { fg = c.moss }, -- Escape sequences
		["@string.regex"] = { fg = c.forest }, -- Regex patterns
		["@string.special"] = { fg = c.emerald }, -- Special strings
		["@string.special.path"] = { fg = c.pine, underline = true }, -- File paths
		["@string.special.symbol"] = { fg = c.olive }, -- Symbols
		["@string.special.url"] = { fg = c.info, underline = true },

		-- Tags (HTML/XML)
		["@tag"] = { fg = c.purple },
		["@tag.attribute"] = { fg = c.orange },
		["@tag.delimiter"] = { fg = c.light_gray },

		-- Types - Enhanced Golden Family for Better Rust Support
		["@type"] = { fg = c.honey }, -- Struct names, user-defined types
		["@type.builtin"] = { fg = c.amber, bold = true }, -- Primitive types (i32, String, etc.)
		["@type.definition"] = { fg = c.honey, bold = true }, -- Type definitions
		["@type.qualifier"] = { fg = c.bronze }, -- Type qualifiers (&, mut, etc.)

		-- Variables - Refined Earth Tones for Better Rust Support
		["@variable"] = { fg = c.fg }, -- Regular variables - clean foreground
		["@variable.builtin"] = { fg = c.rust, italic = true }, -- self, super, crate
		["@variable.member"] = { fg = c.dusty_rose }, -- Struct fields - soft rose
		["@variable.parameter"] = { fg = c.terracotta }, -- Function parameters - earthy

		-- Language-specific overrides
		-- Lua
		["@constructor"] = { fg = c.amber },
		["@constructor.lua"] = { fg = c.steel },
		["@function.call.lua"] = { fg = c.slate_blue },
		["@keyword.function.lua"] = { fg = c.violet },
		["@keyword.operator.lua"] = { fg = c.slate_blue },
		["@punctuation.bracket.lua"] = { fg = c.steel },
		["@punctuation.delimiter.lua"] = { fg = c.stone },
		["@variable.builtin.lua"] = { fg = c.rust },

		-- Python
		["@attribute.python"] = { fg = c.orange },
		["@constructor.python"] = { fg = c.yellow },
		["@function.builtin.python"] = { fg = c.cyan },
		["@keyword.operator.python"] = { fg = c.purple },
		["@parameter.python"] = { fg = c.red },
		["@punctuation.special.python"] = { fg = c.purple },
		["@type.builtin.python"] = { fg = c.yellow },
		["@variable.builtin.python"] = { fg = c.purple },

		-- JavaScript/TypeScript
		["@constructor.javascript"] = { fg = c.yellow },
		["@constructor.typescript"] = { fg = c.yellow },
		["@function.method.javascript"] = { fg = c.blue },
		["@function.method.typescript"] = { fg = c.blue },
		["@keyword.export.javascript"] = { fg = c.purple },
		["@keyword.export.typescript"] = { fg = c.purple },
		["@keyword.import.javascript"] = { fg = c.purple },
		["@keyword.import.typescript"] = { fg = c.purple },
		["@property.javascript"] = { fg = c.red },
		["@property.typescript"] = { fg = c.red },
		["@punctuation.bracket.javascript"] = { fg = c.light_gray },
		["@punctuation.bracket.typescript"] = { fg = c.light_gray },
		["@variable.builtin.javascript"] = { fg = c.purple },
		["@variable.builtin.typescript"] = { fg = c.purple },

		-- CSS
		["@property.css"] = { fg = c.red },
		["@string.css"] = { fg = c.green },
		["@type.css"] = { fg = c.yellow },
		["@function.css"] = { fg = c.blue },
		["@number.css"] = { fg = c.orange },
		["@keyword.css"] = { fg = c.purple },
		["@punctuation.delimiter.css"] = { fg = c.light_gray },

		-- JSON
		["@label.json"] = { fg = c.purple },
		["@string.json"] = { fg = c.green },
		["@number.json"] = { fg = c.orange },
		["@boolean.json"] = { fg = c.orange },
		["@constant.json"] = { fg = c.yellow },

		-- YAML
		["@field.yaml"] = { fg = c.purple },
		["@string.yaml"] = { fg = c.green },
		["@number.yaml"] = { fg = c.orange },
		["@boolean.yaml"] = { fg = c.orange },
		["@constant.yaml"] = { fg = c.yellow },
		["@punctuation.delimiter.yaml"] = { fg = c.light_gray },

		-- HTML
		["@tag.html"] = { fg = c.purple },
		["@tag.attribute.html"] = { fg = c.orange },
		["@tag.delimiter.html"] = { fg = c.light_gray },
		["@string.html"] = { fg = c.green },

		-- XML
		["@tag.xml"] = { fg = c.purple },
		["@tag.attribute.xml"] = { fg = c.orange },
		["@tag.delimiter.xml"] = { fg = c.light_gray },
		["@string.xml"] = { fg = c.green },

		-- Markdown
		["@markup.heading.1.markdown"] = { fg = c.purple, bold = true },
		["@markup.heading.2.markdown"] = { fg = c.blue, bold = true },
		["@markup.heading.3.markdown"] = { fg = c.green, bold = true },
		["@markup.heading.4.markdown"] = { fg = c.yellow, bold = true },
		["@markup.heading.5.markdown"] = { fg = c.red, bold = true },
		["@markup.heading.6.markdown"] = { fg = c.comment, bold = true },
		["@markup.link.markdown"] = { fg = c.info, underline = true },
		["@markup.link.label.markdown"] = { fg = c.green },
		["@markup.link.url.markdown"] = { fg = c.info, underline = true },
		["@markup.raw.markdown"] = { fg = c.green },
		["@markup.raw.block.markdown"] = { fg = c.green },
		["@markup.list.markdown"] = { fg = c.cyan },
		["@markup.emphasis.markdown"] = { italic = true },
		["@markup.strong.markdown"] = { bold = true },
		["@markup.strikethrough.markdown"] = { strikethrough = true },
		["@markup.quote.markdown"] = { fg = c.comment, italic = true },

		-- C/C++
		["@constant.macro.c"] = { fg = c.copper },
		["@constant.macro.cpp"] = { fg = c.copper },
		["@function.builtin.c"] = { fg = c.teal_gray },
		["@function.builtin.cpp"] = { fg = c.teal_gray },
		["@keyword.directive.c"] = { fg = c.indigo },
		["@keyword.directive.cpp"] = { fg = c.indigo },
		["@type.builtin.c"] = { fg = c.honey },
		["@type.builtin.cpp"] = { fg = c.honey },

		-- Go
		["@function.builtin.go"] = { fg = c.cyan },
		["@keyword.function.go"] = { fg = c.purple },
		["@keyword.import.go"] = { fg = c.purple },
		["@type.builtin.go"] = { fg = c.yellow },
		["@variable.builtin.go"] = { fg = c.purple },

		-- Rust - Enhanced for Better TreeSitter Support
		["@attribute.rust"] = { fg = c.orange }, -- #[derive], #[cfg], etc.
		["@function.builtin.rust"] = { fg = c.primary }, -- println!, vec!, etc.
		["@function.macro.rust"] = { fg = c.purple }, -- Macro definitions
		["@keyword.storage.rust"] = { fg = c.burgundy }, -- mut, const, static
		["@keyword.function.rust"] = { fg = c.violet }, -- fn keyword
		["@keyword.import.rust"] = { fg = c.navy }, -- use statements
		["@keyword.type.rust"] = { fg = c.indigo }, -- struct, enum, impl, trait
		["@type.builtin.rust"] = { fg = c.amber }, -- i32, String, Vec, etc.
		["@variable.builtin.rust"] = { fg = c.rust }, -- self, super, crate
		["@variable.member.rust"] = { fg = c.dusty_rose }, -- Struct field access
		["@module.rust"] = { fg = c.slate_blue }, -- Module references (std::io)
		["@namespace.rust"] = { fg = c.slate_blue }, -- Namespace references

		-- Java
		["@constant.java"] = { fg = c.yellow },
		["@function.builtin.java"] = { fg = c.cyan },
		["@keyword.import.java"] = { fg = c.purple },
		["@type.builtin.java"] = { fg = c.yellow },
		["@variable.builtin.java"] = { fg = c.purple },

		-- PHP
		["@function.builtin.php"] = { fg = c.cyan },
		["@keyword.operator.php"] = { fg = c.purple },
		["@variable.builtin.php"] = { fg = c.red },

		-- Ruby
		["@function.builtin.ruby"] = { fg = c.cyan },
		["@keyword.function.ruby"] = { fg = c.purple },
		["@symbol.ruby"] = { fg = c.yellow },
		["@variable.builtin.ruby"] = { fg = c.purple },

		-- Shell/Bash
		["@function.builtin.bash"] = { fg = c.cyan },
		["@keyword.function.bash"] = { fg = c.purple },
		["@parameter.bash"] = { fg = c.red },
		["@punctuation.special.bash"] = { fg = c.cyan },
		["@variable.builtin.bash"] = { fg = c.red },

		-- Vim
		["@function.builtin.vim"] = { fg = c.cyan },
		["@keyword.function.vim"] = { fg = c.purple },
		["@variable.builtin.vim"] = { fg = c.red },

		-- SQL
		["@function.builtin.sql"] = { fg = c.cyan },
		["@keyword.sql"] = { fg = c.purple },
		["@type.builtin.sql"] = { fg = c.yellow },

		-- Docker
		["@keyword.dockerfile"] = { fg = c.purple },
		["@string.dockerfile"] = { fg = c.green },

		-- TOML
		["@property.toml"] = { fg = c.purple },
		["@string.toml"] = { fg = c.green },

		-- Git
		["@keyword.gitcommit"] = { fg = c.purple },
		["@string.gitcommit"] = { fg = c.green },

		-- Diff
		["@text.diff.add"] = { fg = c.git_add },
		["@text.diff.delete"] = { fg = c.git_delete },

		-- Additional semantic tokens (disabled to prevent TreeSitter interference)
		["@lsp.type.class"] = {},
		["@lsp.type.decorator"] = {},
		["@lsp.type.enum"] = {},
		["@lsp.type.enumMember"] = {},
		["@lsp.type.function"] = {},
		["@lsp.type.interface"] = {},
		["@lsp.type.macro"] = {},
		["@lsp.type.method"] = {},
		["@lsp.type.namespace"] = {},
		["@lsp.type.parameter"] = {},
		["@lsp.type.property"] = {},
		["@lsp.type.struct"] = {},
		["@lsp.type.type"] = {},
		["@lsp.type.typeParameter"] = {},
		["@lsp.type.variable"] = {},

		-- LSP semantic token modifiers (disabled to prevent TreeSitter interference)
		["@lsp.mod.deprecated"] = {},
		["@lsp.mod.readonly"] = {},
		["@lsp.mod.static"] = {},

		-- Legacy TreeSitter groups (for compatibility)
		TSAnnotation = { link = "@annotation" },
		TSAttribute = { link = "@attribute" },
		TSBoolean = { link = "@boolean" },
		TSCharacter = { link = "@character" },
		TSComment = { link = "@comment" },
		TSConditional = { link = "@keyword.conditional" },
		TSConstant = { link = "@constant" },
		TSConstBuiltin = { link = "@constant.builtin" },
		TSConstMacro = { link = "@constant.macro" },
		TSConstructor = { link = "@constructor" },
		TSError = { fg = c.error },
		TSException = { link = "@keyword.exception" },
		TSField = { link = "@property" },
		TSFloat = { link = "@number.float" },
		TSFunction = { link = "@function" },
		TSFuncBuiltin = { link = "@function.builtin" },
		TSFuncMacro = { link = "@function.macro" },
		TSInclude = { link = "@keyword.import" },
		TSKeyword = { link = "@keyword" },
		TSKeywordFunction = { link = "@keyword.function" },
		TSKeywordOperator = { link = "@keyword.operator" },
		TSKeywordReturn = { link = "@keyword.return" },
		TSLabel = { link = "@label" },
		TSMethod = { link = "@function.method" },
		TSNamespace = { link = "@module" },
		TSNumber = { link = "@number" },
		TSOperator = { link = "@operator" },
		TSParameter = { link = "@parameter" },
		TSParameterReference = { link = "@parameter.reference" },
		TSProperty = { link = "@property" },
		TSPunctDelimiter = { link = "@punctuation.delimiter" },
		TSPunctBracket = { link = "@punctuation.bracket" },
		TSPunctSpecial = { link = "@punctuation.special" },
		TSRepeat = { link = "@keyword.repeat" },
		TSString = { link = "@string" },
		TSStringRegex = { link = "@string.regex" },
		TSStringEscape = { link = "@string.escape" },
		TSStringSpecial = { link = "@string.special" },
		TSSymbol = { link = "@string.special.symbol" },
		TSTag = { link = "@tag" },
		TSTagAttribute = { link = "@tag.attribute" },
		TSTagDelimiter = { link = "@tag.delimiter" },
		TSText = { link = "@markup" },
		TSEmphasis = { link = "@markup.emphasis" },
		TSUnderline = { link = "@markup.underline" },
		TSStrike = { link = "@markup.strikethrough" },
		TSTitle = { link = "@markup.heading" },
		TSLiteral = { link = "@markup.raw" },
		TSURI = { link = "@markup.link.url" },
		TSMath = { link = "@markup.math" },
		TSTextReference = { link = "@markup.link" },
		TSEnvironment = { link = "@markup.environment" },
		TSEnvironmentName = { link = "@markup.environment.name" },
		TSNote = { link = "@comment.note" },
		TSWarning = { link = "@comment.warning" },
		TSDanger = { link = "@comment.error" },
		TSTodo = { link = "@comment.todo" },
		TSType = { link = "@type" },
		TSTypeBuiltin = { link = "@type.builtin" },
		TSTypeQualifier = { link = "@type.qualifier" },
		TSTypeDefinition = { link = "@type.definition" },
		TSVariable = { link = "@variable" },
		TSVariableBuiltin = { link = "@variable.builtin" },
	}

	return highlights
end

return M
