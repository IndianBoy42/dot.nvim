local M = {}

local recipes = {}
local function add_recipes(recipes_)
  vim.list_extend(recipes, recipes_)
  vim.g["sandwich#recipes"] = recipes
end
M.add_recipes = add_recipes
function M.add_recipe(recipe)
  add_recipes { recipe }
end

local insertlocal = utils.fn.sandwich.util.insertlocal
local function add_local_recipes(recipes_)
  local localrecipes = vim.b.sandwich_recipes
  if localrecipes == nil then
    localrecipes = vim.deepcopy(recipes)
  end
  vim.list_extend(localrecipes, recipes_)
  vim.b.sandwich_recipes = localrecipes
end
M.add_local_recipes = add_local_recipes
function M.add_local_recipe(recipe)
  add_local_recipes { recipe }
end

M.default_recipes = {
  {
    ["buns"] = { "s+", "s+" },
    ["regex"] = 1,
    ["kind"] = { "delete", "replace", "query" },
    ["input"] = { " " },
  },

  {
    ["buns"] = { "", "" },
    ["action"] = { "add" },
    ["motionwise"] = { "line" },
    ["linewise"] = 1,
    ["input"] = { "<CR>" },
  },

  {
    ["buns"] = { "^$", "^$" },
    ["regex"] = 1,
    ["linewise"] = 1,
    ["input"] = { "<CR>" },
  },

  {
    ["buns"] = { "<", ">" },
    ["expand_range"] = 0,
    ["input"] = { ">", "a" },
  },

  {
    ["buns"] = { "`", "`" },
    ["quoteescape"] = 1,
    ["expand_range"] = 0,
    ["nesting"] = 0,
    ["linewise"] = 0,
  },

  {
    ["buns"] = { '"', '"' },
    ["quoteescape"] = 1,
    ["expand_range"] = 0,
    ["nesting"] = 0,
    ["linewise"] = 0,
  },

  {
    ["buns"] = { "'", "'" },
    ["quoteescape"] = 1,
    ["expand_range"] = 0,
    ["nesting"] = 0,
    ["linewise"] = 0,
  },

  {
    ["buns"] = { "{", "}" },
    ["nesting"] = 1,
    ["skip_break"] = 1,
    ["input"] = { "{", "}", "B" },
  },

  {
    ["buns"] = { "[", "]" },
    ["nesting"] = 1,
    ["input"] = { "[", "]", "r" },
  },

  {
    ["buns"] = { "(", ")" },
    ["nesting"] = 1,
    ["input"] = { "(", ")", "b" },
  },

  {
    ["buns"] = "sandwich#magicchar#t#tag()",
    ["listexpr"] = 1,
    ["kind"] = { "add" },
    ["action"] = { "add" },
    ["input"] = { "t", "T" },
  },

  {
    ["buns"] = "sandwich#magicchar#t#tag()",
    ["listexpr"] = 1,
    ["kind"] = { "replace" },
    ["action"] = { "add" },
    ["input"] = { "T", "<" },
  },

  {
    ["buns"] = "sandwich#magicchar#t#tagname()",
    ["listexpr"] = 1,
    ["kind"] = { "replace" },
    ["action"] = { "add" },
    ["input"] = { "t" },
  },

  {
    ["external"] = { "<Plug>(textobj-sandwich-tag-i)", "<Plug>(textobj-sandwich-tag-a)" },
    ["noremap"] = 0,
    ["kind"] = { "delete", "textobj" },
    ["expr_filter"] = { 'operator#sandwich#kind() !=# "replace"' },
    ["linewise"] = 1,
    ["input"] = { "t", "T", "<" },
  },

  {
    ["external"] = { "<Plug>(textobj-sandwich-tag-i)", "<Plug>(textobj-sandwich-tag-a)" },
    ["noremap"] = 0,
    ["kind"] = { "replace", "query" },
    ["expr_filter"] = { 'operator#sandwich#kind() ==# "replace"' },
    ["input"] = { "T", "<" },
  },

  {
    ["external"] = { "<Plug>(textobj-sandwich-tagname-i)", "<Plug>(textobj-sandwich-tagname-a)" },
    ["noremap"] = 0,
    ["kind"] = { "replace", "textobj" },
    ["expr_filter"] = { 'operator#sandwich#kind() ==# "replace"' },
    ["input"] = { "t" },
  },

  {
    ["buns"] = { "sandwich#magicchar#f#fname()", '")"' },
    ["kind"] = { "add", "replace" },
    ["action"] = { "add" },
    ["expr"] = 1,
    ["input"] = { "f" },
  },

  {
    ["external"] = { "<Plug>(textobj-sandwich-function-ip)", "<Plug>(textobj-sandwich-function-i)" },
    ["noremap"] = 0,
    ["kind"] = { "delete", "replace", "query" },
    ["input"] = { "f" },
  },

  {
    ["external"] = { "<Plug>(textobj-sandwich-function-ap)", "<Plug>(textobj-sandwich-function-a)" },
    ["noremap"] = 0,
    ["kind"] = { "delete", "replace", "query" },
    ["input"] = { "F" },
  },

  {
    ["buns"] = 'sandwich#magicchar#i#input("operator")',
    ["kind"] = { "add", "replace" },
    ["action"] = { "add" },
    ["listexpr"] = 1,
    ["input"] = { "i" },
  },

  {
    ["buns"] = 'sandwich#magicchar#i#input("textobj", 1)',
    ["kind"] = { "delete", "replace", "query" },
    ["listexpr"] = 1,
    ["regex"] = 1,
    ["input"] = { "i" },
  },

  {
    ["buns"] = 'sandwich#magicchar#i#lastinput("operator", 1)',
    ["kind"] = { "add", "replace" },
    ["action"] = { "add" },
    ["listexpr"] = 1,
    ["input"] = { "I" },
  },

  {
    ["buns"] = 'sandwich#magicchar#i#lastinput("textobj")',
    ["kind"] = { "delete", "replace", "query" },
    ["listexpr"] = 1,
    ["regex"] = 1,
    ["input"] = { "I" },
  },

  {
    external = { "ic", "ac" },
    noremap = false,
    kind = { "delete", "replace", "query" },
    input = { "c" },
  },
  {
    external = { "ii", "ai" },
    noremap = false,
    kind = { "delete", "replace", "query" },
    input = { "i" },
  },
  {
    external = { "if", "af" },
    noremap = false,
    kind = { "delete", "replace", "query" },
    input = { "af" },
  },
  -- {
  --   buns = { {[']], [[']} },
  --   quoteescape = true,
  --   expand_range = false,
  --   nesting = false,
  --   input = { "q" },
  -- },
  -- {
  --   buns = { {["]], [["]} },
  --   quoteescape = true,
  --   expand_range = false,
  --   nesting = false,
  --   input = { "Q" },
  -- },
  {
    buns = { "{'`\"]", "['`\"}" },
    kind = { "delete", "replace", "query" },
    quoteescape = true,
    expand_range = false,
    nesting = false,
    input = { "q" },
    regex = 1,
  },
}

return M
