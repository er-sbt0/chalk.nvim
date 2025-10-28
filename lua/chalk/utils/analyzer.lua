-- Analysis and debugging utilities for chalk.nvim
-- Consolidated highlight analysis tools

local M = {}

---Notify with consistent formatting
---@param message string Message to display
---@param level? number Log level (default: INFO)
local function notify(message, level)
	level = level or vim.log.levels.INFO
	vim.notify(string.format("[Analyzer] %s", message), level)
end

---Format a numeric color value to hex string
---@param n number The numeric color value
---@return string The hex color string (e.g., "#ff0000")
local function format_color(n)
	return string.format("#%06x", n)
end

---List all highlight groups that have non-transparent backgrounds
---Useful for debugging transparency issues in colorschemes
function M.list_non_transparent()
	local groups = vim.fn.getcompletion("", "highlight")
	local rows = {}

	for _, group_name in ipairs(groups) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
		if ok and hl and hl.bg and type(hl.bg) == "number" then
			table.insert(rows, { group_name, format_color(hl.bg) })
		end
	end

	-- Sort alphabetically by group name
	table.sort(rows, function(a, b)
		return a[1] < b[1]
	end)

	-- Print results
	print(string.rep("-", 60))
	print(string.format("%-35s %s", "Highlight Group", "Background Color"))
	print(string.rep("-", 60))

	for _, row in ipairs(rows) do
		print(string.format("%-35s %s", row[1], row[2]))
	end

	print(string.rep("-", 60))
	print(string.format("Found %d highlight groups with background colors", #rows))
	print("Hint: :verbose hi <Group> to see where it was set.")

	return rows
end

---Get highlight groups with background colors as a table (for programmatic use)
---@return table Array of {group_name, hex_color} pairs
function M.get_non_transparent()
	local groups = vim.fn.getcompletion("", "highlight")
	local results = {}

	for _, group_name in ipairs(groups) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
		if ok and hl and hl.bg and type(hl.bg) == "number" then
			table.insert(results, { group_name, format_color(hl.bg) })
		end
	end

	table.sort(results, function(a, b)
		return a[1] < b[1]
	end)
	return results
end

---Analyze all current highlight groups and show statistics
function M.analyze_highlights()
	local groups = vim.fn.getcompletion("", "highlight")
	local stats = {
		total = 0,
		with_fg = 0,
		with_bg = 0,
		with_both = 0,
		links = 0,
		transparent = 0,
	}

	local color_usage = {}

	for _, group_name in ipairs(groups) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
		if ok and hl then
			stats.total = stats.total + 1

			if hl.link then
				stats.links = stats.links + 1
			else
				local has_fg = hl.fg and type(hl.fg) == "number"
				local has_bg = hl.bg and type(hl.bg) == "number"

				if has_fg then
					stats.with_fg = stats.with_fg + 1
					local fg_color = format_color(hl.fg)
					color_usage[fg_color] = (color_usage[fg_color] or 0) + 1
				end

				if has_bg then
					stats.with_bg = stats.with_bg + 1
					local bg_color = format_color(hl.bg)
					color_usage[bg_color] = (color_usage[bg_color] or 0) + 1
				end

				if has_fg and has_bg then
					stats.with_both = stats.with_both + 1
				end

				if not has_bg then
					stats.transparent = stats.transparent + 1
				end
			end
		end
	end

	-- Show statistics
	print("Highlight Group Analysis")
	print(string.rep("=", 40))
	print(string.format("Total groups: %d", stats.total))
	print(string.format("With foreground: %d", stats.with_fg))
	print(string.format("With background: %d", stats.with_bg))
	print(string.format("With both: %d", stats.with_both))
	print(string.format("Transparent: %d", stats.transparent))
	print(string.format("Links: %d", stats.links))

	-- Show most used colors
	local sorted_colors = {}
	for color, count in pairs(color_usage) do
		table.insert(sorted_colors, { color, count })
	end

	table.sort(sorted_colors, function(a, b)
		return a[2] > b[2]
	end)

	print("\nMost Used Colors:")
	print(string.rep("-", 30))
	for i = 1, math.min(10, #sorted_colors) do
		local color, count = sorted_colors[i][1], sorted_colors[i][2]
		print(string.format("%-10s used %d times", color, count))
	end

	return stats
end

---Find highlight groups that use a specific color
---@param target_color string Hex color to search for (e.g., "#ff0000")
---@param search_bg? boolean Whether to search background colors (default: false, searches fg)
function M.find_groups_with_color(target_color, search_bg)
	target_color = target_color:lower()
	local groups = vim.fn.getcompletion("", "highlight")
	local matches = {}

	for _, group_name in ipairs(groups) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
		if ok and hl then
			local color_field = search_bg and hl.bg or hl.fg
			if color_field and type(color_field) == "number" then
				local hex_color = format_color(color_field):lower()
				if hex_color == target_color then
					table.insert(matches, group_name)
				end
			end
		end
	end

	local color_type = search_bg and "background" or "foreground"
	print(string.format("Highlight groups with %s color %s:", color_type, target_color))
	print(string.rep("-", 50))

	if #matches == 0 then
		print("No matches found")
	else
		for _, group in ipairs(matches) do
			print(group)
		end
		print(string.format("\nTotal: %d groups", #matches))
	end

	return matches
end

---Show detailed information about a specific highlight group
---@param group_name string Highlight group name
function M.inspect_group(group_name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name })
	if not ok then
		notify(string.format("Highlight group '%s' not found", group_name), vim.log.levels.ERROR)
		return
	end

	print(string.format("Highlight Group: %s", group_name))
	print(string.rep("=", 30))

	if hl.link then
		print(string.format("Links to: %s", hl.link))
		-- Recursively show the linked group
		return M.inspect_group(hl.link)
	end

	local attributes = {}
	if hl.fg then
		table.insert(attributes, string.format("fg=%s", format_color(hl.fg)))
	end
	if hl.bg then
		table.insert(attributes, string.format("bg=%s", format_color(hl.bg)))
	end
	if hl.sp then
		table.insert(attributes, string.format("sp=%s", format_color(hl.sp)))
	end
	if hl.bold then
		table.insert(attributes, "bold")
	end
	if hl.italic then
		table.insert(attributes, "italic")
	end
	if hl.underline then
		table.insert(attributes, "underline")
	end
	if hl.undercurl then
		table.insert(attributes, "undercurl")
	end
	if hl.underdouble then
		table.insert(attributes, "underdouble")
	end
	if hl.underdotted then
		table.insert(attributes, "underdotted")
	end
	if hl.underdashed then
		table.insert(attributes, "underdashed")
	end
	if hl.strikethrough then
		table.insert(attributes, "strikethrough")
	end
	if hl.reverse then
		table.insert(attributes, "reverse")
	end
	if hl.standout then
		table.insert(attributes, "standout")
	end

	if #attributes > 0 then
		print("Attributes: " .. table.concat(attributes, ", "))
	else
		print("No attributes set")
	end

	-- Show where it was defined (if possible)
	local verbose_info = vim.fn.execute("verbose hi " .. group_name)
	local lines = vim.split(verbose_info, "\n")
	for _, line in ipairs(lines) do
		if line:match("Last set from") then
			print(line)
			break
		end
	end
end

---Setup analyzer commands
function M.setup_commands()
	local commands = {
		ChalkAnalyzeHighlights = {
			callback = M.analyze_highlights,
			opts = { desc = "Analyze all highlight groups and show statistics" },
		},
		ChalkListNonTransparent = {
			callback = M.list_non_transparent,
			opts = { desc = "List all highlight groups with background colors" },
		},
		ChalkFindColor = {
			callback = function(opts)
				local args = vim.split(opts.args or "", "%s+")
				if #args == 0 then
					notify("Usage: ChalkFindColor <hex_color> [bg]", vim.log.levels.ERROR)
					return
				end
				local color = args[1]
				local search_bg = args[2] == "bg"
				M.find_groups_with_color(color, search_bg)
			end,
			opts = {
				desc = "Find highlight groups using a specific color",
				nargs = "+",
				complete = function()
					return { "#ff0000", "#00ff00", "#0000ff", "bg" }
				end,
			},
		},
		ChalkInspectGroup = {
			callback = function(opts)
				if not opts.args or opts.args == "" then
					notify("Usage: ChalkInspectGroup <group_name>", vim.log.levels.ERROR)
					return
				end
				M.inspect_group(opts.args)
			end,
			opts = {
				desc = "Inspect a specific highlight group",
				nargs = 1,
				complete = function()
					return vim.fn.getcompletion("", "highlight")
				end,
			},
		},
	}

	for name, def in pairs(commands) do
		vim.api.nvim_create_user_command(name, def.callback, def.opts)
	end

	notify("Analyzer commands enabled")
end

return M
