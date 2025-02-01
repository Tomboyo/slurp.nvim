# Slurp.nvim

**S**truct**ur**a**l** text editing for nvim. Uh, **p**.

This plugin aims to provide similar funcitonality as vim-sexp or emacs' paredit
by taking advantage of treesitter, which is built in to neovim. In short:
slurp.nvim defines command for modifying a program in terms of its grammar.

## Usage

This plugin is a work in progress. That said, all it does is define <Plug>
mappings that you can optionally map commands to. Mappings may change in the
future. For the full list of Plugs, refer to the fnl/slurp.fnl source code. The
following is an example keybinding:

(This is fennel. Move the first parenthesis to the right a bit, replace `:foo`
with `"foo"` and `[foo]` with `{foo}` and you have lua.)
```fnl
; element selection
(vim.keymap.set [:v :o] "<LocalLeader>ee" "<Plug>(slurp-select-element)")
(vim.keymap.set [:v :o] "<LocalLeader>ie" "<Plug>(slurp-select-inside-element)")
(vim.keymap.set [:v :o] "<LocalLeader>ae" "<Plug>(slurp-select-outside-element)")
(vim.keymap.set [:v :o] "<LocalLeader>e)" "<Plug>(slurp-select-(element))")
(vim.keymap.set [:v :o] "<LocalLeader>e]" "<Plug>(slurp-select-[element])")
(vim.keymap.set [:v :o] "<LocalLeader>e}" "<Plug>(slurp-select-{element})")
(vim.keymap.set [:v :o] "<LocalLeader>i)" "<Plug>(slurp-select-inside-(element))")
(vim.keymap.set [:v :o] "<LocalLeader>i]" "<Plug>(slurp-select-inside-[element])")
(vim.keymap.set [:v :o] "<LocalLeader>i}" "<Plug>(slurp-select-inside-{element})")
(vim.keymap.set [:v :o] "<LocalLeader>a)" "<Plug>(slurp-select-outside-(element))")
(vim.keymap.set [:v :o] "<LocalLeader>a]" "<Plug>(slurp-select-outside-[element])")
(vim.keymap.set [:v :o] "<LocalLeader>a}" "<Plug>(slurp-select-outside-{element})")
(vim.keymap.set [:v :o] "<LocalLeader>il" "<Plug>(slurp-inner-list-to)")
(vim.keymap.set [:v :o] "<LocalLeader>al" "<Plug>(slurp-outer-list-to)")

;motion
(vim.keymap.set [:n :v :o] "w" "<Plug>(slurp-forward-into-element)")
(vim.keymap.set [:n :v :o] "W" "<Plug>(slurp-forward-over-element)")

;manipulation
(vim.keymap.set [:n]
              "<LocalLeader>)l"
              "<Plug>(slurp-slurp-close-paren-forward)")
(vim.keymap.set [:n]
              "<LocalLeader>(h"
              "<Plug>(slurp-slurp-open-paren-backward)")
(vim.keymap.set [:n]
              "<LocalLeader>(l"
              "<Plug>(slurp-barf-open-paren-forward)")
(vim.keymap.set [:n]
              "<LocalLeader>)h"
              "<Plug>(slurp-barf-close-paren-backward)")
(vim.keymap.set [:n]
              "<LocalLeader>o"
              "<Plug>(slurp-replace-parent)")
(vim.keymap.set [:n]
              "<LocalLeader>@)"
              "<Plug>(slurp-delete-surrounding-())")
```
