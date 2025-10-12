-- TreeSitter-based color scheme generator for chalk.nvim
-- Analyzes TreeSitter dumps and generates harmonious, coherent color palettes

local M = {}

-- Color utility functions
local ColorUtils = {}

---Convert HSL to RGB
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return number, number, number r, g, b (0-255)
function ColorUtils.hsl_to_rgb(h, s, l)
	h = h / 360
	s = s / 100
	l = l / 100

	local function hue_to_rgb(p, q, t)
		if t < 0 then t = t + 1 end
		if t > 1 then t = t - 1 end
		if t < 1/6 then return p + (q - p) * 6 * t end
		if t < 1/2 then return q end
		if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
		return p
	end

	local r, g, b
	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue_to_rgb(p, q, h + 1/3)
		g = hue_to_rgb(p, q, h)
		b = hue_to_rgb(p, q, h - 1/3)
	end

	return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

---Convert RGB to hex
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return string Hex color (#rrggbb)
function ColorUtils.rgb_to_hex(r, g, b)
	return string.format("#%02x%02x%02x", r, g, b)
end

---Convert HSL to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return string Hex color (#rrggbb)
function ColorUtils.hsl_to_hex(h, s, l)
	local r, g, b = ColorUtils.hsl_to_rgb(h, s, l)
	return ColorUtils.rgb_to_hex(r, g, b)
end

---Calculate relative luminance for WCAG contrast
---@param hex string Hex color (#rrggbb)
---@return number Relative luminance (0-1)
function ColorUtils.relative_luminance(hex)
	local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
	
	local function gamma_correct(c)
		c = c / 255
		return c <= 0.03928 and c / 12.92 or math.pow((c + 0.055) / 1.055, 2.4)
	end
	
	r, g, b = gamma_correct(r), gamma_correct(g), gamma_correct(b)
	return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

---Calculate WCAG contrast ratio
---@param color1 string First color (#rrggbb)
---@param color2 string Second color (#rrggbb)
---@return number Contrast ratio (1-21)
function ColorUtils.contrast_ratio(color1, color2)
	local l1 = ColorUtils.relative_luminance(color1)
	local l2 = ColorUtils.relative_luminance(color2)
	local lighter = math.max(l1, l2)
	local darker = math.min(l1, l2)
	return (lighter + 0.05) / (darker + 0.05)
end

-- TreeSitter analyzer
local TreeSitterAnalyzer = {}

---Semantic token groups with their characteristics
TreeSitterAnalyzer.semantic_groups = {
	structure = {
		base_hue = 280, -- Purple family
		saturation_range = {40, 70},
		lightness_range = {50, 80},
		tokens = {
			"@keyword", "@keyword.conditional", "@keyword.repeat", "@keyword.type",
			"@keyword.operator", "@operator", "@punctuation", "@keyword.import"
		}
	},
	control_flow = {
		base_hue = 310, -- Violet family  
		saturation_range = {50, 80},
		lightness_range = {55, 85},
		tokens = {
			"@keyword.return", "@keyword.exception", "@keyword.function"
		}
	},
	types = {
		base_hue = 50, -- Golden family
		saturation_range = {60, 90},
		lightness_range = {65, 85},
		tokens = {
			"@type", "@type.builtin", "@type.definition", "@constructor"
		}
	},
	functions = {
		base_hue = 220, -- Blue family
		saturation_range = {45, 75},
		lightness_range = {55, 80},
		tokens = {
			"@function", "@function.call", "@function.method", "@function.builtin"
		}
	},
	data = {
		base_hue = 30, -- Orange family
		saturation_range = {50, 80},
		lightness_range = {60, 85},
		tokens = {
			"@variable", "@constant", "@number", "@string", "@property"
		}
	},
	meta = {
		base_hue = 200, -- Cool blue-gray
		saturation_range = {20, 50},
		lightness_range = {40, 70},
		tokens = {
			"@comment", "@attribute", "@markup"
		}
	}
}

---Parse TreeSitter dump text and extract token frequency
---@param dump_text string TreeSitter dump content
---@param verbose? boolean Enable verbose debug output
---@return table<string, number> Token frequency map
function TreeSitterAnalyzer.parse_dump(dump_text, verbose)
	local token_count = {}
	verbose = verbose or false
	
	-- Debug: Show first 200 chars of dump (only in verbose mode)
	if verbose then
		vim.notify("Parsing dump (first 200 chars): " .. dump_text:sub(1, 200), vim.log.levels.INFO)
	end
	
	-- Try multiple TreeSitter dump formats
	
	-- Format 1: [@token] - bracket format (playground style)
	local found_bracket_format = false
	for token in dump_text:gmatch("%[@([^%]]+)%]") do
		found_bracket_format = true
		-- Handle composite tokens like "@variable,@variable.member"
		for single_token in token:gmatch("([^,]+)") do
			single_token = "@" .. single_token:gsub("^@", "")
			token_count[single_token] = (token_count[single_token] or 0) + 1
		end
	end
	
	-- Format 2: @token - direct format (inspect style)
	if not found_bracket_format then
		for token in dump_text:gmatch("@[%w%._%-%+]+") do
			token_count[token] = (token_count[token] or 0) + 1
		end
	end
	
	-- Format 3: "token" - quoted format
	if vim.tbl_count(token_count) == 0 then
		for token in dump_text:gmatch('"(@[%w%._%-%+]+)"') do
			token_count[token] = (token_count[token] or 0) + 1
		end
	end
	
	-- Format 4: Plain token names (TSPlayground capture names)
	if vim.tbl_count(token_count) == 0 then
		-- Look for common TreeSitter capture patterns
		for line in dump_text:gmatch("[^\r\n]+") do
			-- Match lines like "  keyword @keyword"
			local capture = line:match("%s*%w+%s+(@[%w%._%-%+]+)")
			if capture then
				token_count[capture] = (token_count[capture] or 0) + 1
			end
			-- Match lines like "keyword" (add @ prefix)
			local bare_token = line:match("^%s*([%w%._%-%+]+)%s*$")
			if bare_token and not bare_token:match("^@") then
				-- Only add @ if it looks like a TreeSitter capture
				if bare_token:match("^(keyword|function|variable|type|string|number|comment|operator)") then
					token_count["@" .. bare_token] = (token_count["@" .. bare_token] or 0) + 1
				end
			end
		end
	end
	
	-- Debug: Show parsed tokens (only in verbose mode)
	if verbose then
		local token_list = {}
		for token, count in pairs(token_count) do
			table.insert(token_list, string.format("%s:%d", token, count))
		end
		vim.notify("Parsed " .. vim.tbl_count(token_count) .. " token types: " .. 
			table.concat(token_list, ", "), vim.log.levels.INFO)
	end
	
	return token_count
end

---Categorize tokens into semantic groups
---@param tokens table<string, number> Token frequency map
---@param verbose? boolean Enable verbose debug output
---@return table<string, table<string, number>> Categorized tokens
function TreeSitterAnalyzer.categorize_tokens(tokens, verbose)
	local categorized = {}
	local total_categorized = 0
	verbose = verbose or false
	
	for group_name, group_data in pairs(TreeSitterAnalyzer.semantic_groups) do
		categorized[group_name] = {}
		
		for _, base_token in ipairs(group_data.tokens) do
			-- Find all tokens that start with this base token
			for token, count in pairs(tokens) do
				local escaped_base = base_token:gsub("%.", "%%."):gsub("%-", "%%-"):gsub("%+", "%%+")
				if token:match("^" .. escaped_base .. "($|%.)") then
					if not categorized[group_name][token] then -- Avoid double-counting
						categorized[group_name][token] = count
						total_categorized = total_categorized + 1
					end
				end
			end
		end
	end
	
	-- Handle uncategorized tokens by assigning them to appropriate groups
	local uncategorized = {}
	for token, count in pairs(tokens) do
		local is_categorized = false
		for _, group_tokens in pairs(categorized) do
			if group_tokens[token] then
				is_categorized = true
				break
			end
		end
		if not is_categorized then
			uncategorized[token] = count
		end
	end
	
	-- Auto-assign uncategorized tokens based on patterns
	for token, count in pairs(uncategorized) do
		if token:match("@keyword") then
			categorized.structure[token] = count
			total_categorized = total_categorized + 1
		elseif token:match("@type") then
			categorized.types[token] = count
			total_categorized = total_categorized + 1
		elseif token:match("@function") then
			categorized.functions[token] = count
			total_categorized = total_categorized + 1
		elseif token:match("@variable") then
			categorized.data[token] = count
			total_categorized = total_categorized + 1
		elseif token:match("@string") or token:match("@number") or token:match("@constant") then
			categorized.data[token] = count
			total_categorized = total_categorized + 1
		elseif token:match("@comment") then
			categorized.meta[token] = count
			total_categorized = total_categorized + 1
		else
			-- Default fallback to structure group
			categorized.structure[token] = count
			total_categorized = total_categorized + 1
		end
	end
	
	-- Debug: Show categorization results (only in verbose mode)  
	if verbose then
		vim.notify(string.format("Categorized %d tokens into %d groups", 
			total_categorized, vim.tbl_count(categorized)), vim.log.levels.INFO)
			
		for group_name, group_tokens in pairs(categorized) do
			if vim.tbl_count(group_tokens) > 0 then
				local group_list = {}
				for token, count in pairs(group_tokens) do
					table.insert(group_list, string.format("%s:%d", token, count))
				end
				vim.notify(string.format("Group %s: %s", group_name, 
					table.concat(group_list, ", ")), vim.log.levels.INFO)
			end
		end
	end
	
	return categorized
end

-- Color scheme generator
local ColorGenerator = {}

---@class GeneratorOptions
---@field background string Background color (#rrggbb)
---@field harmony_model string "split_complementary" | "triadic" | "analogous"
---@field min_contrast number Minimum WCAG contrast ratio
---@field language_specific table<string, table> Language-specific adjustments

---Generate harmonious color palette from TreeSitter analysis
---@param categorized_tokens table<string, table<string, number>> Categorized tokens
---@param opts GeneratorOptions Generation options
---@return table<string, string> Token to color mapping
function ColorGenerator.generate_palette(categorized_tokens, opts)
	opts = vim.tbl_extend("force", {
		background = "#1e2328",
		harmony_model = "split_complementary",
		min_contrast = 4.5,
		language_specific = {}
	}, opts or {})
	
	local palette = {}
	
	-- Generate base colors for each semantic group
	local base_colors = ColorGenerator.create_base_harmony(opts.harmony_model)
	
	-- Generate variations within each group
	for group_name, tokens in pairs(categorized_tokens) do
		if TreeSitterAnalyzer.semantic_groups[group_name] then
			local group_palette = ColorGenerator.generate_group_variations(
				group_name, tokens, base_colors, opts
			)
			palette = vim.tbl_extend("force", palette, group_palette)
		end
	end
	
	-- Ensure accessibility
	palette = ColorGenerator.ensure_accessibility(palette, opts.background, opts.min_contrast)
	
	return palette
end

---Create base color harmony
---@param model string Harmony model
---@return table<string, string> Base colors for each group
function ColorGenerator.create_base_harmony(model)
	if model == "split_complementary" then
		return {
			functions = ColorUtils.hsl_to_hex(220, 60, 70),    -- Blue
			structure = ColorUtils.hsl_to_hex(40, 55, 65),     -- Yellow-orange  
			types = ColorUtils.hsl_to_hex(100, 65, 75),        -- Yellow-green
			data = ColorUtils.hsl_to_hex(10, 70, 80),          -- Red-orange
			control_flow = ColorUtils.hsl_to_hex(280, 55, 65), -- Purple
			meta = ColorUtils.hsl_to_hex(200, 30, 50)          -- Cool gray
		}
	elseif model == "triadic" then
		return {
			functions = ColorUtils.hsl_to_hex(240, 60, 70),    -- Blue
			types = ColorUtils.hsl_to_hex(0, 65, 75),          -- Red  
			data = ColorUtils.hsl_to_hex(120, 70, 80),         -- Green
			structure = ColorUtils.hsl_to_hex(280, 55, 65),    -- Purple
			control_flow = ColorUtils.hsl_to_hex(320, 55, 65), -- Magenta
			meta = ColorUtils.hsl_to_hex(200, 30, 50)          -- Cool gray
		}
	else -- analogous
		return {
			functions = ColorUtils.hsl_to_hex(240, 60, 70),    -- Blue
			structure = ColorUtils.hsl_to_hex(260, 55, 65),    -- Blue-purple
			control_flow = ColorUtils.hsl_to_hex(280, 55, 65), -- Purple  
			types = ColorUtils.hsl_to_hex(300, 65, 75),        -- Purple-magenta
			data = ColorUtils.hsl_to_hex(320, 70, 80),         -- Magenta
			meta = ColorUtils.hsl_to_hex(200, 30, 50)          -- Cool gray
		}
	end
end

---Generate color variations within a semantic group
---@param group_name string Group name
---@param tokens table<string, number> Tokens in group with frequencies
---@param base_colors table<string, string> Base color palette
---@param opts GeneratorOptions Options
---@return table<string, string> Token to color mapping
function ColorGenerator.generate_group_variations(group_name, tokens, base_colors, opts)
	local group_data = TreeSitterAnalyzer.semantic_groups[group_name]
	if not group_data then return {} end
	
	local base_color = base_colors[group_name]
	if not base_color then return {} end
	
	local variations = {}
	local sorted_tokens = {}
	
	-- Sort tokens by frequency (most frequent first)
	for token, count in pairs(tokens) do
		table.insert(sorted_tokens, {token = token, count = count})
	end
	table.sort(sorted_tokens, function(a, b) return a.count > b.count end)
	
	-- Generate variations
	for i, token_data in ipairs(sorted_tokens) do
		local token = token_data.token
		
		-- Calculate variation based on position in frequency list
		local lightness_offset = (i - 1) * 8 - 16 -- Spread around base
		local saturation_offset = (i - 1) * 5 - 10
		
		-- Apply language-specific adjustments
		local lang_adjustments = opts.language_specific[token] or {}
		lightness_offset = lightness_offset + (lang_adjustments.lightness or 0)
		saturation_offset = saturation_offset + (lang_adjustments.saturation or 0)
		
		-- Clamp to group ranges
		local base_hue = group_data.base_hue + (lang_adjustments.hue_shift or 0)
		local saturation = math.max(group_data.saturation_range[1], 
		                   math.min(group_data.saturation_range[2], 60 + saturation_offset))
		local lightness = math.max(group_data.lightness_range[1],
		                  math.min(group_data.lightness_range[2], 70 + lightness_offset))
		
		variations[token] = ColorUtils.hsl_to_hex(base_hue % 360, saturation, lightness)
	end
	
	return variations
end

---Ensure all colors meet accessibility requirements
---@param palette table<string, string> Token to color mapping
---@param background string Background color
---@param min_contrast number Minimum contrast ratio
---@return table<string, string> Adjusted palette
function ColorGenerator.ensure_accessibility(palette, background, min_contrast)
	local adjusted = {}
	
	for token, color in pairs(palette) do
		local contrast = ColorUtils.contrast_ratio(color, background)
		
		if contrast < min_contrast then
			-- Adjust lightness to meet contrast requirement
			-- This is a simplified approach - a full implementation would be more sophisticated
			adjusted[token] = ColorGenerator.adjust_for_contrast(color, background, min_contrast)
		else
			adjusted[token] = color
		end
	end
	
	return adjusted
end

---Adjust color lightness to meet contrast requirement
---@param color string Original color
---@param background string Background color  
---@param target_contrast number Target contrast ratio
---@return string Adjusted color
function ColorGenerator.adjust_for_contrast(color, background, target_contrast)
	-- This is a simplified implementation
	-- A full version would use proper color space conversions
	local bg_lum = ColorUtils.relative_luminance(background)
	
	-- If background is dark, make color lighter
	-- If background is light, make color darker  
	if bg_lum < 0.5 then
		-- Dark background - increase lightness
		return color -- Simplified - would adjust HSL lightness
	else
		-- Light background - decrease lightness
		return color -- Simplified - would adjust HSL lightness
	end
end

-- Main module interface
M.ColorUtils = ColorUtils
M.TreeSitterAnalyzer = TreeSitterAnalyzer  
M.ColorGenerator = ColorGenerator

---Generate color palette from TreeSitter dump
---@param dump_text string TreeSitter dump content
---@param opts? GeneratorOptions Generation options
---@return table<string, string> Token to color mapping
function M.generate_from_dump(dump_text, opts)
	opts = opts or {}
	local verbose = opts.verbose or false
	
	local tokens = TreeSitterAnalyzer.parse_dump(dump_text, verbose)
	local categorized = TreeSitterAnalyzer.categorize_tokens(tokens, verbose)
	return ColorGenerator.generate_palette(categorized, opts)
end

---Generate color palette for current buffer
---@param opts? GeneratorOptions Generation options
---@return table<string, string> Token to color mapping
function M.generate_for_buffer(opts)
	-- Get TreeSitter dump for current buffer
	local parser = vim.treesitter.get_parser()
	if not parser then
		vim.notify("No TreeSitter parser available for current buffer", vim.log.levels.WARN)
		return {}
	end
	
	-- This would require implementing TreeSitter query extraction
	-- For now, return empty table
	vim.notify("Buffer analysis not yet implemented", vim.log.levels.INFO)
	return {}
end

return M
