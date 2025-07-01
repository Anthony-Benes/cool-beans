---@class CoolBeans
---@field config CoolBeansConfig
---@field palette CoolBeansPalette
local CoolBeans = {}
---@alias Contrast "hard" | "soft" | ""
---@class ItalicConfig
---@field strings boolean
---@field comments boolean
---@field operators boolean
---@field folds boolean
---@field emphasis boolean

---@class HighlightDefinition
---@field fg string?
---@field bg string?
---@field sp string?
---@field blend integer?
---@field bold boolean?
---@field standout boolean?
---@field underline boolean?
---@field undercurl boolean?
---@field underdouble boolean?
---@field underdotted boolean?
---@field strikethrough boolean?
---@field italic boolean?
---@field reverse boolean?
---@field nocombine boolean?

---@class CoolBeansConfig
---@field bold boolean?
---@field contrast Contrast?
---@field dim_inactive boolean?
---@field inverse boolean?
---@field invert_selection boolean?
---@field invert_signs boolean?
---@field invert_tabline boolean?
---@field italic ItalicConfig?
---@field overrides table<string, HighlightDefinition>?
---@field palette_overrides table<string, string>?
---@field strikethrough boolean?
---@field terminal_colors boolean?
---@field transparent_mode boolean?
---@field undercurl boolean?
---@field underline boolean?
local default_config = {
    terminal_colors = true,
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = true,
        folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    inverse = true,
    contrast = "",
    palette_overrides = {},
    overrides = {},
    dim_inactive = true,
    transparent_mode = true,
}
CoolBeans.config = vim.deepcopy(default_config)

local function min(a, b)
    return a < b and a or b
end
local function max(a, b)
    return a > b and a or b
end
local function hsl_to_rgb(h, s, l)
    while(h < 0) do
        h = h + 360
    end
    h = h % 360
    s = max(min(s, 100), 0)
    l = max(min(l, 100), 0)
    h = h / 360
    s = s / 100
    l = l / 100
    if (s == 0) then
        local rgb = math.floor(l * 255)
        return rgb, rgb, rgb
    end
    local function h_to_rgb(p, q, t)
        if (t < 0) then t = t + 1 end
        if (t > 1) then t = t - 1 end
        if (t < 1/6 ) then return p + ((q - p) * 6 * t) end
        if (t < 0.5) then return q end
        if (t < 2/3) then return p + ((q - p) * (2/3 - t) * 6) end
        return p
    end
    local q = (l < 0.5) and l * (1 + s) or (l + s - (l * s))
    p = (2 * l) - q
    local r = h_to_rgb(p, q, (h + 1/3))
    local g = h_to_rgb(p, q, h)
    local b = h_to_rgb(p, q, (h - 1/3))
    return math.floor(0.5 + (r * 255)), math.floor(0.5 + (g * 255)), math.floor(0.5 + (b * 255))
end
local function m_color(h, s, l)
    r, g, b = hsl_to_rgb(h, s, l)
    return string.format("#%02x%02x%02x", r, g, b)
