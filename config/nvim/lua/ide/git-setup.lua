vim.pack.add({
    { src = 'https://github.com/tpope/vim-fugitive' },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  },
  { confirm = false })

-- https://github.com/tpope/vim-fugitive
vim.keymap.set("n", "<leader>gb", ":<C-U>Git blame<CR>", { noremap = true, desc = "Open git blame", silent = true })
vim.keymap.set("n", "<leader>gH", ":<c-u>Git log --decorate --oneline --graph<cr>", { noremap = true, desc = "Show commits for repository", silent = true })
vim.keymap.set("n", "<leader>gh", ":<c-u>Git log --decorate --oneline --graph %<cr>", { noremap = true, desc = "Show commits that changed the file in buffer", silent = true })
vim.keymap.set("n", "<leader>gd", function()
    local commit_hash = vim.fn.getreg('"')
    vim.cmd("Gvdiffsplit " .. commit_hash)
  end, { noremap = true, desc = "Compare file to its previous state in the commit in the clipboard", silent = true, })


-- https://github.com/lewis6991/gitsigns.nvim
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        ---@diagnostic disable-next-line: param-type-mismatch
        gitsigns.nav_hunk('next')
      end
    end, {noremap = true, silent = true, desc = "Next hunk"})

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        ---@diagnostic disable-next-line: param-type-mismatch
        gitsigns.nav_hunk('prev')
      end
    end, {noremap = true, silent = true, desc = ""})

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk, {noremap = true, silent = true, desc = "stage_hunk"})
    map('n', '<leader>hr', gitsigns.reset_hunk, {noremap = true, silent = true, desc = "reset_hunk"})

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, {noremap = true, silent = true, desc = "stage_hunk"})

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, {noremap = true, silent = true, desc = "reset_hunk"})

    map('n', '<leader>hS', gitsigns.stage_buffer, {noremap = true, silent = true, desc = "stage_buffer"})
    map('n', '<leader>hR', gitsigns.reset_buffer, {noremap = true, silent = true, desc = "reset_buffer"})
    map('n', '<leader>hp', gitsigns.preview_hunk, {noremap = true, silent = true, desc = "preview_hunk"})
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, {noremap = true, silent = true, desc = "preview_hunk_inline"})

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end, {noremap = true, silent = true, desc = "blame_line"})

    map('n', '<leader>hd', gitsigns.diffthis, {noremap = true, silent = true, desc = "diffthis"})

    map('n', '<leader>hD', function()
      ---@diagnostic disable-next-line: param-type-mismatch
      gitsigns.diffthis('~')
    end, {noremap = true, silent = true, desc = "diffthis"})

    ---@diagnostic disable-next-line: param-type-mismatch
    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, {noremap = true, silent = true, desc = "setqflist"})
    map('n', '<leader>hq', gitsigns.setqflist, {noremap = true, silent = true, desc = "setqflist"})

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, {noremap = true, silent = true, desc = "toggle_current_line_blame"})
    map('n', '<leader>tw', gitsigns.toggle_word_diff, {noremap = true, silent = true, desc = "toggle_word_diff"})

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk, {noremap = true, silent = true, desc = "select_hunk"})
  end
}
