if vim.g.dr_lsp_no_highlight then return end
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities
		if not capabilities.documentHighlightProvider then return end

		local group = vim.api.nvim_create_augroup("LspDocumentHighlight", {})
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = vim.lsp.buf.document_highlight,
			buffer = args.buf,
			group = group,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			callback = vim.lsp.buf.clear_references,
			buffer = args.buf,
			group = group,
		})
		vim.api.nvim_create_autocmd("LspDetach", {
			callback = function()
				vim.lsp.buf.clear_references()
				pcall(vim.api.nvim_del_augroup_by_id, group)
			end,
		})
	end,
})

--------------------------------------------------------------------------------

local function setupHighlights()
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = true }) -- definition
	vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = true }) -- reference
	vim.api.nvim_set_hl(0, "LspReferenceText", {}) -- too much noise, as is underlines e.g. strings
end

-- initialization
setupHighlights()

-- persist upon colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", { callback = setupHighlights })
