-- Quick setup script for chalk color generator
-- Add this to your init.lua for easy activation

local M = {}

---Quick setup with sensible defaults
---@param opts? table Optional configuration
function M.quick_setup(opts)
	opts = vim.tbl_extend("force", {
		-- Generator enabled by default
		enable_generator = true,
		generator_keymaps = true,
		
		-- Sensible generator defaults
		generator_config = {
			harmony_model = "split_complementary",
			min_contrast = 4.5,
			auto_apply = true,
			language_hints = true,
		},
		
		-- Other chalk options
		variant = "default",
		transparent = false,
		terminal_colors = true,
	}, opts or {})
	
	-- Setup chalk with generator
	require("chalk").setup(opts)
	
	-- Setup helpful autocmds
	M.setup_autocmds()
	
	-- Show help message
	vim.defer_fn(function()
		print("🎨 Chalk Color Generator enabled!")
		print("Commands: :ChalkGenerate, :ChalkPreview, :ChalkApply, :ChalkReset")
		print("Keymaps: <leader>cg, <leader>cp, <leader>ca, <leader>cr")
	end, 100)
end

---Setup helpful autocmds for the generator
function M.setup_autocmds()
	local group = vim.api.nvim_create_augroup("ChalkGenerator", { clear = true })
	
	-- Show generator status in statusline
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		pattern = "chalk*",
		callback = function()
			local generator = require("chalk.generator")
			if generator.current_palette then
				vim.g.chalk_generator_active = true
			else
				vim.g.chalk_generator_active = false
			end
		end
	})
end

---One-command activation for common use cases
function M.activate_for_language(language)
	local examples = {
		rust = [[
[@keyword.import]
[@keyword.type] Struct {
    [@variable.member]: [@type.builtin],
}
[@keyword.function] main() {
    [@keyword] mut [@variable] = [@type] {};
    [@variable.member] = [@string];
}]],
		
		python = [[
[@keyword.import] [@module]
[@keyword.function] [@function]([@parameter]: [@type]) -> [@type]:
    [@variable] = [@string]
    [@keyword.return] [@variable]
]],
		
		javascript = [[
[@keyword.import] { [@function] } [@keyword.import] [@string]
[@keyword.function] [@function]([@parameter]) {
    [@keyword] [@variable] = [@object];
    [@keyword.return] [@variable.property];
}]]
	}
	
	local dump = examples[language]
	if dump then
		local generator = require("chalk.generator")
		generator.generate_from_dump(dump, {
			harmony_model = language == "rust" and "split_complementary" or "triadic",
			auto_apply = true
		})
		vim.notify(string.format("Activated chalk generator for %s", language), vim.log.levels.INFO)
	else
		vim.notify(string.format("No example available for %s", language), vim.log.levels.WARN)
	end
end

-- Export setup function for easy access
_G.ChalkQuickSetup = M.quick_setup

return M
