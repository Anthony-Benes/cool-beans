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

CoolBeans.palette = {
    dark0_hard        = "#020401",
    dark0             = "#0a1505",
    dark0_soft        = "#0d1d07",
    dark1             = "#13290a",
    dark2             = "#19350d",
    dark3             = "#1f3d0f",
    dark4             = "#234511",
    light0_hard       = "#f5fcf3",
    light0            = "#e3e8e3",
    light0_soft       = "#dff5d6",
    light1            = "#d3f2ca",
    light2            = "#c1edb5",
    light3            = "#b1e8a1",
    light4            = "#a0e38c",
    bright_red        = "#d45230",
    bright_green      = "#6bd03e",
    bright_yellow     = "#d7d242",
    bright_blue       = "#4291d7",
    bright_purple     = "#ba33d5",
    bright_cyan       = "#3ed5d3",
    bright_orange     = "#d9943b",
    neutral_red       = "#93371f",
    neutral_green     = "#489725",
    neutral_yellow    = "#a4a023",
    neutral_blue      = "#2368a4",
    neutral_purple    = "#841f98",
    neutral_cyan      = "#239f9d",
    neutral_orange    = "#a36a1f",
    faded_red         = "#4f1d11",
    faded_green       = "#285515",
    faded_yellow      = "#605e15",
    faded_blue        = "#153e60",
    faded_purple      = "#491154",
    faded_cyan        = "#155d5b",
    faded_orange      = "#5f3e12",
    dark_blue_hard    = "#0e283f",
    dark_blue         = "#0e283f",
    dark_blue_soft    = "#0e283f",
    dark_purple_hard  = "#2c0a32",
    dark_purple       = "#2c0a32",
    dark_purple_soft  = "#2c0a32",
    dark_red_hard     = "#2d110a",
    dark_red          = "#2d110a",
    dark_red_soft     = "#2d110a",
    light_blue_hard   = "#4e99da",
    light_blue        = "#64a5de",
    light_blue_soft   = "#78b1e2",
    light_purple_hard = "#bf41d8",
    light_purple      = "#c555dc",
    light_purple_soft = "#cd6be1",
    light_red_hard    = "#d75b3c",
    light_red         = "#db6e52",
    light_red_soft    = "#e07f67",
    gray              = "#38761d",
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
            fg0 = p.light0,
            fg1 = p.light1,
            fg2 = p.light2,
            fg3 = p.light3,
            fg4 = p.light4,
            red = p.bright_red,
            green = p.bright_green,
            yellow = p.bright_yellow,
            blue = p.bright_blue,
            purple = p.bright_purple,
            aqua = p.bright_cyan,
            orange = p.bright_orange,
            neutral_red = p.neutral_red,
            neutral_green = p.neutral_green,
            neutral_yellow = p.neutral_yellow,
            neutral_blue = p.neutral_blue,
            neutral_purple = p.neutral_purple,
            neutral_aqua = p.neutral_cyan,
            dark_blue = p.dark_blue,
            dark_purple = p.dark_purple,
            dark_red = p.dark_red,
            gray = p.gray,
        },
        light = {
            bg0 = p.light0,
            bg1 = p.light1,
            bg2 = p.light2,
            bg3 = p.light3,
            bg4 = p.light4,
            fg0 = p.dark0,
            fg1 = p.dark1,
            fg2 = p.dark2,
            fg3 = p.dark3,
            fg4 = p.dark4,
            red = p.faded_red,
            green = p.faded_green,
            yellow = p.faded_yellow,
            blue = p.faded_blue,
            purple = p.faded_purple,
            aqua = p.faded_cyan,
            orange = p.faded_orange,
            neutral_red = p.neutral_red,
            neutral_green = p.neutral_green,
            neutral_yellow = p.neutral_yellow,
            neutral_blue = p.neutral_blue,
            neutral_purple = p.neutral_purple,
            neutral_aqua = p.neutral_cyan,
            dark_blue = p.light_blue,
            dark_purple = p.light_purple,
            dark_red = p.light_red,
            gray = p.gray,
        },
    }
    
    if contrast ~= nil and contrast ~= "" then
        color_groups[bg].bg0 = p[bg .. "0_" .. contrast]
        color_groups[bg].dark_blue = p[bg .. "_blue_" .. contrast]
        color_groups[bg].dark_purple = p[bg .. "_purple_" .. contrast]
        color_groups[bg].dark_red = p[bg .. "_red_" .. contrast]
    end
    
    return color_groups[bg]
end

