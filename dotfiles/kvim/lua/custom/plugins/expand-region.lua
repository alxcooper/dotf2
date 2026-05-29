-- vim-expand-region - incrementally grow or shrink visual selections.
-- Default mappings:
--   + expands selection through text objects (word, quotes, parens, blocks)
--   _ shrinks it back
return {
  {
    'terryma/vim-expand-region',
    lazy = false,
    init = function()
      vim.g.expand_region_text_objects_ruby = {
        ie = 0,
        ip = 0,
        iw = 0,
        iB = 1,
        il = 0,
        iW = 0,
        ["i'"] = 0,
        ib = 1,
        ['i]'] = 1,
        ['i"'] = 0,
        im = 0,
        am = 0,
      }
    end,
  },
}
