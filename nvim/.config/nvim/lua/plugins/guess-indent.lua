return {
  "NMAC427/guess-indent.nvim",
  event = "BufReadPost",
  config = function()
    require("guess-indent").setup {
      auto_cmd = true,  -- Set indent when opening a file
      override_editorconfig = false, -- Don’t override .editorconfig
    }
  end,
}