local function get_groups()
    local colors = get_colors()
    local config = CoolBeans.config
    if config.terminal_colors then
        local term_colors = {
            colors.bg0,
            colors.neutral_red,
            colors.neutral_green,
            colors.neutral_yellow,
            colors.neutral_blue,
            colors.neutral_purple,
            colors.neutral_aqua,
            colors.fg4,
            colors.gray,
            colors.red,
            colors.green,
            colors.yellow,
            colors.blue,
            colors.purple,
            colors.aqua,
            colors.fg1,
        }
        for index, value in ipairs(term_colors) do
            vim.g["terminal_color_" .. index - 1] = value
        end
    end
    
    local groups = {
        CoolBeansFg0 = { fg = colors.fg0 },
        CoolBeansFg1 = { fg = colors.fg1 },
        CoolBeansFg2 = { fg = colors.fg2 },
        CoolBeansFg3 = { fg = colors.fg3 },
        CoolBeansFg4 = { fg = colors.fg4 },
        CoolBeansGray = { fg = colors.gray },
        CoolBeansBg0 = { fg = colors.bg0 },
        CoolBeansBg1 = { fg = colors.bg1 },
        CoolBeansBg2 = { fg = colors.bg2 },
        CoolBeansBg3 = { fg = colors.bg3 },
        CoolBeansBg4 = { fg = colors.bg4 },
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
        CoolBeansAqua = { fg = colors.aqua },
        CoolBeansAquaBold = { fg = colors.aqua, bold = config.bold },
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
        CoolBeansAquaSign = config.transparent_mode and { fg = colors.aqua, reverse = config.invert_signs }
            or { fg = colors.aqua, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansOrangeSign = config.transparent_mode and { fg = colors.orange, reverse = config.invert_signs }
            or { fg = colors.orange, bg = colors.bg1, reverse = config.invert_signs },
        CoolBeansRedUnderline = { undercurl = config.undercurl, sp = colors.red },
        CoolBeansGreenUnderline = { undercurl = config.undercurl, sp = colors.green },
        CoolBeansYellowUnderline = { undercurl = config.undercurl, sp = colors.yellow },
        CoolBeansBlueUnderline = { undercurl = config.undercurl, sp = colors.blue },
        CoolBeansPurpleUnderline = { undercurl = config.undercurl, sp = colors.purple },
        CoolBeansAquaUnderline = { undercurl = config.undercurl, sp = colors.aqua },
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
        NonText = { link = "CoolBeansBg2" },
        SpecialKey = { link = "CoolBeansFg4" },
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
        PreProc = { link = "CoolBeansAqua" },
        Include = { link = "CoolBeansAqua" },
        Define = { link = "CoolBeansAqua" },
        Macro = { link = "CoolBeansAqua" },
        PreCondit = { link = "CoolBeansAqua" },
        Constant = { link = "CoolBeansPurple" },
        Character = { link = "CoolBeansPurple" },
        String = { fg = colors.green, italic = config.italic.strings },
        Boolean = { link = "CoolBeansPurple" },
        Number = { link = "CoolBeansPurple" },
        Float = { link = "CoolBeansPurple" },
        Type = { link = "CoolBeansYellow" },
        StorageClass = { link = "CoolBeansOrange" },
        Structure = { link = "CoolBeansAqua" },
        Typedef = { link = "CoolBeansYellow" },
        Pmenu = { fg = colors.fg1, bg = colors.bg2 },
        PmenuSel = { fg = colors.bg2, bg = colors.blue, bold = config.bold },
        PmenuSbar = { bg = colors.bg2 },
        PmenuThumb = { bg = colors.bg4 },
        DiffDelete = { bg = colors.dark_blue },
        DiffAdd = { bg = colors.dark_purple },
        DiffChange = { bg = colors.dark_red },
        DiffText = { bg = colors.yellow, fg = colors.bg0 },
        SpellCap = { link = "CoolBeansBlueUnderline" },
        SpellBad = { link = "CoolBeansRedUnderline" },
        SpellLocal = { link = "CoolBeansAquaUnderline" },
        SpellRare = { link = "CoolBeansPurpleUnderline" },
        Whitespace = { fg = colors.bg2 },
        Delimiter = { link = "CoolBeansOrange" },
        EndOfBuffer = { link = "NonText" },
        DiagnosticError = { link = "CoolBeansRed" },
        DiagnosticWarn = { link = "CoolBeansYellow" },
        DiagnosticInfo = { link = "CoolBeansBlue" },
        DiagnosticHint = { link = "CoolBeansAqua" },
        DiagnosticOk = { link = "CoolBeansGreen" },
        DiagnosticSignError = { link = "CoolBeansRedSign" },
        DiagnosticSignWarn = { link = "CoolBeansYellowSign" },
        DiagnosticSignInfo = { link = "CoolBeansBlueSign" },
        DiagnosticSignHint = { link = "CoolBeansAquaSign" },
        DiagnosticSignOk = { link = "CoolBeansGreenSign" },
        DiagnosticUnderlineError = { link = "CoolBeansRedUnderline" },
        DiagnosticUnderlineWarn = { link = "CoolBeansYellowUnderline" },
        DiagnosticUnderlineInfo = { link = "CoolBeansBlueUnderline" },
        DiagnosticUnderlineHint = { link = "CoolBeansAquaUnderline" },
        DiagnosticUnderlineOk = { link = "CoolBeansGreenUnderline" },
        DiagnosticFloatingError = { link = "CoolBeansRed" },
        DiagnosticFloatingWarn = { link = "CoolBeansOrange" },
        DiagnosticFloatingInfo = { link = "CoolBeansBlue" },
        DiagnosticFloatingHint = { link = "CoolBeansAqua" },
        DiagnosticFloatingOk = { link = "CoolBeansGreen" },
        DiagnosticVirtualTextError = { link = "CoolBeansRed" },
        DiagnosticVirtualTextWarn = { link = "CoolBeansYellow" },
        DiagnosticVirtualTextInfo = { link = "CoolBeansBlue" },
        DiagnosticVirtualTextHint = { link = "CoolBeansAqua" },
        DiagnosticVirtualTextOk = { link = "CoolBeansGreen" },
        TelescopeNormal = { link = "CoolBeansFg1" },
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
        ["@variable"] = { link = "CoolBeansFg1" },
        ["@variable.builtin"] = { link = "Special" },
        ["@variable.member"] = { link = "Identifier" },
        ["@variable.parameter"] = { link = "Identifier" },
        ["@constant"] = { link = "Constant" },
        ["@constant.builtin"] = { link = "Special" },
        ["@constant.macro"] = { link = "Define" },
        ["@markup"] = { link = "CoolBeansFg1" },
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
        ["@module"] = { link = "CoolBeansFg1" },
        ["@namespace"] = { link = "CoolBeansFg1" },
        ["@symbol"] = { link = "Identifier" },
        ["@text"] = { link = "CoolBeansFg1" },
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
