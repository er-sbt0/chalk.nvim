-- Default dark theme variant for chalk.nvim
-- Warm, earthy chalk colors on dark chalkboard backgrounds

---@type chalk.Palette
return {
	-- Background colors (dark slate/chalkboard tones)
	bg_darker = "#0e1419", -- Deepest background
	bg_dark = "#1a1f24", -- Dark background
	bg = "#1e2328", -- Main background (chalkboard)
	bg_light = "#2a2f35", -- Light background
	bg_lighter = "#363c42", -- Lightest background

	-- Foreground colors (chalk white/cream tones)
	fg_darker = "#8a9199", -- Darkest foreground
	fg = "#c9c7cd", -- Main foreground (chalk white)
	fg_light = "#e6e4ea", -- Light foreground

	-- Primary colors (chalk blues and teals)
	primary = "#73b3e7", -- Soft chalk blue
	secondary = "#7fc8db", -- Chalk teal
	accent = "#8ed1c7", -- Mint chalk

	-- Status colors (vivid but not harsh)
	error = "#e06c75", -- Soft red chalk
	warning = "#e5c07b", -- Yellow chalk
	info = "#61afef", -- Info blue
	hint = "#56b6c2", -- Hint cyan
	success = "#98c379", -- Green chalk

	-- Semantic colors (warm, muted tones)
	purple = "#c678dd", -- Purple chalk
	blue = "#61afef", -- Blue chalk
	red = "#e06c75", -- Red chalk
	green = "#98c379", -- Green chalk
	orange = "#d19a66", -- Orange chalk
	yellow = "#e5c07b", -- Yellow chalk
	comment = "#5c6370", -- Muted comment
	cyan = "#56b6c2", -- Cyan chalk
	light_gray = "#abb2bf", -- Light punctuation

	-- Light colors (soft pastel chalk shades)
	light_coral = "#f0c5c2", -- Light coral chalk
	pastel = "#f0e1c2", -- Light cream chalk (fixed typo)
	menta = "#e8f2bd", -- Light mint chalk
	lavender = "#e6d7ff", -- Light purple chalk
	sky = "#d4e9ff", -- Light blue chalk
	peach = "#ffd4c2", -- Light orange chalk
	lemon = "#fff2c2", -- Light yellow chalk
	sage = "#d4f2c2", -- Light green chalk
	coral = "#ffc2d4", -- Light red chalk
	aqua = "#c2f2ff", -- Light cyan chalk
	cream = "#f5f1e8", -- Light cream base
	ivory = "#faf8f0", -- Light ivory
	powder = "#e8f0ff", -- Light powder blue
	blush = "#ffe8f0", -- Light blush pink
	pearl = "#f0f8ff", -- Light pearl
	vanilla = "#fff8e1", -- Light vanilla
	seafoam = "#e1fff8", -- Light seafoam

	-- Refined colors (sophisticated muted tones)
	indian_red = "#c28a82", -- Muted red-brown
	amber = "#d9a67c", -- Warm amber
	dusty_rose = "#c7969a", -- Muted rose
	sage_green = "#9fb39b", -- Muted green
	slate_blue = "#8491a3", -- Muted blue-gray
	mauve = "#b695a8", -- Dusty purple
	burnt_orange = "#cc8f65", -- Muted orange
	olive = "#a3a068", -- Muted yellow-green
	pewter = "#a59b9b", -- Gray with warmth
	terracotta = "#c19177", -- Earthy red-brown
	bronze = "#b5956b", -- Metallic brown
	teal_gray = "#7a9b9b", -- Muted teal
	plum = "#a387a3", -- Deep muted purple
	rust = "#b8775e", -- Oxidized orange-red
	moss = "#8fa085", -- Deep muted green
	steel = "#8a9199", -- Cool gray
	sand = "#c4b59a", -- Warm beige
	stone = "#9c9691", -- Natural gray

	-- Deeper colors (sharpened rich tones)
	honey = "#cc8f44", -- Sharp deep golden brown
	mahogany = "#a85533", -- Sharp deep red-brown
	forest = "#447733", -- Sharp deep forest green
	navy = "#335588", -- Sharp deep navy blue
	burgundy = "#aa4444", -- Sharp deep wine red
	chocolate = "#884422", -- Sharp deep brown
	indigo = "#554488", -- Sharp deep purple-blue
	emerald = "#228855", -- Sharp deep green
	crimson = "#882222", -- Sharp deep red
	copper = "#bb5522", -- Sharp deep orange-brown
	violet = "#662288", -- Sharp deep purple
	charcoal = "#444444", -- Sharp deep gray
	midnight = "#223355", -- Sharp deep blue-black
	espresso = "#553322", -- Sharp deep coffee brown
	pine = "#335522", -- Sharp deep pine green
	slate = "#445566", -- Sharp deep slate
	maroon = "#661122", -- Sharp deep maroon
	obsidian = "#222244", -- Sharp deep black-blue
	soft_blue = "#82a2d3", -- Soft periwinkle blue
	lavender_mist = "#a799cc", -- Soft lavender purple
	warm_gold = "#d8a67d", -- Warm golden tan

	-- Git colors
	git_add = "#98c379", -- Git add green
	git_change = "#e5c07b", -- Git change yellow
	git_delete = "#e06c75", -- Git delete red
	git_text = "#61afef", -- Git text blue

	-- Diff colors
	diff_add = "#98c379", -- Diff add
	diff_delete = "#e06c75", -- Diff delete
	diff_change = "#e5c07b", -- Diff change
	diff_text = "#61afef", -- Diff text

	-- Selection and UI colors
	selection = "#3e4451", -- Selection background
	search = "#e5c07b", -- Search highlight
	match = "#c678dd", -- Matching bracket
	cursor = "#528bff", -- Cursor blue
	cursor_line = "#2c323c", -- Cursor line
	line_number = "#4b5263", -- Line numbers
	line_number_current = "#abb2bf", -- Current line number

	-- Menu and completion colors
	menu_bg = "#21252b", -- Menu background
	menu_sel = "#2c323c", -- Menu selection
	menu_border = "#4b5263", -- Menu border

	-- Float and popup colors
	float_bg = "#21252b", -- Float background
	float_border = "#4b5263", -- Float border

	-- Diagnostic colors
	diagnostic_error = "#e06c75", -- Diagnostic error
	diagnostic_warning = "#e5c07b", -- Diagnostic warning
	diagnostic_info = "#61afef", -- Diagnostic info
	diagnostic_hint = "#56b6c2", -- Diagnostic hint
}
