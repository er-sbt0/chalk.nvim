-- Enhanced color utilities for chalk.nvim
-- Extends the core util.lua with advanced color manipulation functions

local Util = require("chalk.util")
local M = {}

-- Re-export core util functions for consistency
M.hex_to_rgb = Util.hex_to_rgb
M.rgb_to_hex = Util.rgb_to_hex
M.blend = Util.blend
M.blend_bg = Util.blend_bg
M.blend_fg = Util.blend_fg
M.lighten = Util.lighten
M.darken = Util.darken
M.luminance = Util.luminance
M.contrast = Util.contrast
M.ensure_contrast = Util.ensure_contrast

-- HSL color space conversions (extended functionality)

---Convert HSL to RGB
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return number, number, number r, g, b (0-255)
function M.hsl_to_rgb(h, s, l)
	h = h / 360
	s = s / 100
	l = l / 100

	local function hue_to_rgb(p, q, t)
		if t < 0 then
			t = t + 1
		end
		if t > 1 then
			t = t - 1
		end
		if t < 1 / 6 then
			return p + (q - p) * 6 * t
		end
		if t < 1 / 2 then
			return q
		end
		if t < 2 / 3 then
			return p + (q - p) * (2 / 3 - t) * 6
		end
		return p
	end

	local r, g, b
	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue_to_rgb(p, q, h + 1 / 3)
		g = hue_to_rgb(p, q, h)
		b = hue_to_rgb(p, q, h - 1 / 3)
	end

	return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

---Convert RGB to HSL
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return number, number, number h, s, l (h: 0-360, s/l: 0-100)
function M.rgb_to_hsl(r, g, b)
	r, g, b = r / 255, g / 255, b / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local diff = max - min
	local add = max + min
	local l = add * 0.5

	local s, h
	if diff == 0 then
		s, h = 0, 0
	else
		s = l < 0.5 and diff / add or diff / (2 - add)

		if max == r then
			h = ((g - b) / diff) + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / diff + 2
		else
			h = (r - g) / diff + 4
		end
		h = h / 6
	end

	return h * 360, s * 100, l * 100
end

---Convert hex to HSL
---@param hex string Hex color (#rrggbb)
---@return number, number, number h, s, l (h: 0-360, s/l: 0-100)
function M.hex_to_hsl(hex)
	local r, g, b = M.hex_to_rgb(hex)
	return M.rgb_to_hsl(r, g, b)
end

---Convert HSL to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return string Hex color (#rrggbb)
function M.hsl_to_hex(h, s, l)
	local r, g, b = M.hsl_to_rgb(h, s, l)
	return M.rgb_to_hex(r, g, b)
end

-- Advanced color manipulation

---Adjust brightness using HSL lightness
---@param hex string Hex color
---@param adjustment number Brightness adjustment (-100 to 100)
---@return string Adjusted hex color
function M.adjust_brightness(hex, adjustment)
	local h, s, l = M.hex_to_hsl(hex)
	l = math.max(0, math.min(100, l + adjustment))
	return M.hsl_to_hex(h, s, l)
end

---Adjust saturation
---@param hex string Hex color
---@param adjustment number Saturation adjustment (-100 to 100)
---@return string Adjusted hex color
function M.adjust_saturation(hex, adjustment)
	local h, s, l = M.hex_to_hsl(hex)
	s = math.max(0, math.min(100, s + adjustment))
	return M.hsl_to_hex(h, s, l)
end

---Shift hue
---@param hex string Hex color
---@param shift number Hue shift in degrees (-360 to 360)
---@return string Shifted hex color
function M.shift_hue(hex, shift)
	local h, s, l = M.hex_to_hsl(hex)
	h = (h + shift) % 360
	if h < 0 then
		h = h + 360
	end
	return M.hsl_to_hex(h, s, l)
end

-- Color families and palettes

---Color family definitions for dynamic adjustment
M.color_families = {
	warm = {
		{ hue = 0, name = "red" },
		{ hue = 30, name = "orange" },
		{ hue = 60, name = "yellow" },
		{ hue = 90, name = "yellow-green" },
	},
	cool = {
		{ hue = 180, name = "cyan" },
		{ hue = 210, name = "light-blue" },
		{ hue = 240, name = "blue" },
		{ hue = 270, name = "purple" },
	},
	saturated = {
		saturation_boost = 20,
		lightness_adjust = -5,
	},
	muted = {
		saturation_boost = -30,
		lightness_adjust = 10,
	},
}

---Apply color family transformation
---@param hex string Original hex color
---@param family string Color family ("warm", "cool", "saturated", "muted")
---@param direction number Direction (1 for next, -1 for previous)
---@return string Transformed hex color
function M.apply_color_family(hex, family, direction)
	local h, s, l = M.hex_to_hsl(hex)
	local family_def = M.color_families[family]

	if not family_def then
		return hex
	end

	if family == "saturated" or family == "muted" then
		-- Adjust saturation and lightness
		s = math.max(0, math.min(100, s + (family_def.saturation_boost * direction)))
		l = math.max(0, math.min(100, l + (family_def.lightness_adjust * direction)))
		return M.hsl_to_hex(h, s, l)
	else
		-- Find closest hue in family and move to next/previous
		local closest_idx = 1
		local closest_diff = math.abs(h - family_def[1].hue)

		for i, color in ipairs(family_def) do
			local diff = math.abs(h - color.hue)
			if diff < closest_diff then
				closest_diff = diff
				closest_idx = i
			end
		end

		-- Move to next/previous color in family
		local new_idx = closest_idx + direction
		if new_idx > #family_def then
			new_idx = 1
		end
		if new_idx < 1 then
			new_idx = #family_def
		end

		local new_hue = family_def[new_idx].hue
		return M.hsl_to_hex(new_hue, s, l)
	end
end

---Generate color wheel positions
---@param hex string Base hex color
---@param steps number Number of steps in the wheel
---@return table Array of hex colors
function M.generate_color_wheel(hex, steps)
	steps = steps or 12
	local h, s, l = M.hex_to_hsl(hex)
	local colors = {}

	for i = 0, steps - 1 do
		local new_hue = (h + (360 / steps) * i) % 360
		table.insert(colors, M.hsl_to_hex(new_hue, s, l))
	end

	return colors
end

---Get next color in wheel
---@param hex string Current hex color
---@param direction number Direction (1 for next, -1 for previous)
---@param steps number Number of steps in wheel (default: 12)
---@return string Next hex color
function M.get_wheel_color(hex, direction, steps)
	steps = steps or 12
	local h, s, l = M.hex_to_hsl(hex)
	local step_size = 360 / steps
	local new_hue = (h + (step_size * direction)) % 360
	if new_hue < 0 then
		new_hue = new_hue + 360
	end
	return M.hsl_to_hex(new_hue, s, l)
end

return M
