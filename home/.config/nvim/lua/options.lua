require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt ='both'
o.number = true
o.relativenumber = true
o.cursorline = true

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2

vim.opt.list = true
vim.opt.listchars = {
  tab = "»·",
  lead = "·",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}
