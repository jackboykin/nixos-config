-- Load paths from Nix-generated module for portable configuration
local ok, paths = pcall(require, "paths")
if not ok then
  vim.notify("paths.lua not found - run nixos-rebuild", vim.log.levels.WARN)
  paths = { nixos_config = "", hostname = "", username = "" }
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      { "folke/lazydev.nvim", opts = {} },
    },
    config = function()
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        float = { border = "rounded" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", vim.lsp.buf.references, "Show references")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
        end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        nixd = {
          settings = {
            nixd = {
              formatting = { command = { "alejandra" } },
              options = {
                nixos = {
                  expr = string.format(
                    '(builtins.getFlake "%s").nixosConfigurations.%s.options',
                    paths.nixos_config,
                    paths.hostname
                  ),
                },
                home_manager = {
                  expr = string.format(
                    '(builtins.getFlake "%s").homeConfigurations."%s".options',
                    paths.nixos_config,
                    paths.username
                  ),
                },
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              completion = { callSnippet = "Replace" },
            },
          },
        },
        ts_ls = {},
        cssls = {},
        html = {},
      }

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },
}
