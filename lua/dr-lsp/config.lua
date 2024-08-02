local M = {}
--------------------------------------------------------------------------------

---@class DrLspConfig
local defaultConfig = {
	highlightCursorWordReferences = {
		enable = true,
	},
}

M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? DrLspConfig
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", M.config, userConfig or {})

	if M.config.highlightCursorWordReferences.enable then require("dr-lsp.highlight-cword-refs") end
end

--------------------------------------------------------------------------------
return M
