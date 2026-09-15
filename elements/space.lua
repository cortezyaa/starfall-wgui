--@name wgui/e/space


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/space", BaseElement )
Element.static.elementName = "space"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.horizontal = false

    self.data.offsetX = 0
    self.data.offsetY = 0
    self.data.offsetXold = 0
    self.data.offsetYold = 0
    self.data.sensitivity = 1

    self.data.lines = true
    self.data.linesDistance = 100

    self.data.overflow = OVERFLOW.HIDDEN

    self.data.colors.fill = table.rgba( self.data.palette.fill )
    self.data.colors.lines = table.rgba( self.data.palette.button )

    -- Ивенты
    self.events.system.click = function( self )
        self.data.offsetXold = self.data.offsetX
        self.data.offsetYold = self.data.offsetY
    end

    self.events.system.hoverclick = function( self )
        self.data.offsetX = self.data.offsetXold + ( self.data.renderSpace.cursor.position.x - self.data.renderSpace.cursor.clickPosition.x ) * self.data.sensitivity
        self.data.offsetY = self.data.offsetYold + ( self.data.renderSpace.cursor.position.y - self.data.renderSpace.cursor.clickPosition.y ) * self.data.sensitivity

        self:sysRecalculate()
    end
end


-- Оптимизация?
local math_lerp = math.lerp
local math_max = math.max
local math_min = math.min
local math_clamp = math.clamp
local math_ceil = math.ceil
local render_setRGBA = render.setRGBA
local render_drawRectFast = render.drawRectFast
local render_drawLine = render.drawLine


-- Системная функция перерасчета элемента
local self_data, self_pgx, self_pgy
local children, child_data, cx, cy, cw, ch, coLeft, coTop, coRight, coBottom

Element.sysRecalculation = function( self )
    self_data = self.data
    self_pgx = self_data.positionGlobal.x
    self_pgy = self_data.positionGlobal.y

    children = self_data.children

    for _, child in pairs( children ) do
        child_data = child.data

        child_data.sizeGlobal.w = child_data.sizeLocal.w
        child_data.sizeGlobal.h = child_data.sizeLocal.h

        child_data.positionGlobal.x = self_pgx + child_data.positionLocal.x + self_data.offsetX
        child_data.positionGlobal.y = self_pgy + child_data.positionLocal.y + self_data.offsetY

        cx = child_data.positionGlobal.x
        cy = child_data.positionGlobal.y
        cw = child_data.sizeGlobal.w
        ch = child_data.sizeGlobal.h

        if child_data.overflow == OVERFLOW.VISIBLE then
            child_data.overflowBox.left = self_data.overflowBox.left
            child_data.overflowBox.top = self_data.overflowBox.top
            child_data.overflowBox.right = self_data.overflowBox.right
            child_data.overflowBox.bottom = self_data.overflowBox.bottom
        else
            child_data.overflowBox.left = math_clamp( cx, self_data.overflowBox.left, self_data.overflowBox.right )
            child_data.overflowBox.top = math_clamp( cy, self_data.overflowBox.top, self_data.overflowBox.bottom )
            child_data.overflowBox.right = math_clamp( cx + cw, self_data.overflowBox.left, self_data.overflowBox.right )
            child_data.overflowBox.bottom = math_clamp( cy + ch, self_data.overflowBox.top, self_data.overflowBox.bottom )
        end

        coLeft = child_data.overflowBox.left
        coTop = child_data.overflowBox.top
        coRight = child_data.overflowBox.right
        coBottom = child_data.overflowBox.bottom

        child_data.hitbox.left = math_clamp( math_max( cx, coLeft ), coLeft, coRight )
        child_data.hitbox.top = math_clamp( math_max( cy, coTop ), coTop, coBottom )
        child_data.hitbox.right = math_clamp( math_min( cx + cw, coRight ), coLeft, coRight )
        child_data.hitbox.bottom = math_clamp( math_min( cy + ch, coBottom ), coTop, coBottom )

        child_data.shouldUseStencil = 
            ( cx < coLeft ) or 
            ( cy < coTop ) or 
            ( ( cx + cw ) > coRight ) or 
            ( ( cy + ch ) > coBottom )

        child_data.shouldDraw = 
            ( cw >= 0 and ch >= 0 ) and
            ( cx <= coRight ) and
            ( cy <= coBottom ) and
            ( ( cx + cw ) >= coLeft ) and
            ( ( cy + ch ) >= coTop )

        child:sysRecalculation()
    end
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render_setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    if self.data.lines then
        render_setRGBA( self.data.colors.lines.r, self.data.colors.lines.g, self.data.colors.lines.b, self.data.colors.lines.a )

        local pos = 0

        for line = 1, math_ceil( self.data.sizeGlobal.w / self.data.linesDistance ) do
            pos = self.data.positionGlobal.x + self.data.linesDistance * line + ( self.data.offsetX % self.data.linesDistance ) - self.data.linesDistance
            if pos >= self.data.positionGlobal.x + self.data.sizeGlobal.w then continue end
            render_drawLine( pos, self.data.positionGlobal.y, pos, self.data.positionGlobal.y + self.data.sizeGlobal.h )
        end

        for line = 1, math_ceil( self.data.sizeGlobal.h / self.data.linesDistance ) do
            pos = self.data.positionGlobal.y + self.data.linesDistance * line + ( self.data.offsetY % self.data.linesDistance ) - self.data.linesDistance
            if pos >= self.data.positionGlobal.y + self.data.sizeGlobal.h then continue end
            render_drawLine( self.data.positionGlobal.x, pos, self.data.positionGlobal.x + self.data.sizeGlobal.w, pos )
        end
    end
end


-- Возвращаем класс элемента
return Element
