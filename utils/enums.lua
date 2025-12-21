--@name wgui/u/enums


-- Создание новых enum таблиц
DOCK = {
    NODOCK = 0,
    FILL = 1,
    LEFT = 2,
    TOP = 3,
    RIGHT = 4,
    BOTTOM = 5,
}

RENDERSPACE = {
    HUD = 0,
    SCREEN = 1,
    WORLD = 2,
}

RENDERSPACENAME = {}
RENDERSPACENAME[ RENDERSPACE.HUD ] = "renderSpaceHUD"
RENDERSPACENAME[ RENDERSPACE.SCREEN ] = "renderSpaceScreen"
RENDERSPACENAME[ RENDERSPACE.WORLD ] = "renderSpaceWorld"

OVERFLOW = {
    VISIBLE = 0,
    HIDDEN = 1,
}

WGUIEVENTS = {
    -- click
    CLICK = "click",
    RIGHTCLICK = "rightclick",
    DOUBLECLICK = "doubleclick",
    HOVERCLICK = "hoverclick",
    HOVERCLICKDELAYED = "hoverclickdelayed",

    -- hover
    HOVER = "hover",
    HOVERON = "hoveron",
    HOVEROFF = "hoveroff",

    -- cursor ( renderspace only )
    CURSORMOVED = "cursormoved",

    -- element
    VALUECHANGED = "valuechanged",
    REMOVED = "removed",
}
