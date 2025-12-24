return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      swift = { "swiftlint" },
      javascript = { "eslint_d" },
      python = { "ruff" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      kotlin = { "ktlint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
      group = lint_augroup,
      callback = function()
        if not vim.endswith(vim.fn.bufname(), "swiftinterface") then
          require("lint").try_lint()
        end
      end,
    })

    vim.keymap.set("n", "<leader>ml", function()
      require("lint").try_lint()
    end, { desc = "Lint file" })
  end,
}
