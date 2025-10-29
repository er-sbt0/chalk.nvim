---@type chalk.Palette
return {
	-- ============================================================================
	-- BACKGROUND & FOREGROUND
	-- ============================================================================
	bg_1 = "#959dbd", -- Lightest background
	bg_2 = "#7d84a1", -- Light background
	bg_3 = "#697088", -- Medium background
	bg_4 = "#565c6f", -- Dark background
	bg_5 = "#424856", -- Darkest background

	fg_darker = "#424140", -- Darkest foreground - improved contrast
	fg_light = "#f0ebe4", -- Light foreground - crisp sophisticated chalk
	fg = "#b3b0ac", -- Main foreground - refined chalk white

	-- ============================================================================
	-- REDS
	-- ============================================================================
	crimson = "#ff5d62", -- Light crimson - bright red glow
	ruby = "#ff757f", -- Light ruby - gentle red glow
	cherry = "#ec6788", -- Light cherry - bright pink glow
	rose = "#eb6f92", -- Base rose - sophisticated warm red

	-- ============================================================================
	-- PINKS
	-- ============================================================================
	pink = "#fcade2", -- Light pink - gentle cotton candy
	coral = "#c4746e", -- Base coral - sophisticated warm pink-orange
	peach = "#c56e6e", -- Dark peach - rich coral depth

	-- ============================================================================
	-- ORANGES
	-- ============================================================================
	copper = "#e7b493", -- Light copper - soft metal glow
	orange = "#fda751", -- Light peach - gentle citrus glow
	tangerine = "#f6c177", -- Light tangerine - bright citrus glow

	-- ============================================================================
	-- YELLOWS
	-- ============================================================================
	yellow = "#ffd8ab", -- Light yellow - bright sunshine
	amber = "#f9d791", -- Light champagne - soft golden glow
	gold = "#f2ecbc", -- Light gold - gentle metallic glow

	-- ============================================================================
	-- GREENS
	-- ============================================================================
	lime = "#c3e88d", -- Light lime - fresh bright green
	emerald = "#b7d0ae", -- Light sage mist - gentle natural
	sage = "#cfdac6", -- Light sage - airy herbal tint

	-- ============================================================================
	-- CYANS/TEALS
	-- ============================================================================
	turquoise = "#93dddc", -- Base turquoise - vibrant ocean sophistication
	seafoam = "#A3D4D5", -- Light seafoam - gentle ocean mist
	teal = "#b8ebe6", -- Light aqua foam - gentle teal
	cyan = "#86e1fc", -- Light cyan - bright electric blue

	-- ============================================================================
	-- BLUES
	-- ============================================================================
	azure = "#92c2dd", -- Light powder blue - gentle sky
	steel_blue = "#76bbc9", -- Base steel blue - enhanced visibility
	ocean_blue = "#5aa8b5", -- Medium ocean - balanced blue depth
	royal = "#8fd0fc", -- Light royal - bright sky blue
	indigo = "#89a5e6", -- Base indigo - sophisticated deep blue
	periwinkle = "#89a5e6", -- Periwinkle blue - soft blue-violet

	-- ============================================================================
	-- PURPLES/VIOLETS
	-- ============================================================================
	violet = "#c7a9ff", -- Light violet - gentle purple glow
	amethyst = "#b97898", -- Light amethyst - bright purple glow
	mauve_light = "#f0c0f0", -- Light mauve mist - gentle purple-gray
	mauve = "#c4a4c4", -- Base mauve - sophisticated purple-gray
	mauve_medium = "#b394b3", -- Medium mauve - balanced purple depth
	mauve_dark = "#a284a2", -- Dark mauve - rich purple-gray

	-- ============================================================================
	-- NEUTRALS/BROWNS/GRAYS
	-- ============================================================================
	bronze = "#d6c0a5", -- Light bronze - gentle metallic beige
	earth = "#cdb49e", -- Light clay soil - soft warm tan
	clay = "#d9b4a3", -- Light clay - soft rosy tan
	cream = "#cbbca4", -- Darkest cream - warm muted sand
	taupe = "#cfc6be", -- Light taupe - soft warm gray
	slate = "#8ea4a2", -- Light slate - balanced neutral
	stone_1 = "#b3b8d1", -- Light stone - cool elegance
	stone_2 = "#9ca2bd", -- Base cool stone - sophisticated cool
	stone_3 = "#74798f", -- Medium pewter - balanced stone depth
	stone_4 = "#545c7e", -- Dark pewter - refined cool depth
	powder = "#c6d1db", -- Light powder - gentle dusty blue
	shadow = "#c4c7d4", -- Light shadow - misted cool gray
	mist = "#e8ecf1", -- Light mist - airy cool veil
	ash = "#a6a69c", -- Ash gray - neutral warm gray

	-- ============================================================================
	-- SEMANTIC COLORS
	-- ============================================================================
	purple = "#9d7cd8", -- Base violet - sophisticated purple
	blue = "#7E9CD8", -- Base indigo - better visibility
	red = "#E46876", -- Base ruby - elegant red
	green = "#9ece6a", -- Base emerald - sophisticated green
	orange = "#FF9E3B", -- Base orange - refined orange
	yellow = "#f6c177", -- Base yellow - sophisticated gold
	cyan = "#73daca", -- Base turquoise - elegant cyan
	comment = "#8087a9", -- Enhanced stone - better comment visibility

	-- ============================================================================
	-- PRIMARY COLORS
	-- ============================================================================
	primary = "#7E9CD8", -- Base indigo - sophisticated primary
	secondary = "#6CAF95", -- Base seafoam - elegant secondary
	accent = "#9ece6a", -- Base emerald - refined accent

	-- ============================================================================
	-- STATUS COLORS
	-- ============================================================================
	error = "#E46876", -- Base ruby - sophisticated error
	warning = "#DCA561", -- Base amber - elegant warning
	info = "#7E9CD8", -- Base indigo - sophisticated info
	hint = "#6CAF95", -- Base seafoam - elegant hints
	success = "#9ece6a", -- Base emerald - refined success

	-- ============================================================================
	-- DIAGNOSTIC COLORS
	-- ============================================================================
	diagnostic_error = "#E46876", -- Base ruby - refined error indication
	diagnostic_warning = "#DCA561", -- Base amber - sophisticated warning
	diagnostic_info = "#7E9CD8", -- Base indigo - elegant information
	diagnostic_hint = "#6CAF95", -- Base seafoam - sophisticated hints

	-- ============================================================================
	-- GIT COLORS
	-- ============================================================================
	git_add = "#b7d0ae", -- Light emerald - sophisticated addition
	git_change = "#f6c177", -- Base yellow - elegant modification
	git_delete = "#ff757f", -- Light ruby - refined deletion
	git_text = "#65bcff", -- Base royal - sophisticated text changes

	-- ============================================================================
	-- DIFF COLORS
	-- ============================================================================
	diff_add = "#97ca95", -- Medium emerald - sophisticated addition
	diff_delete = "#ff899d", -- Light rose - refined deletion
	diff_change = "#f9d791", -- Light amber - elegant modification
	diff_text = "#4f7ab6", -- Medium royal - sophisticated text
	diff_add_bg = "#488154", -- Subtle green background for additions
	diff_change_bg = "#cc9364", -- Standard git diff change background
	diff_delete_bg = "#ad6069", -- Subtle red background for deletions
	diff_text_bg = "#444d5e", -- Subtle blue background for text changes

	-- ============================================================================
	-- UI COLORS
	-- ============================================================================
	selection = "#464b5f", -- Warm sophisticated selection
	search = "#f9d791", -- Light amber - elegant search highlight
	match = "#9d7cd8", -- Base violet - sophisticated matching
	cursor = "#65bcff", -- Base royal - better cursor visibility
	cursor_line = "#332f2b", -- Elegant warm cursor line
	line_number = "#8087a9", -- Enhanced stone - better line number visibility
	line_number_current = "#b3b8d1", -- Light stone - current line emphasis

	-- ============================================================================
	-- SPECIAL COLORS
	-- ============================================================================
	pure_white = "#ffffff",
	pure_black = "#000000",
	transparent = "NONE",
}
