local M = {}

-- Default chalk colors
M.bg = "#1e1e2e" -- Default chalk background (main)
M.fg = "#c9c7cd" -- Default chalk foreground

---Standardized notification helper
---@param message string Notification message
---@param level? number Notification level (default: INFO)
---@param prefix? string Message prefix (default: "chalk.nvim")
function M.notify(message, level, prefix)
	level = level or vim.log.levels.INFO
	prefix = prefix or "chalk.nvim"
	vim.notify(string.format("%s: %s", prefix, message), level)
end

---Standardized error helper
---@param message string Error message
---@param prefix? string Message prefix (default: "chalk.nvim")
function M.error(message, prefix)
	M.notify(message, vim.log.levels.ERROR, prefix)
end

---Standardized warning helper
---@param message string Warning message
---@param prefix? string Message prefix (default: "chalk.nvim")
function M.warn(message, prefix)
	M.notify(message, vim.log.levels.WARN, prefix)
end

---Convert hex color to RGB values
---@param hex string Hex color string (e.g., "#ff0000")
---@return number, number, number RGB values (0-255)
function M.hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	if #hex == 3 then
		hex = hex:gsub("(.)", "%1%1")
	end
	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0
	return r, g, b
end

---Convert RGB values to hex color
---@param r number Red value (0-255)
---@param g number Green value (0-255)
---@param b number Blue value (0-255)
---@return string Hex color string
function M.rgb_to_hex(r, g, b)
	return string.format("#%02x%02x%02x", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
end

---Blend foreground color with alpha over background
---@param foreground string Foreground hex color
---@param alpha number Alpha value (0.0-1.0)
---@param background string Background hex color
---@return string Blended hex color
function M.blend(foreground, alpha, background)
	background = background or M.bg
	alpha = math.max(0, math.min(1, alpha))

	local fg_r, fg_g, fg_b = M.hex_to_rgb(foreground)
	local bg_r, bg_g, bg_b = M.hex_to_rgb(background)

	local blend_r = alpha * fg_r + (1 - alpha) * bg_r
	local blend_g = alpha * fg_g + (1 - alpha) * bg_g
	local blend_b = alpha * fg_b + (1 - alpha) * bg_b

	return M.rgb_to_hex(blend_r, blend_g, blend_b)
end

---Blend color with background using specified amount
---@param hex string Color to blend
---@param amount number Amount to blend (0.0-1.0)
---@param bg? string Background color (defaults to M.bg)
---@return string Blended color
function M.blend_bg(hex, amount, bg)
	return M.blend(hex, amount, bg or M.bg)
end

---Blend color with foreground using specified amount
---@param hex string Color to blend
---@param amount number Amount to blend (0.0-1.0)
---@param fg? string Foreground color (defaults to M.fg)
---@return string Blended color
function M.blend_fg(hex, amount, fg)
	return M.blend(hex, amount, fg or M.fg)
end

---Lighten a color by blending with white
---@param hex string Color to lighten
---@param amount number Amount to lighten (0.0-1.0)
---@return string Lightened color
function M.lighten(hex, amount)
	return M.blend(hex, 1 - amount, "#ffffff")
end

---Darken a color by blending with black
---@param hex string Color to darken
---@param amount number Amount to darken (0.0-1.0)
---@return string Darkened color
function M.darken(hex, amount)
	return M.blend(hex, 1 - amount, "#000000")
end

---Load a module with error handling
---@param modname string Module name to load
---@param silent? boolean Whether to suppress error messages
---@return table|nil Module or nil if load failed
function M.mod(modname, silent)
	local ok, result = pcall(require, modname)
	if not ok then
		if not silent then
			M.error("Failed to load module '" .. modname .. "'")
		end
		return nil
	end
	return result
end

---Resolve highlight group definitions
---@param groups table<string, chalk.Highlight|string> Raw highlight groups
---@return table<string, chalk.Highlight> Resolved highlight groups
function M.resolve(groups)
	local resolved = {}
	local visited = {}

	local function resolve_group(name, group)
		if visited[name] then
			return resolved[name] -- Avoid infinite recursion
		end
		visited[name] = true

		if type(group) == "string" then
			-- Handle link
			local target = groups[group]
			if target then
				resolved[name] = resolve_group(group, target)
			else
				resolved[name] = { link = group }
			end
		else
			resolved[name] = vim.deepcopy(group)
		end

		return resolved[name]
	end

	for name, group in pairs(groups) do
		if not resolved[name] then
			resolve_group(name, group)
		end
	end

	return resolved
end

---Check if a plugin is available
---@param plugin_name string Name of the plugin to check
---@return boolean Whether plugin is available
function M.plugin_available(plugin_name)
	local ok, _ = pcall(require, plugin_name)
	return ok
end

---Get the luminance of a color for contrast calculations
---@param hex string Hex color
---@return number Luminance value (0.0-1.0)
function M.luminance(hex)
	local r, g, b = M.hex_to_rgb(hex)

	-- Normalize to 0-1 range
	r, g, b = r / 255, g / 255, b / 255

	-- Apply gamma correction
	local function gamma_correct(c)
		return c <= 0.03928 and c / 12.92 or math.pow((c + 0.055) / 1.055, 2.4)
	end

	r = gamma_correct(r)
	g = gamma_correct(g)
	b = gamma_correct(b)

	-- Calculate luminance
	return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

---Calculate contrast ratio between two colors
---@param color1 string First color (hex)
---@param color2 string Second color (hex)
---@return number Contrast ratio (1.0-21.0)
function M.contrast(color1, color2)
	local lum1 = M.luminance(color1)
	local lum2 = M.luminance(color2)

	local lighter = math.max(lum1, lum2)
	local darker = math.min(lum1, lum2)

	return (lighter + 0.05) / (darker + 0.05)
end

---Ensure sufficient contrast by adjusting color
---@param color string Color to adjust
---@param background string Background color
---@param min_contrast number Minimum contrast ratio
---@return string Adjusted color with sufficient contrast
function M.ensure_contrast(color, background, min_contrast)
	min_contrast = min_contrast or 4.5 -- WCAG AA standard

	local current_contrast = M.contrast(color, background)
	if current_contrast >= min_contrast then
		return color
	end

	-- Try lightening first
	local step = 0.1
	local adjusted = color

	for i = 1, 10 do
		local lighter = M.lighten(adjusted, step * i)
		if M.contrast(lighter, background) >= min_contrast then
			return lighter
		end
	end

	-- If lightening didn't work, try darkening
	for i = 1, 10 do
		local darker = M.darken(color, step * i)
		if M.contrast(darker, background) >= min_contrast then
			return darker
		end
	end

	-- Fallback to high contrast color
	local bg_lum = M.luminance(background)
	return bg_lum > 0.5 and "#000000" or "#ffffff"
end

---Apply transparency to a highlight definition
---@param hl table Highlight definition
---@return table Modified highlight
function M.make_transparent(hl)
	if type(hl) == "table" then
		hl.bg = "NONE"
		hl.ctermbg = "NONE"
	end
	return hl
end

---Apply transparency to multiple highlight groups
---@param highlights table Highlight groups
---@param group_names string[] Groups to make transparent
---@return table Modified highlights
function M.apply_transparency(highlights, group_names)
	for _, group in ipairs(group_names) do
		if highlights[group] then
			highlights[group] = M.make_transparent(highlights[group])
		end
	end
	return highlights
end

---Cache management for chalk theme system
M.cache = {}

---Clear all cached data including dynamic overrides
function M.cache.clear()
	-- Clear dynamic color system cache (safe for theme loading)
	local has_dynamic, dynamic = pcall(require, "chalk.dynamic.dynamic")
	if has_dynamic and dynamic.clear_cache then
		-- Use safe cache clear that doesn't reload colorscheme
		dynamic.clear_cache()
	end

	-- Clear module cache for chalk modules
	for module_name, _ in pairs(package.loaded) do
		if module_name:match("^chalk%.") then
			package.loaded[module_name] = nil
		end
	end
end

return M
