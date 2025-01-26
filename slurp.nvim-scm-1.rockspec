rockspec_format = '3.0'
package = 'slurp.nvim'
version = 'scm-1'

test_dependencies = {
  'lua >= 5.1',
  'nlua',
  --'nui.nvim',
}

source = {
  url = 'git://github.com/Tomboyo/' .. package,
}

build = {
  -- TODO, needs to be make since fnl
  type = 'builtin',
}
