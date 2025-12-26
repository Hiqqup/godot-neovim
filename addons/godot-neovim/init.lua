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
vim.api.nvim_set_hl(0, 'Visual', { fg = 'NONE', bg = 'NONE' })
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

