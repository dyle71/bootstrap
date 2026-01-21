require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

local function feed(keys)
  local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(k, "n", false)
end

local function scroll_follow(dir)
  local c = vim.v.count1
  local before = vim.fn.winsaveview()

  if dir == "down" then
    feed(c .. "<C-e>")
    local after = vim.fn.winsaveview()
    if after.topline ~= before.topline then
      feed(c .. "j")
    end
  else
    feed(c .. "<C-y>")
    local after = vim.fn.winsaveview()
    if after.topline ~= before.topline then
      feed(c .. "k")
    end
  end
end

map("n", "<A-j>", function() scroll_follow("down") end, { desc = "Scroll down, keep cursor position" })
map("n", "<A-k>", function() scroll_follow("up") end, { desc = "Scroll up, keep cursor position" })

