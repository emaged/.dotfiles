-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "html",
        "css",
        "htmldjango",
        "javascript",
        "typescript",
        "tsx",
        "python",
      })
    end,
  },
}
