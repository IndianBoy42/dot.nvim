vim.diagnostic.config(vim.tbl_extend("keep", {
  virtual_text = false,
  virtual_lines = true,
}, require("langs").diagnostic_config))