end
CoolBeans.palette = {
    dark0          = m_color(110, 10, 5),
    dark1          = m_color(110, 10, 10),
    dark2          = m_color(110, 10, 15),
    dark3          = m_color(110, 10, 20),
    dark4          = m_color(110, 10, 25),
    dark5          = m_color(110, 10, 30),
    light0         = m_color(110, 10, 85),
    light1         = m_color(110, 10, 80),
    light2         = m_color(110, 10, 75),
    light3         = m_color(110, 10, 70),
    light4         = m_color(110, 10, 65),
    light5         = m_color(110, 10, 60),
    light_gray     = m_color(110, 10, 50),
    gray           = m_color(110, 10, 40),
    dark_gray      = m_color(110, 10, 35),
    v_light_red    = m_color(  0, 50, 80),
    v_light_orange = m_color( 32, 50, 80),
    v_light_yellow = m_color( 57, 50, 80),
    v_light_green  = m_color(110, 50, 80),
    v_light_cyan   = m_color(182, 50, 80),
    v_light_blue   = m_color(230, 50, 80),
    v_light_purple = m_color(285, 50, 80),
    light_red      = m_color(  0, 50, 65),
    light_orange   = m_color( 32, 50, 65),
    light_yellow   = m_color( 57, 50, 65),
    light_green    = m_color(110, 50, 65),
    light_cyan     = m_color(182, 50, 65),
    light_blue     = m_color(230, 50, 65),
    light_purple   = m_color(285, 50, 65),
    red            = m_color(  0, 50, 50),
    orange         = m_color( 32, 50, 50),
    yellow         = m_color( 57, 50, 50),
    green          = m_color(110, 50, 50),
    cyan           = m_color(182, 50, 50),
    blue           = m_color(230, 50, 50),
    purple         = m_color(285, 50, 50),
    dim_red        = m_color(  0, 50, 35),
    dim_orange     = m_color( 32, 50, 35),
    dim_yellow     = m_color( 57, 50, 35),
    dim_green      = m_color(110, 50, 35),
    dim_cyan       = m_color(182, 50, 35),
    dim_blue       = m_color(230, 50, 35),
    dim_purple     = m_color(285, 50, 35),
    dark_red       = m_color(  0, 50, 25),
    dark_orange    = m_color( 32, 50, 25),
    dark_yellow    = m_color( 57, 50, 25),
    dark_green     = m_color(110, 50, 25),
    dark_cyan      = m_color(182, 50, 25),
    dark_blue      = m_color(230, 50, 25),
    dark_purple    = m_color(285, 50, 25),
    v_dark_red     = m_color(  0, 50, 15),
    v_dark_orange  = m_color( 32, 50, 15),
    v_dark_yellow  = m_color( 57, 50, 15),
    v_dark_green   = m_color(110, 50, 15),
    v_dark_cyan    = m_color(182, 50, 15),
    v_dark_blue    = m_color(230, 50, 15),
    v_dark_purple  = m_color(285, 50, 15),
}

local function get_colors()
    local p = CoolBeans.palette
    local config = CoolBeans.config
    for color, hex in pairs(config.palette_overrides) do
        p[color] = hex
    end
    local bg = vim.o.background
    local contrast = config.contrast
    local color_groups = {
        dark = {
            bg0 = p.dark0,
            bg1 = p.dark1,
            bg2 = p.dark2,
            bg3 = p.dark3,
            bg4 = p.dark4,
            fg0 = p.light1,
            fg1 = p.light2,
            fg2 = p.light3,
            fg3 = p.light4,
            fg4 = p.light5,
            v_light_red = p.v_light_red,
            v_light_orange = p.v_light_orange,
            v_light_yellow = p.v_light_yellow,
            v_light_green = p.v_light_green,
            v_light_cyan = p.v_light_cyan,
            v_light_blue = p.v_light_blue,
            v_light_purple = p.v_light_purple,
            light_red = p.light_red,
            light_orange = p.light_orange,
            light_yellow = p.light_yellow,
            light_green = p.light_green,
            light_cyan = p.light_cyan,
            light_blue = p.light_blue,
            light_purple = p.light_purple,
            red = p.red,
            orange = p.orange,
            yellow = p.yellow,
            green = p.green,
            cyan = p.cyan,
            blue = p.blue,
            purple = p.purple,
            dark_red = p.dim_red,
            dark_orange = p.dim_orange,
            dark_yellow = p.dim_yellow,
            dark_green = p.dim_green,
            dark_cyan = p.dim_cyan,
            dark_blue = p.dim_blue,
            dark_purple = p.dim_purple,
            v_dark_red = p.dark_red,
            v_dark_orange = p.dark_orange,
            v_dark_yellow = p.dark_yellow,
            v_dark_green = p.dark_green,
            v_dark_cyan = p.dark_cyan,
            v_dark_blue = p.dark_blue,
            v_dark_purple = p.dark_purple,
            gray = p.gray,
            light_gray = p.light_gray,
        },
        light = {
            bg0 = p.light0,
            bg1 = p.light1,
            bg2 = p.light2,
            bg3 = p.light3,
            bg4 = p.light4,
            fg0 = p.dark1,
            fg1 = p.dark2,
            fg2 = p.dark3,
            fg3 = p.dark4,
            fg4 = p.dark5,
            v_light_red = p.v_dark_red,
            v_light_orange = p.v_dark_orange,
            v_light_yellow = p.v_dark_yellow,
            v_light_green = p.v_dark_green,
            v_light_cyan = p.v_dark_cyan,
            v_light_blue = p.v_dark_blue,
            v_light_purple = p.v_dark_purple,
            light_red = p.dark_red,
            light_orange = p.dark_orange,
            light_yellow = p.dark_yellow,
            light_green = p.dark_green,
            light_cyan = p.dark_cyan,
            light_blue = p.dark_blue,
            light_purple = p.dark_purple,
            red = p.dim_red,
            orange = p.dim_orange,
            yellow = p.dim_yellow,
            green = p.dim_green,
            cyan = p.dim_cyan,
            blue = p.dim_blue,
            purple = p.dim_purple,
            dark_red = p.red,
            dark_orange = p.orange,
            dark_yellow = p.yellow,
            dark_green = p.green,
            dark_cyan = p.cyan,
            dark_blue = p.blue,
            dark_purple = p.purple,
            v_dark_red = p.light_red,
            v_dark_orange = p.light_orange,
            v_dark_yellow = p.light_yellow,
            v_dark_green = p.light_green,
            v_dark_cyan = p.light_cyan,
            v_dark_blue = p.light_blue,
            v_dark_purple = p.light_purple,
            gray = p.dark_gray,
            light_gray = p.gray,
        },
    }
    return color_groups[bg]
