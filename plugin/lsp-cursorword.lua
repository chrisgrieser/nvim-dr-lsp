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
-- HIGHLIGHTS
local group = vim.api.nvim_create_augroup("LspCursorWordHighlights", {})

local function setupHighlights()
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = true }) -- definition
	vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = true }) -- reference
	vim.api.nvim_set_hl(0, "LspReferenceText", {}) -- too much noise, as it underlines e.g. strings
end

-- persist highlights upon colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = setupHighlights,
})
setupHighlights() -- initialization

--------------------------------------------------------------------------------
-- PAUSE HIGHLIGHTS WHEN IN SPECIAL WINDOWS
-- FIX: For plugins using backdrop-like effects, there is some winblend bug,
-- which causes the underlines to be displayed in ugly red. We fix this by
-- temporarily disabling the underline effects set by this plugin.
local function toggleHighlights()
	local regularBuffer = vim.bo.buftype == ""
	if regularBuffer then
		setupHighlights()
	else
		-- Needs to change highlights, as `vim.lsp.buf.clear_references` only
		-- works on the current buffer.
		vim.api.nvim_set_hl(0, "LspReferenceWrite", {})
		vim.api.nvim_set_hl(0, "LspReferenceRead", {})
	end
end

vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
	group = group,
	callback = function(ctx)
		if ctx.event == "WinEnter" then
			-- WinEnter needs a delay so buftype changes set by plugins are picked up
			vim.defer_fn(toggleHighlights, 1)
		elseif ctx.event == "FileType" and ctx.match == "DressingInput" then
			-- Dressing.nvim needs to be detected separately, as it uses `noautocmd`
			toggleHighlights()
		end
	end,
})
