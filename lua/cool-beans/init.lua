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
        operators = false,
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
    dim_inactive = false,
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
    
    local groups = {
        CoolBeansfg0 = { fg = colors.fg0 },
        CoolBeansfg1 = { fg = colors.fg1 },
        CoolBeansfg2 = { fg = colors.fg2 },
        CoolBeansfg3 = { fg = colors.fg3 },
        CoolBeansfg4 = { fg = colors.fg4 },
        CoolBeansGray = { fg = colors.gray },
        CoolBeansbg0 = { fg = colors.bg0 },
        CoolBeansbg1 = { fg = colors.bg1 },
        CoolBeansbg2 = { fg = colors.bg2 },
        CoolBeansbg3 = { fg = colors.bg3 },
        CoolBeansbg4 = { fg = colors.bg4 },
        CoolBeansRed = { fg = colors.red },
        CoolBeansRedBold = { fg = colors.red, bold = config.bold },
        CoolBeansGreen = { fg = colors.green },
        CoolBeansGreenBold = { fg = colors.green, bold = config.bold },
        CoolBeansYellow = { fg = colors.yellow },
        CoolBeansYellowBold = { fg = colors.yellow, bold = config.bold },
        CoolBeansBlue = { fg = colors.blue },
        CoolBeansBlueBold = { fg = colors.blue, bold = config.bold },
        CoolBeansPurple = { fg = colors.purple },
        CoolBeansPurpleBold = { fg = colors.purple, bold = config.bold },
        CoolBeanscyan = { fg = colors.cyan },
        CoolBeanscyanBold = { fg = colors.cyan, bold = config.bold },
        CoolBeansOrange = { fg = colors.orange },
        CoolBeansOrangeBold = { fg = colors.orange, bold = config.bold },
        CoolBeansRedSign = config.transparent_mode and { fg = colors.red, reverse = config.invert_signs }
            or { fg = colors.red, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansGreenSign = config.transparent_mode and { fg = colors.green, reverse = config.invert_signs }
            or { fg = colors.green, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansYellowSign = config.transparent_mode and { fg = colors.yellow, reverse = config.invert_signs }
            or { fg = colors.yellow, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansBlueSign = config.transparent_mode and { fg = colors.blue, reverse = config.invert_signs }
            or { fg = colors.blue, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansPurpleSign = config.transparent_mode and { fg = colors.purple, reverse = config.invert_signs }
            or { fg = colors.purple, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeanscyanSign = config.transparent_mode and { fg = colors.cyan, reverse = config.invert_signs }
            or { fg = colors.cyan, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansOrangeSign = config.transparent_mode and { fg = colors.orange, reverse = config.invert_signs }
            or { fg = colors.orange, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansRedUnderline = { undercurl = config.undercurl, sp = colors.red },
        CoolBeansGreenUnderline = { undercurl = config.undercurl, sp = colors.green },
        CoolBeansYellowUnderline = { undercurl = config.undercurl, sp = colors.yellow },
        CoolBeansBlueUnderline = { undercurl = config.undercurl, sp = colors.blue },
        CoolBeansPurpleUnderline = { undercurl = config.undercurl, sp = colors.purple },
        CoolBeanscyanUnderline = { undercurl = config.undercurl, sp = colors.cyan },
        CoolBeansOrangeUnderline = { undercurl = config.undercurl, sp = colors.orange },
        Normal = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg0 },
        NormalFloat = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg1 },
        NormalNC = config.dim_inactive and { fg = colors.fg0, bg = colors.bg1 } or { link = "Normal" },
        CursorLine = { bg = colors.bg1 },
        CursorColumn = { link = "CursorLine" },
        TabLineFill = { fg = colors.bg4, bg = colors.bg1, reverse = config.invert_tabline },
        TabLineSel = { fg = colors.green, bg = colors.bg1, reverse = config.invert_tabline },
        TabLine = { link = "TabLineFill" },
        MatchParen = { bg = colors.bg3, bold = config.bold },
        ColorColumn = { bg = colors.bg1 },
        Conceal = { fg = colors.blue },
        CursorLineNr = { fg = colors.yellow, bg = colors.bg1 },
        NonText = { link = "CoolBeansbg2" },
        SpecialKey = { link = "CoolBeansfg4" },
        Visual = { bg = colors.bg3, reverse = config.invert_selection },
        VisualNOS = { link = "Visual" },
        Search = { fg = colors.yellow, bg = colors.bg0, reverse = config.inverse },
        IncSearch = { fg = colors.orange, bg = colors.bg0, reverse = config.inverse },
        CurSearch = { link = "IncSearch" },
        QuickFixLine = { link = "CoolBeansPurple" },
        Underlined = { fg = colors.blue, underline = config.underline },
        StatusLine = { fg = colors.fg1, bg = colors.bg2 },
        StatusLineNC = { fg = colors.fg4, bg = colors.bg1 },
        WinBar = { fg = colors.fg4, bg = colors.bg0 },
        WinBarNC = { fg = colors.fg3, bg = colors.bg1 },
        WinSeparator = config.transparent_mode and { fg = colors.bg3, bg = nil } or { fg = colors.bg3, bg = colors.bg0 },
        WildMenu = { fg = colors.blue, bg = colors.bg2, bold = config.bold },
        Directory = { link = "CoolBeansGreenBold" },
        Title = { link = "CoolBeansGreenBold" },
        ErrorMsg = { fg = colors.bg0, bg = colors.red, bold = config.bold },
        MoreMsg = { link = "CoolBeansYellowBold" },
        ModeMsg = { link = "CoolBeansYellowBold" },
        Question = { link = "CoolBeansOrangeBold" },
        WarningMsg = { link = "CoolBeansRedBold" },
        LineNr = { fg = colors.bg4 },
        SignColumn = config.transparent_mode and { bg = nil } or { bg = colors.bg1 },
        Folded = { fg = colors.gray, bg = colors.bg1, italic = config.italic.folds },
        FoldColumn = config.transparent_mode and { fg = colors.gray, bg = nil } or { fg = colors.gray, bg = colors.bg1 },
        Cursor = { reverse = config.inverse },
        vCursor = { link = "Cursor" },
        iCursor = { link = "Cursor" },
        lCursor = { link = "Cursor" },
        Special = { link = "CoolBeansOrange" },
        Comment = { fg = colors.gray, italic = config.italic.comments },
        Todo = { fg = colors.bg0, bg = colors.yellow, bold = config.bold, italic = config.italic.comments },
        Done = { fg = colors.orange, bold = config.bold, italic = config.italic.comments },
        Error = { fg = colors.red, bold = config.bold, reverse = config.inverse },
        Statement = { link = "CoolBeansRed" },
        Conditional = { link = "CoolBeansRed" },
        Repeat = { link = "CoolBeansRed" },
        Label = { link = "CoolBeansRed" },
        Exception = { link = "CoolBeansRed" },
        Operator = { fg = colors.orange, italic = config.italic.operators },
        Keyword = { link = "CoolBeansRed" },
        Identifier = { link = "CoolBeansBlue" },
        Function = { link = "CoolBeansGreenBold" },
        PreProc = { link = "CoolBeanscyan" },
        Include = { link = "CoolBeanscyan" },
        Define = { link = "CoolBeanscyan" },
        Macro = { link = "CoolBeanscyan" },
        PreCondit = { link = "CoolBeanscyan" },
        Constant = { link = "CoolBeansPurple" },
        Character = { link = "CoolBeansPurple" },
        String = { fg = colors.green, italic = config.italic.strings },
        Boolean = { link = "CoolBeansPurple" },
        Number = { link = "CoolBeansPurple" },
        Float = { link = "CoolBeansPurple" },
        Type = { link = "CoolBeansYellow" },
        StorageClass = { link = "CoolBeansOrange" },
        Structure = { link = "CoolBeanscyan" },
        Typedef = { link = "CoolBeansYellow" },
        Pmenu = { fg = colors.fg1, bg = colors.bg2 },
        PmenuSel = { fg = colors.bg2, bg = colors.blue, bold = config.bold },
        PmenuSbar = { bg = colors.bg2 },
        PmenuThumb = { bg = colors.bg4 },
        DiffDelete = { bg = colors.v_dark_blue },
        DiffAdd = { bg = colors.v_dark_purple },
        DiffChange = { bg = colors.v_dark_red },
        DiffText = { bg = colors.yellow, fg = colors.bg0 },
        SpellCap = { link = "CoolBeansBlueUnderline" },
        SpellBad = { link = "CoolBeansRedUnderline" },
        SpellLocal = { link = "CoolBeanscyanUnderline" },
        SpellRare = { link = "CoolBeansPurpleUnderline" },
        Whitespace = { fg = colors.bg2 },
        Delimiter = { link = "CoolBeansOrange" },
        EndOfBuffer = { link = "NonText" },
        DiagnosticError = { link = "CoolBeansRed" },
        DiagnosticWarn = { link = "CoolBeansYellow" },
        DiagnosticInfo = { link = "CoolBeansBlue" },
        DiagnosticHint = { link = "CoolBeanscyan" },
        DiagnosticOk = { link = "CoolBeansGreen" },
        DiagnosticSignError = { link = "CoolBeansRedSign" },
        DiagnosticSignWarn = { link = "CoolBeansYellowSign" },
        DiagnosticSignInfo = { link = "CoolBeansBlueSign" },
        DiagnosticSignHint = { link = "CoolBeanscyanSign" },
        DiagnosticSignOk = { link = "CoolBeansGreenSign" },
        DiagnosticUnderlineError = { link = "CoolBeansRedUnderline" },
        DiagnosticUnderlineWarn = { link = "CoolBeansYellowUnderline" },
        DiagnosticUnderlineInfo = { link = "CoolBeansBlueUnderline" },
        DiagnosticUnderlineHint = { link = "CoolBeanscyanUnderline" },
        DiagnosticUnderlineOk = { link = "CoolBeansGreenUnderline" },
        DiagnosticFloatingError = { link = "CoolBeansRed" },
        DiagnosticFloatingWarn = { link = "CoolBeansOrange" },
        DiagnosticFloatingInfo = { link = "CoolBeansBlue" },
        DiagnosticFloatingHint = { link = "CoolBeanscyan" },
        DiagnosticFloatingOk = { link = "CoolBeansGreen" },
        DiagnosticVirtualTextError = { link = "CoolBeansRed" },
        DiagnosticVirtualTextWarn = { link = "CoolBeansYellow" },
        DiagnosticVirtualTextInfo = { link = "CoolBeansBlue" },
        DiagnosticVirtualTextHint = { link = "CoolBeanscyan" },
        DiagnosticVirtualTextOk = { link = "CoolBeansGreen" },
        TelescopeNormal = { link = "CoolBeansfg1" },
        TelescopeSelection = { link = "CursorLine" },
        TelescopeSelectionCaret = { link = "CoolBeansRed" },
        TelescopeMultiSelection = { link = "CoolBeansGray" },
        TelescopeBorder = { link = "TelescopeNormal" },
        TelescopePromptBorder = { link = "TelescopeNormal" },
        TelescopeResultsBorder = { link = "TelescopeNormal" },
        TelescopePreviewBorder = { link = "TelescopeNormal" },
        TelescopeMatching = { link = "CoolBeansOrange" },
        TelescopePromptPrefix = { link = "CoolBeansRed" },
        TelescopePrompt = { link = "TelescopeNormal" },
        diffAdded = { link = "DiffAdd" },
        diffRemoved = { link = "DiffDelete" },
        diffChanged = { link = "DiffChange" },
        diffFile = { link = "CoolBeansOrange" },
        diffNewFile = { link = "CoolBeansYellow" },
        diffOldFile = { link = "CoolBeansOrange" },
        diffLine = { link = "CoolBeansBlue" },
        diffIndexLine = { link = "diffChanged" },
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
        ["@keyword.function"] = { link = "Keyword" },
        ["@keyword.import"] = { link = "Include" },
        ["@keyword.operator"] = { link = "CoolBeansRed" },
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
        ["@variable"] = { link = "CoolBeansfg1" },
        ["@variable.builtin"] = { link = "Special" },
        ["@variable.member"] = { link = "Identifier" },
        ["@variable.parameter"] = { link = "Identifier" },
        ["@constant"] = { link = "Constant" },
        ["@constant.builtin"] = { link = "Special" },
        ["@constant.macro"] = { link = "Define" },
        ["@markup"] = { link = "CoolBeansfg1" },
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
        ["@markup.list.checked"] = { link = "CoolBeansGreen" },
        ["@markup.list.unchecked"] = { link = "CoolBeansGray" },
        ["@comment.todo"] = { link = "Todo" },
        ["@comment.note"] = { link = "SpecialComment" },
        ["@comment.warning"] = { link = "WarningMsg" },
        ["@comment.error"] = { link = "ErrorMsg" },
        ["@diff.plus"] = { link = "diffAdded" },
        ["@diff.minus"] = { link = "diffRemoved" },
        ["@diff.delta"] = { link = "diffChanged" },
        ["@module"] = { link = "CoolBeansfg1" },
        ["@namespace"] = { link = "CoolBeansfg1" },
        ["@symbol"] = { link = "Identifier" },
        ["@text"] = { link = "CoolBeansfg1" },
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
        ["@text.todo.checked"] = { link = "CoolBeansGreen" },
        ["@text.todo.unchecked"] = { link = "CoolBeansGray" },
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
