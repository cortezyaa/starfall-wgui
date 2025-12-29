--@name wgui/u/enums

-- Создание новых таблиц
KEYBOARD = {}

for k, v in pairs( KEY ) do
    if #k == 1 then
        KEYBOARD[ "u" .. tostring( v ) ] = string.upper( k )
        KEYBOARD[ tostring( v ) ] = string.lower( k )
    end
end

KEYBOARD[ "u1" ] = ")"
KEYBOARD[ "u2" ] = "!"
KEYBOARD[ "u3" ] = "@"
KEYBOARD[ "u4" ] = "#"
KEYBOARD[ "u5" ] = "$"
KEYBOARD[ "u6" ] = "%"
KEYBOARD[ "u7" ] = "^"
KEYBOARD[ "u8" ] = "&"
KEYBOARD[ "u9" ] = "*"
KEYBOARD[ "u10" ] = "("
KEYBOARD[ "u53" ] = "{"
KEYBOARD[ "u54" ] = "}"
KEYBOARD[ "55" ] = ";"
KEYBOARD[ "u55" ] = ":"
KEYBOARD[ "u56" ] = "\""
KEYBOARD[ "u58" ] = "<"
KEYBOARD[ "u59" ] = ">"
KEYBOARD[ "u60" ] = "?"
KEYBOARD[ "u61" ] = "|"
KEYBOARD[ "u62" ] = "_"
KEYBOARD[ "u63" ] = "+"
KEYBOARD[ "64" ] = "ENTER"
KEYBOARD[ "u64" ] = "ENTER"
KEYBOARD[ "65" ] = " "
KEYBOARD[ "u65" ] = " "
KEYBOARD[ "66" ] = "BACKSPACE"
KEYBOARD[ "u66" ] = "BACKSPACE"

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
    CLICKRELEASE = "clickrelease",
    RIGHTCLICK = "rightclick",
    DOUBLECLICK = "doubleclick",
    HOVERCLICK = "hoverclick",
    HOVERCLICKDELAYED = "hoverclickdelayed",

    -- hover
    HOVER = "hover",
    HOVERON = "hoveron",
    HOVEROFF = "hoveroff",

    -- focus
    FOCUSON = "focuson",
    FOCUSOFF = "focusoff",

    -- element
    VALUECHANGED = "valuechanged",
    REMOVED = "removed",
    CHILDRENADDED = "childrenadded",
    CHILDRENREMOVED = "childrenremoved",
    
    -- renderSpace
    CURSORMOVED = "cursormoved",
    HOVERCHANGED = "hoverchanged",
    FOCUSCHANGED = "focuschanged",
}


--[[
KEY TABLE

4	=	5
S	=	29
.	=	59
PAGEDOWN	=	77
KP_PLUS	=	50
KP_PGUP	=	46
PGUP	=	76
F7	=	98
U	=	31
ALT	=	81
8	=	9
W	=	33
6	=	7
FIRST	=	0
Y	=	35
PAD_DIVIDE	=	47
KP_ENTER	=	51
PAD_PLUS	=	50
[	=	53
PAD_1	=	38
PAUSE	=	78
KP_UPARROW	=	45
]	=	54
LEFTARROW	=	89
DELETE	=	73
PAD_2	=	39
LSHIFT	=	79
PAD_3	=	40
B	=	12
LCONTROL	=	83
INSERT	=	72
PAD_4	=	41
'	=	56
KP_END	=	38
H	=	18
DEL	=	73
F	=	16
PERIOD	=	59
RCTRL	=	84
-	=	62
J	=	20
INS	=	72
RALT	=	82
/	=	60
CTRL	=	83
NUMLOCK	=	69
RSHIFT	=	80
COMMA	=	58
RBRACKET	=	54
PAD_ENTER	=	51
SPACE	=	65
P	=	26
EQUAL	=	63
SHIFT	=	79
KP_5	=	42
SEMICOLON	=	55
PAD_MINUS	=	49
NONE	=	0
KP_MULTIPLY	=	48
5	=	6
R	=	28
PGDN	=	77
F6	=	97
T	=	30
KP_DEL	=	52
7	=	8
UP	=	88
PAD_5	=	42
9	=	10
KP_LEFTARROW	=	41
X	=	34
ENTER	=	64
V	=	32
UPARROW	=	88
PAD_MULTIPLY	=	48
PAD_7	=	44
APP	=	87
=	=	63
Z	=	36
\	=	61
PAD_8	=	45
APOSTROPHE	=	56
KEY3	=	4
LAST	=	106
SCROLLLOCKTOGGLE	=	106
A	=	11
KP_SLASH	=	47
DOWNARROW	=	90
TAB	=	67
NUMLOCKTOGGLE	=	105
`	=	57
KP_PGDN	=	40
F12	=	103
C	=	13
F11	=	102
KEY4	=	5
F10	=	101
LBRACKET	=	53
F9	=	100
KEY5	=	6
F8	=	99
F5	=	96
E	=	15
F4	=	95
F3	=	94
F2	=	93
KEY8	=	9
F1	=	92
RIGHT	=	91
KEY0	=	1
KEY9	=	10
RIGHTARROW	=	91
DOWN	=	90
KEY1	=	2
PAD_0	=	37
RWIN	=	86
LWIN	=	85
RCONTROL	=	84
BACKQUOTE	=	57
I	=	19
KEY6	=	7
G	=	17
PAD_6	=	43
PAGEUP	=	76
KEY7	=	8
,	=	58
SCROLLLOCK	=	71
K	=	21
LEFT	=	89
KP_HOME	=	44
N	=	24
D	=	14
1	=	2
O	=	25
ESCAPE	=	70
KP_MINUS	=	49
LALT	=	81
M	=	23
PAD_DECIMAL	=	52
BREAK	=	78
MINUS	=	62
L	=	22
0	=	1
KP_RIGHTARROW	=	43
HOME	=	74
CAPSLOCKTOGGLE	=	104
COUNT	=	106
SLASH	=	60
KEY2	=	3
END	=	75
PAD_9	=	46
BACKSPACE	=	66
CAPSLOCK	=	68
Q	=	27
KP_DOWNARROW	=	39
2	=	3
BACKSLASH	=	61
3	=	4
KP_INS	=	37
--]]
