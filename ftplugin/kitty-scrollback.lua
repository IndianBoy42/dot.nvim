bufnr = vim.api.nvim_get_current_buf()
local map = function(mode, lhs, rhs, opts) opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {}) end

-- <Plug>(KsbExecuteCmd)	      <C-CR>	    n,i	   execute_command()	Execute the contents of the paste window in Kitty
-- <Plug>(KsbPasteCmd)	        <S-CR>	    n,i	   paste_command()	Paste the contents of the paste window to Kitty without executing
-- <Plug>(KsbExecuteVisualCmd)	<C-CR>	    v	     execute_visual_command()	Execute the contents of visual selection in Kitty
-- <Plug>(KsbPasteVisualCmd)	  <S-CR>	    v	     paste_visual_command()	Paste the contents of visual selection to Kitty without executing
-- <Plug>(KsbToggleFooter)	    g?	        n	     toggle_footer()	Toggle the paste window footer that displays mappings
-- <Plug>(KsbCloseOrQuitAll)	  <Esc>	      n	     close_or_quit_all()	If the current buffer is the paste buffer, then close the window. Otherwise quit Neovim
-- <Plug>(KsbQuitAll)	          <C-c>	      n,i,t	 quit_all()	Quit Neovim
-- <Plug>(KsbVisualYankLine)	  <Leader>Y	  v		   Maps to "+Y
-- <Plug>(KsbVisualYank)	      <Leader>y	  v		   Maps to "+y
-- <Plug>(KsbNormalYankEnd)	    <Leader>Y	  n		   Maps to "+y$
-- <Plug>(KsbNormalYank)	      <Leader>y	  n		   Maps to "+y
-- <Plug>(KsbNormalYankLine)	  <Leader>yy	n

-- TODO: <localleader> everything
map("v", "<localleader>Y", "<Plug>(KsbVisualYankLine)", { desc = 'Maps to "+Y' })
map("v", "<localleader>y", "<Plug>(KsbVisualYank)", { desc = 'Maps to "+y' })
map("n", "<localleader>Y", "<Plug>(KsbNormalYankEnd)", { desc = 'Maps to "+y$' })
map("n", "<localleader>y", "<Plug>(KsbNormalYank)", { desc = 'Maps to "+y' })
map("n", "<localleader>yy", "<Plug>(KsbNormalYankLine)", { desc = 'Maps to "+yy' })
map("n", "<S-CR>", utils.operatorfunc_keys "<S-CR>", { desc = 'Copy to Kitty' })
map("n", "<S-CR><S-CR>", utils.operatorfunc_keys ("<S-CR>", "il"), { desc = 'Copy to Kitty' })
map("n", "<C-CR>", utils.operatorfunc_keys "<C-CR>", { desc = 'Copy to Kitty' })
map("n", "<C-CR><C-CR>", utils.operatorfunc_keys ("<C-CR>", "il"), { desc = 'Copy to Kitty' })
map("n", "<localleader>c", utils.operatorfunc_keys "<S-CR>", { desc = 'Copy to Kitty' })
map("n", "<localleader>cc", utils.operatorfunc_keys ("<S-CR>", "il"), { desc = 'Copy to Kitty' })
map("n", "<localleader>C", utils.operatorfunc_keys ("<S-CR>", "$"), { desc = 'Copy to Kitty' })
