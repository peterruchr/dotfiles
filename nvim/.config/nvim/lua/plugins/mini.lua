return {
	{
		"nvim-mini/mini.pairs",
		version = "*",
		config = function()
			require("mini.pairs").setup()
		end,
	},
	{
		"nvim-mini/mini.move",
		version = "*",
		config = function()
			require("mini.move").setup()
		end,
	},
	{
		"nvim-mini/mini.comment",
		version = "*",
		config = function()
			require("mini.comment").setup()
		end,
	},
	{
		"nvim-mini/mini.indentscope",
		version = "*",
		config = function()
			require("mini.indentscope").setup()
		end,
	},
	{
		"nvim-mini/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup()
		end,
	},
}
