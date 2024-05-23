if vim.g.dr_lsp_no_highlight then return end
--------------------------------------------------------------------------------

local activeOnBufs = {}

---@param bufnr? integer
local function setupLspCursorword(bufnr)
	if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
	if activeOnBufs[bufnr] then return end -- GUARD ensure idempotency

	local group = vim.api.nvim_create_augroup("LspCursorWord", {})
	activeOnBufs[bufnr] = group

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
			local deleted = pcall(vim.api.nvim_del_augroup_by_id, group)
			if deleted then
				activeOnBufs[bufnr] = nil
				return true -- delete this autocmd itself on success
			end
		end,
		buffer = bufnr,
	})
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities or {}
		if not capabilities.documentHighlightProvider then return end
		setupLspCursorword(args.buf)
	end,
})

-- initialization
-- (needed in case this plugin is loaded after LspAttach)
local clientWithDocumentHl = vim.tbl_filter(
	function(client) return client.server_capabilities.documentHighlightProvider end,
	vim.lsp.get_clients { bufnr = 0 }
)
if #clientWithDocumentHl > 0 then setupLspCursorword() end 

--------------------------------------------------------------------------------

local function setupHighlights()
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = true }) -- definition
	vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = true }) -- reference
	vim.api.nvim_set_hl(0, "LspReferenceText", {}) -- too much noise, as it underlines e.g. strings
end

-- persist highlights upon colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("LspCursorWordHighlightGroups", {}),
	callback = setupHighlights,
})

-- initialization
setupHighlights()
