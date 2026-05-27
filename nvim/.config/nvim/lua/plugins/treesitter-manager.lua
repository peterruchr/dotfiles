return {
	"romus204/tree-sitter-manager.nvim",
	lazy = false,
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"c_sharp",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
		},
	},
	config = function(_, opts)
		require("tree-sitter-manager").setup(opts)

		-- Tell Neovim 0.12 to use building treesitter-hightlighting globally
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				-- Performance tjek: Deaktiver hvis filen er over 100KB
				local max_filesize = 100 * 1024
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
				if ok and stats and stats.size > max_filesize then
					vim.notify("File too large (100KB+), syntax-highlighting deaktiveret.", vim.log.levels.WARN)
					return
				end

				-- Start Neovims indbyggede treesitter highlighting
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
