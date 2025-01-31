-- See https://hiphish.github.io/blog/2024/01/29/testing-neovim-plugins-with-busted/
local jobopts = {
  rpc = true,
  width = 80,
  height = 24,
  -- Note: tests rely on XDG_CONFIG_HOME and co. to correctly initialize nvim.
  -- The nluarocks container sets these up automatically
  -- clear_env = false
}

describe("TODO", function()
  local nvim -- embedded neovim process

  before_each(function()
    -- TODO: prefer vim.system() per documentation
    -- TODO: --headless
    nvim = vim.fn.jobstart({'nvim', '--embed', '--headless'}, jobopts)
  end)

  after_each(function()
    vim.fn.jobstop(nvim)
  end)

  it("TODO", function()
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
end)
