return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local util = require("lspconfig.util")

    local capabilities = cmp_nvim_lsp.default_capabilities()

    local on_attach = function(_, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }

      opts.desc = "Show line diagnostics"
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

      opts.desc = "Show documentation for what is under cursor"
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

      opts.desc = "Show LSP definition"
      vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions trim_text=true<CR>", opts)
    end

    -- SourceKit LSP for Swift / iOS projects
    lspconfig.sourcekit.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = function(fname)
        return util.root_pattern("Package.swift")(fname)
          or util.find_git_ancestor(fname)
          or vim.loop.cwd()
      end,
      cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
    })

    -- Kotlin
    lspconfig.kotlin_language_server.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- typescript
    lspconfig.tsserver.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      -- optional:
      settings = {
        typescript = {
          inlayHints = { includeInlayParameterNameHints = "all" },
        },
      },
    })

    -- mason
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "pyright",
        "kotlin_language_server",
        "lemminx",
        -- sourcekit-lsp is usually managed by Xcode, so not included here
      },
    })

    -- python
    lspconfig.pyright.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic", -- change to "strict" if you want
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    })

    lspconfig.lemminx.setup({
      cmd = { "lemminx" },
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- nice icons
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
  end,
}
