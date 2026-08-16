-- carbonfox palette, adapted for base46 from EdenEast/nightfox.nvim
-- Installed but NOT active: switch via <leader>th or theme = "carbonfox"
local M = {}

M.base_30 = {
  white = "#f9fbff",
  darker_black = "#0c0c0c",
  black = "#161616", -- nvim bg
  black2 = "#252525",
  one_bg = "#252525",
  one_bg2 = "#353535",
  one_bg3 = "#3f3f3f",
  grey = "#535353",
  grey_fg = "#b6b8bb",
  grey_fg2 = "#8c8d8f",
  light_grey = "#7b7c7e",
  red = "#ee5396",
  baby_pink = "#ff7eb6",
  pink = "#ff91c1",
  line = "#1f1f1f", -- for lines like vertsplit
  green = "#25be6a",
  vibrant_green = "#46c880",
  nord_blue = "#78a9ff",
  blue = "#78a9ff",
  yellow = "#08bdba",
  sun = "#2dc7c4",
  purple = "#be95ff",
  dark_purple = "#a17ef2",
  teal = "#33b1ff",
  orange = "#3ddbd9",
  cyan = "#52bdff",
  statusline_bg = "#0c0c0c",
  lightbg = "#353535",
  pmenu_bg = "#78a9ff",
  folder_bg = "#78a9ff",
}

M.base_16 = {
  base00 = "#161616",
  base01 = "#0c0c0c",
  base02 = "#252525",
  base03 = "#353535",
  base04 = "#535353",
  base05 = "#f2f4f8",
  base06 = "#f9fbff",
  base07 = "#ffffff",
  base08 = "#ee5396",
  base09 = "#3ddbd9",
  base0A = "#08bdba",
  base0B = "#25be6a",
  base0C = "#33b1ff",
  base0D = "#78a9ff",
  base0E = "#be95ff",
  base0F = "#ff7eb6",
}

M.polish_hl = {
  ["@comment"] = { fg = "#6e6f70" },
  ["@variable"] = { fg = "#dfdfe0" },
  ["@function"] = { fg = "#8cb6ff" },
  ["@keyword"] = { fg = "#be95ff" },
  ["@type"] = { fg = "#08bdba" },
  ["@constant"] = { fg = "#5ae0df" },
  ["@number"] = { fg = "#3ddbd9" },
  ["@string"] = { fg = "#25be6a" },
  ["@operator"] = { fg = "#b6b8bb" },
  ["@property"] = { fg = "#78a9ff" },
  ["@conditional"] = { fg = "#c8a5ff" },
  ["@repeat"] = { fg = "#c8a5ff" },
  ["@preproc"] = { fg = "#ff91c1" },
  ["@variable.builtin"] = { fg = "#ee5396" },
}

M.type = "dark"

M = require("base46").override_theme(M, "carbonfox")

return M
