vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showmode = false
vim.opt.showcmd = false


vim.cmd('syntax off')
vim.cmd('colorscheme default')
vim.opt.termguicolors = false
vim.opt.hlsearch = false

vim.api.nvim_set_hl(0, 'Normal', { fg = 'NONE', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Search', { fg = 'NONE', bg = 'NONE' })
--vim.api.nvim_set_hl(0, 'Visual', { fg = 'NONE', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'CursorLine', { fg = 'NONE', bg = 'NONE' })

vim.api.nvim_create_autocmd("BufAdd", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local path = vim.api.nvim_buf_get_name(buf)
        vim.rpcnotify(0, "new_buffer", buf, path)
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        vim.rpcnotify(0, "insert_enter")
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        vim.rpcnotify(0, "insert_leave")
    end,
})


-- Track mode changes and notify when entering visual mode
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    local mode = vim.fn.mode()

    local visual_type = nil
    if mode == "v" then
      visual_type = ""
    elseif mode == "V" then
      visual_type = "_line"
    elseif mode == "\22" then -- Ctrl-V is represented as \22 in Vim
      visual_type = "_block"
    end

    if visual_type then
      -- Send RPC notification
      vim.rpcnotify(0, "visual_enter", visual_type)
      vim.rpcnotify(0, "visual_selection_start", vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()))
    end
  end,
})


