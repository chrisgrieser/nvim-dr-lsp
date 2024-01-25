if vim.g.dr_lsp_no_highlight then return end
--------------------------------------------------------------------------------

---@param bufnr integer
local function setupLspCursorword(bufnr)
	local group = vim.api.nvim_create_augroup("LspDocumentHighlight", {})
	vim.api.nvim_create_autocmd("CursorHold", {
		callback = vim.lsp.buf.document_highlight,
		buffer = bufnr,
		group = group,
	})
	vim.api.nvim_create_autocmd("CursorMoved", {
		callback = vim.lsp.buf.clear_references,
		buffer = bufnr,
		group = group,
	})

	-- LspDetach needed e.g. for when user restarts LSP server
	vim.api.nvim_create_autocmd("LspDetach", {
		callback = function()
			vim.lsp.buf.clear_references()
			pcall(vim.api.nvim_del_augroup_by_id, group)
		end,
		buffer = bufnr,
		group = group,
	})
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities
		if not capabilities.documentHighlightProvider then return end
		setupLspCursorword(args.buf)
	end,
})

-- initialization (needed in case this plugin is loaded after LspAttach)
local curBufnr = vim.api.nvim_get_current_buf()
local clientWithDocumentHighlight = vim.lsp.get_clients {
	bufnr = curBufnr,
	filter = function(client) return client.server_capabilities.documentHighlightProvider end,
}
if #clientWithDocumentHighlight > 0 then setupLspCursorword(curBufnr) end ---@diagnostic disable-line: param-type-mismatch

--------------------------------------------------------------------------------

local function setupHighlights()
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = true }) -- definition
	vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = true }) -- reference
	vim.api.nvim_set_hl(0, "LspReferenceText", {}) -- too much noise, as it underlines e.g. strings
end

-- persist highlights upon colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", { callback = setupHighlights })

-- initialization
setupHighlights()
