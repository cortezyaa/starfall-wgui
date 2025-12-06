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

OVERFLOW = {
    VISIBLE = 0,
    HIDDEN = 1,
}

WGUIEVENTS = {
    -- click events
    CLICK = "click",
    RIGHTCLICK = "rightclick",
    DOUBLECLICK = "doubleclick",
    HOVERCLICK = "hoverclick",

    -- hover events
    HOVER = "hover",
    HOVERON = "hoveron",
    HOVEROFF = "hoveroff",

    -- cursor events [ renderspace only ]
    CURSORMOVED = "cursormoved",

    -- value events
    VALUECHANGED = "valuechanged"
}
