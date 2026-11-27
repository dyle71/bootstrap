require "nvchad.autocmds"

-- open nvim-tree on startup; keep focus on the file if one was given
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    local is_dir = vim.fn.isdirectory(data.file) == 1
    local is_file = vim.fn.filereadable(data.file) == 1
    if is_dir then
      vim.cmd.cd(data.file)
    end
    require("nvim-tree.api").tree.open { focus = not is_file }
    if is_file then
      vim.cmd.wincmd "p"
    end
  end,
})
