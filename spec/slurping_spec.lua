-- TODO: a way to set the buffer contents and position of the cursor with a
-- special symbol like "|" would make testing more obvious. E.g:
-- setBuf({
--   "line one"
--   "line |two"
--   "line three"})
-- would put the cursor on line two before the word "two". The buffer would not
-- actually contain the pipe character.
-- TODO: likewise, a way to get the buffer contents with a pipe character
-- injected to represent the cursor would help to make tests about where the
-- cursor ends up.

-- See https://hiphish.github.io/blog/2024/01/29/testing-neovim-plugins-with-busted/
local jobopts = {
  rpc = true,
  width = 80,
  height = 24,
  -- Note: tests rely on XDG_CONFIG_HOME and co. to correctly initialize nvim.
  -- The nluarocks container sets these up automatically
  -- clear_env = false
}

describe("slurping", function()
  local nvim -- embedded neovim process

  before_each(function()
    -- TODO: prefer vim.system() per documentation
    nvim = vim.fn.jobstart({'nvim', '--embed', '--headless'}, jobopts)
  end)

  after_each(function()
    vim.fn.jobstop(nvim)
  end)

  describe("slurp close paren forward", function()
    it("swaps the closing paren with the node's sibling", function()
      vim.rpcrequest(nvim, "nvim_buf_set_lines", 0, 0, 1, false, {"(foo (bar (baz) bang) whizz)"})
      vim.rpcrequest(nvim, "nvim_set_option_value", "filetype", "fennel", {})
      vim.rpcrequest(nvim, "nvim_exec_lua", "vim.treesitter.start()", {})

      vim.rpcrequest(nvim, "nvim_win_set_cursor", 0, {1, 12})
      vim.rpcrequest(
        nvim,
        "nvim_feedkeys",
        vim.api.nvim_replace_termcodes('<Plug>(slurp-slurp-close-paren-forward)', true, true, true),
        'm',
        false)

      local actual = vim.rpcrequest(nvim, "nvim_buf_get_lines", 0, 0, 1, true)[1]
      assert.is.equal("(foo (bar (baz bang)) whizz)", actual)
    end)

    it("applies to the smallest node around the cursor with a sibling", function()
      vim.rpcrequest(nvim, "nvim_buf_set_lines", 0, 0, 1, false, {"(foo (bar ((baz)) bang) whizz)"})
      vim.rpcrequest(nvim, "nvim_set_option_value", "filetype", "fennel", {})
      vim.rpcrequest(nvim, "nvim_exec_lua", "vim.treesitter.start()", {})

      vim.rpcrequest(nvim, "nvim_win_set_cursor", 0, {1, 13})
      vim.rpcrequest(
        nvim,
        "nvim_feedkeys",
        vim.api.nvim_replace_termcodes('<Plug>(slurp-slurp-close-paren-forward)', true, true, true),
        'm',
        false)

      local actual = vim.rpcrequest(nvim, "nvim_buf_get_lines", 0, 0, 1, true)[1]
      -- Note that baz is still surrounded by one set of parens
      assert.is.equal("(foo (bar ((baz) bang)) whizz)", actual)
    end)
  end)

  describe("slurp open paren backward", function()
    it("swaps the opening paren with the preceding element", function()
      vim.rpcrequest(nvim, "nvim_buf_set_lines", 0, 0, 1, false, {"(foo (bar (baz) bang) whizz)"})
      vim.rpcrequest(nvim, "nvim_set_option_value", "filetype", "fennel", {})
      vim.rpcrequest(nvim, "nvim_exec_lua", "vim.treesitter.start()", {})

      vim.rpcrequest(nvim, "nvim_win_set_cursor", 0, {1, 12})
      vim.rpcrequest(
        nvim,
        "nvim_feedkeys",
        vim.api.nvim_replace_termcodes('<Plug>(slurp-slurp-open-paren-backward)', true, true, true),
        'm',
        false)

      local actual = vim.rpcrequest(nvim, "nvim_buf_get_lines", 0, 0, 1, true)[1]
      assert.is.equal("(foo ((bar baz) bang) whizz)", actual)
    end)

    it("applies to the smallest node around the cursor with a sibling", function()
      vim.rpcrequest(nvim, "nvim_buf_set_lines", 0, 0, 1, false, {"(foo (bar ((baz)) bang) whizz)"})
      vim.rpcrequest(nvim, "nvim_set_option_value", "filetype", "fennel", {})
      vim.rpcrequest(nvim, "nvim_exec_lua", "vim.treesitter.start()", {})

      vim.rpcrequest(nvim, "nvim_win_set_cursor", 0, {1, 13})
      vim.rpcrequest(
        nvim,
        "nvim_feedkeys",
        vim.api.nvim_replace_termcodes('<Plug>(slurp-slurp-open-paren-backward)', true, true, true),
        'm',
        false)

      local actual = vim.rpcrequest(nvim, "nvim_buf_get_lines", 0, 0, 1, true)[1]
      -- Note that baz is still surrounded by one set of parens
      assert.is.equal("(foo ((bar (baz)) bang) whizz)", actual)
    end)
  end)
end)