end

local function get_groups()
    local colors = get_colors()
    local config = CoolBeans.config
    if config.terminal_colors then
        local term_colors = {
            colors.bg0,
            colors.red,
            colors.green,
            colors.yellow,
            colors.blue,
            colors.purple,
            colors.cyan,
            colors.fg4,
            colors.light_gray,
            colors.light_red,
            colors.light_green,
            colors.light_yellow,
            colors.light_blue,
            colors.light_purple,
            colors.light_cyan,
            colors.fg1,
        }
        for index, value in ipairs(term_colors) do
            vim.g["terminal_color_" .. index - 1] = value
        end
    end

    local defaultBg0 = config.transparent_mode and "NONE" or colors.bg0
    local defaultBg1 = config.transparent_mode and "NONE" or colors.bg1

    local groups = {
        CBfg0 = { fg = colors.fg0 },
        CBfg1 = { fg = colors.fg1 },
        CBfg2 = { fg = colors.fg2 },
        CBfg3 = { fg = colors.fg3 },
        CBfg4 = { fg = colors.fg4 },
        CBbg0 = { fg = colors.bg0 },
        CBbg1 = { fg = colors.bg1 },
        CBbg2 = { fg = colors.bg2 },
        CBbg3 = { fg = colors.bg3 },
        CBbg4 = { fg = colors.bg4 },
        CBGray = { fg = colors.gray },
        CBRed = { fg = colors.red },
        CBOrange = { fg = colors.orange },
        CBYellow = { fg = colors.yellow },
        CBGreen = { fg = colors.green },
        CBCyan = { fg = colors.cyan },
        CBBlue = { fg = colors.blue },
        CBPurple = { fg = colors.purple },
        CBGrayBold = { fg = colors.gray, bold = config.bold },
        CBRedBold = { fg = colors.red, bold = config.bold },
        CBOrangeBold = { fg = colors.orange, bold = config.bold },
        CBYellowBold = { fg = colors.yellow, bold = config.bold },
        CBGreenBold = { fg = colors.green, bold = config.bold },
        CBCyanBold = { fg = colors.cyan, bold = config.bold },
        CBBlueBold = { fg = colors.blue, bold = config.bold },
        CBPurpleBold = { fg = colors.purple, bold = config.bold },
        CBRedSign = { fg = colors.red, bg = defaultBg1, reverse = config.invert_signs },
        CBOrangeSign = { fg = colors.orange, bg = defaultBg1, reverse = config.invert_signs },
        CBYellowSign = { fg = colors.yellow, bg = defaultBg1, reverse = config.invert_signs },
        CBGreenSign = { fg = colors.green, bg = defaultBg1, reverse = config.invert_signs },
        CBCyanSign = { fg = colors.cyan, bg = defaultBg1, reverse = config.invert_signs },
        CBBlueSign = { fg = colors.blue, bg = defaultBg1, reverse = config.invert_signs },
        CBPurpleSign = { fg = colors.purple, bg = defaultBg1, reverse = config.invert_signs },
        CBRedUnderline = { undercurl = config.undercurl, sp = colors.red },
        CBOrangeUnderline = { undercurl = config.undercurl, sp = colors.orange },
        CBYellowUnderline = { undercurl = config.undercurl, sp = colors.yellow },
        CBGreenUnderline = { undercurl = config.undercurl, sp = colors.green },
        CBCyanUnderline = { undercurl = config.undercurl, sp = colors.cyan },
        CBBlueUnderline = { undercurl = config.undercurl, sp = colors.blue },
        CBPurpleUnderline = { undercurl = config.undercurl, sp = colors.purple },
        -- Builtin Highlight Groups
        ColorColumn = { bg = colors.bg1 },
        Conceal = { fg = colors.blue },
        CurSearch = { fg = colors.purple, bg = colors.fg3, reverse = config.inverse },
        Cursor = { reverse = config.inverse },
        vCursor = { link = "Cursor" },
        iCursor = { link = "Cursor" },
        lCursor = { link = "Cursor" },
        CursorLine = { bg = colors.bg1 },
        CursorColumn = { link = "CursorLine" },
        Directory = { link = "CBGreenBold" },
        DiffAdd = { bg = colors.v_dark_green },
        DiffChange = { bg = colors.v_dark_cyan },
        DiffDelete = { bg = colors.v_dark_red },
        DiffText = { bg = colors.yellow, fg = colors.bg0 },
        ErrorMsg = { fg = colors.bg0, bg = colors.light_red, bold = config.bold },
        WinSeparator =  { fg = colors.bg3, bg = defaultBg0 },
        Folded = { fg = colors.gray, bg = colors.bg1, italic = config.italic.folds },
        FoldColumn = { fg = colors.gray, bg = defaultBg1 },
        SignColumn = { bg = defaultBg1 },
        IncSearch = { link = "CurSearch" },
        Substitue = { fg = colors.dark_purple, bg = colors.light_yellow },
        LineNr = { fg = colors.bg4 },
        CursorLineNr = { fg = colors.yellow, bg = colors.bg1 },
        MatchParen = { bg = colors.bg4, bold = config.bold },
        ModeMsg = { link = "CBYellowBold" },
        MoreMsg = { link = "CBOrangeBold" },
        NonText = { link = "CBbg2" },
        EndOfBuffer = { link = "NonText" },
        Normal = { fg = colors.fg1, bg = defaultBg0 },
        NormalFloat = { fg = colors.fg1, bg = defaultBg1 },
        NormalNC = config.dim_inactive and { fg = colors.fg0, bg = defaultBg1 } or { link = "Normal" },
        Pmenu = { fg = colors.fg1, bg = colors.bg2 },
        PmenuSel = { fg = colors.bg2, bg = colors.green, bold = config.bold },
        PmenuSbar = { bg = colors.bg3 },
        PmenuThumb = { bg = colors.dark_green },
        Question = { link = "CBOrangeBold" },
        QuickFixLine = { link = "CBPurple" },
        Search = { fg = colors.light_yellow, bg = colors.v_dark_purple, reverse = config.inverse },
        SpecialKey = { link = "CBfg4" },
        SpellBad = { link = "CBRedUnderline" },
        SpellCap = { link = "CBBlueUnderline" },
        SpellLocal = { link = "CBCyanUnderline" },
        SpellRare = { link = "CBPurpleUnderline" },
        StatusLine = { fg = colors.fg1, bg = colors.v_dark_green },
        StatusLineNC = { fg = colors.fg4, bg = colors.bg1 },
        TabLineFill = { fg = colors.bg4, bg = colors.bg1, reverse = config.invert_tabline },
        TabLine = { link = "TabLineFill" },
        TabLineSel = { fg = colors.green, bg = colors.bg1, reverse = config.invert_tabline },
        Title = { link = "CBGreenBold" },
        Visual = { bg = colors.bg4, reverse = config.invert_selection },
        VisualNOS = { link = "Visual" },
        WarningMsg = { link = "CBRedBold" },
        Whitespace = { fg = colors.bg3 },
        WildMenu = { fg = colors.light_green, bg = colors.bg2, bold = config.bold },
        WinBar = { fg = colors.fg4, bg = colors.bg0 },
        WinBarNC = { fg = colors.fg3, bg = colors.bg1 },
        Menu = { link = "Pmenu" },
        Scrollbar = { fg = colors.dark_green },
        -- Custom Defined Groups
        diffAdded = { link = "DiffAdd" },
        diffRemoved = { link = "DiffDelete" },
        diffChanged = { link = "DiffChange" },
        diffFile = { link = "CBOrange" },
        diffNewFile = { link = "CBYellow" },
        diffOldFile = { link = "CBOrange" },
        diffLine = { link = "CBBlue" },
        diffIndexLine = { link = "diffChanged" },
        -- LSP Types
        Constant = { fg = colors.cyan },
        Character = { link = "Constant" },
        Number = { link = "Constant" },
        Boolean = { link = "Constant" },
        Float = { link = "Constant" },
        String = { fg = colors.light_cyan, italic = config.italic.strings },
        Identifier = { link = "CBGreen" },
        Function = { fg = colors.dark_green, bold = config.bold },
        Statement = { link = "CBPurple" },
        Conditional = { link = "Statement" },
        Repeat = { link = "Statement" },
        Label = { link = "Statement" },
        Operator = { fg = colors.orange, italic = config.italic.operators },
        Keyword = { link = "Statement" },
        Exception = { link = "Statement" },
        PreProc = { link = "CBBlue" },
        Include = { link = "PreProc" },
        Define = { link = "PreProc" },
        Macro = { link = "PreProc" },
        PreCondit = { link = "PreProc" },
        Type = { link = "CBYellow" },
        StorageClass = { fg = colors.light_orange },
        Structure = { fg = colors.light_yellow },
        Typedef = { link = "Type" },
        Special = { link = "CBOrange" },
        Delimiter = { link = "Special" },
        Debug = { link = "Special" },
        Underlined = { fg = colors.blue, underline = config.underline },
        Ignore = { link = "CBGray" },
        Error = { fg = colors.red, bold = config.bold, reverse = config.inverse },
        Todo = { fg = colors.bg0, bg = colors.yellow, bold = config.bold, italic = config.italic.comments },
        Comment = { fg = colors.gray, italic = config.italic.comments },
        Done = { fg = colors.orange, bold = config.bold, italic = config.italic.comments },
        DiagnosticError = { link = "CBRed" },
        DiagnosticWarn = { link = "CBYellow" },
        DiagnosticInfo = { link = "CBBlue" },
        DiagnosticHint = { link = "CBCyan" },
        DiagnosticOk = { link = "CBGreen" },
        DiagnosticSignError = { link = "CBRedSign" },
        DiagnosticSignWarn = { link = "CBYellowSign" },
        DiagnosticSignInfo = { link = "CBBlueSign" },
        DiagnosticSignHint = { link = "CBCyanSign" },
        DiagnosticSignOk = { link = "CBGreenSign" },
        DiagnosticUnderlineError = { link = "CBRedUnderline" },
        DiagnosticUnderlineWarn = { link = "CBYellowUnderline" },
        DiagnosticUnderlineInfo = { link = "CBBlueUnderline" },
        DiagnosticUnderlineHint = { link = "CBCyanUnderline" },
        DiagnosticUnderlineOk = { link = "CBGreenUnderline" },
        DiagnosticFloatingError = { link = "CBRed" },
        DiagnosticFloatingWarn = { link = "CBOrange" },
        DiagnosticFloatingInfo = { link = "CBBlue" },
        DiagnosticFloatingHint = { link = "CBCyan" },
        DiagnosticFloatingOk = { link = "CBGreen" },
        DiagnosticVirtualTextError = { link = "CBRed" },
        DiagnosticVirtualTextWarn = { link = "CBYellow" },
        DiagnosticVirtualTextInfo = { link = "CBBlue" },
        DiagnosticVirtualTextHint = { link = "CBCyan" },
        DiagnosticVirtualTextOk = { link = "CBGreen" },
        TelescopeNormal = { link = "CBfg1" },
        TelescopeSelection = { link = "CursorLine" },
        TelescopeSelectionCaret = { link = "CBGreen" },
        TelescopeMultiSelection = { link = "CBGray" },
        TelescopeBorder = { link = "TelescopeNormal" },
        TelescopePromptBorder = { link = "TelescopeNormal" },
        TelescopeResultsBorder = { link = "TelescopeNormal" },
        TelescopePreviewBorder = { link = "TelescopeNormal" },
        TelescopeMatching = { link = "CBCyan" },
        TelescopePromptPrefix = { link = "CBBlue" },
        TelescopePrompt = { link = "TelescopeNormal" },
        ["@comment"] = { link = "Comment" },
        ["@none"] = { bg = "NONE", fg = "NONE" },
        ["@preproc"] = { link = "PreProc" },
        ["@define"] = { link = "Define" },
        ["@operator"] = { link = "Operator" },
        ["@punctuation.delimiter"] = { link = "Delimiter" },
        ["@punctuation.bracket"] = { link = "Delimiter" },
        ["@punctuation.special"] = { link = "Delimiter" },
        ["@string"] = { link = "String" },
        ["@string.regex"] = { link = "String" },
        ["@string.regexp"] = { link = "String" },
        ["@string.escape"] = { link = "SpecialChar" },
        ["@string.special"] = { link = "SpecialChar" },
        ["@string.special.path"] = { link = "Underlined" },
        ["@string.special.symbol"] = { link = "Identifier" },
        ["@string.special.url"] = { link = "Underlined" },
        ["@character"] = { link = "Character" },
        ["@character.special"] = { link = "SpecialChar" },
        ["@boolean"] = { link = "Boolean" },
        ["@number"] = { link = "Number" },
        ["@number.float"] = { link = "Float" },
        ["@float"] = { link = "Float" },
        ["@function"] = { link = "Function" },
        ["@function.builtin"] = { link = "Special" },
        ["@function.call"] = { link = "Function" },
        ["@function.macro"] = { link = "Macro" },
        ["@function.method"] = { link = "Function" },
        ["@method"] = { link = "Function" },
        ["@method.call"] = { link = "Function" },
        ["@constructor"] = { link = "Special" },
        ["@parameter"] = { link = "Identifier" },
        ["@keyword"] = { link = "Keyword" },
        ["@keyword.conditional"] = { link = "Conditional" },
        ["@keyword.debug"] = { link = "Debug" },
        ["@keyword.directive"] = { link = "PreProc" },
        ["@keyword.directive.define"] = { link = "Define" },
        ["@keyword.exception"] = { link = "Exception" },
        ["@keyword.function"] = { link = "Function" },
        ["@keyword.import"] = { link = "Include" },
        ["@keyword.operator"] = { link = "Operator" },
        ["@keyword.repeat"] = { link = "Repeat" },
        ["@keyword.return"] = { link = "Keyword" },
        ["@keyword.storage"] = { link = "StorageClass" },
        ["@conditional"] = { link = "Conditional" },
        ["@repeat"] = { link = "Repeat" },
        ["@debug"] = { link = "Debug" },
        ["@label"] = { link = "Label" },
        ["@include"] = { link = "Include" },
        ["@exception"] = { link = "Exception" },
        ["@type"] = { link = "Type" },
        ["@type.builtin"] = { link = "Type" },
        ["@type.definition"] = { link = "Typedef" },
        ["@type.qualifier"] = { link = "Type" },
        ["@storageclass"] = { link = "StorageClass" },
        ["@attribute"] = { link = "PreProc" },
        ["@field"] = { link = "Identifier" },
        ["@property"] = { link = "Identifier" },
        ["@variable"] = { link = "Identifier" },
        ["@variable.builtin"] = { link = "Special" },
        ["@variable.member"] = { link = "Identifier" },
        ["@variable.parameter"] = { link = "Identifier" },
        ["@constant"] = { link = "Constant" },
        ["@constant.builtin"] = { link = "Special" },
        ["@constant.macro"] = { link = "Define" },
        ["@markup"] = { link = "CBfg1" },
        ["@markup.strong"] = { bold = config.bold },
        ["@markup.italic"] = { link = "@text.emphasis" },
        ["@markup.underline"] = { underline = config.underline },
        ["@markup.strikethrough"] = { strikethrough = config.strikethrough },
        ["@markup.heading"] = { link = "Title" },
        ["@markup.raw"] = { link = "String" },
        ["@markup.math"] = { link = "Special" },
        ["@markup.environment"] = { link = "Macro" },
        ["@markup.environment.name"] = { link = "Type" },
        ["@markup.link"] = { link = "Underlined" },
        ["@markup.link.label"] = { link = "SpecialChar" },
        ["@markup.list"] = { link = "Delimiter" },
        ["@markup.list.checked"] = { link = "CBGreen" },
        ["@markup.list.unchecked"] = { link = "CBGray" },
        ["@comment.todo"] = { link = "Todo" },
        ["@comment.note"] = { link = "SpecialComment" },
        ["@comment.warning"] = { link = "WarningMsg" },
        ["@comment.error"] = { link = "ErrorMsg" },
        ["@diff.plus"] = { link = "diffAdded" },
        ["@diff.minus"] = { link = "diffRemoved" },
        ["@diff.delta"] = { link = "diffChanged" },
        ["@module"] = { link = "CBfg1" },
        ["@namespace"] = { link = "CBfg1" },
        ["@symbol"] = { link = "Identifier" },
        ["@text"] = { link = "CBfg1" },
        ["@text.strong"] = { bold = config.bold },
        ["@text.emphasis"] = { italic = config.italic.emphasis },
        ["@text.underline"] = { underline = config.underline },
        ["@text.strike"] = { strikethrough = config.strikethrough },
        ["@text.title"] = { link = "Title" },
        ["@text.literal"] = { link = "String" },
        ["@text.uri"] = { link = "Underlined" },
        ["@text.math"] = { link = "Special" },
        ["@text.environment"] = { link = "Macro" },
        ["@text.environment.name"] = { link = "Type" },
        ["@text.reference"] = { link = "Constant" },
        ["@text.todo"] = { link = "Todo" },
        ["@text.todo.checked"] = { link = "CBGreen" },
        ["@text.todo.unchecked"] = { link = "CBGray" },
        ["@text.note"] = { link = "SpecialComment" },
        ["@text.note.comment"] = { fg = colors.purple, bold = config.bold },
        ["@text.warning"] = { link = "WarningMsg" },
        ["@text.danger"] = { link = "ErrorMsg" },
        ["@text.danger.comment"] = { fg = colors.fg0, bg = colors.red, bold = config.bold },
        ["@text.diff.add"] = { link = "diffAdded" },
        ["@text.diff.delete"] = { link = "diffRemoved" },
        ["@tag"] = { link = "Tag" },
        ["@tag.attribute"] = { link = "Identifier" },
        ["@tag.delimiter"] = { link = "Delimiter" },
        ["@punctuation"] = { link = "Delimiter" },
        ["@macro"] = { link = "Macro" },
        ["@structure"] = { link = "Structure" },
    }

    for group, hl in pairs(config.overrides) do
        if groups[group] then
            -- "link" should not mix with other configs (:h hi-link)
            groups[group].link = nil
        end
        groups[group] = vim.tbl_extend("force", groups[group] or {}, hl)
    end

    return groups
end

function CoolBeans.setup()
    CoolBeans.config = vim.deepcopy(default_config)
    CoolBeans.config = vim.tbl_deep_extend("force", CoolBeans.config, config or {})
    local groups = get_groups()
    for group, settings in pairs(groups) do
        vim.api.nvim_set_hl(0, group, settings)
    end
end

return CoolBeans
