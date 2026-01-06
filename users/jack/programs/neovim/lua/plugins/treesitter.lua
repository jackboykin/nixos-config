-- Grammars are pre-installed via Nix; just enable built-in features
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  main = "nvim-treesitter",
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
  },
}
