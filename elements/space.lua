--@name wgui/e/space


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/space", BaseElement )
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


-- Системная функция перерасчета элемента
Element.sysRecalculation = function( self )
    for _, child in pairs( self.data.children ) do
        child.data.positionGlobal.x = self.data.positionGlobal.x + child.data.positionLocal.x + self.data.offsetX
        child.data.positionGlobal.y = self.data.positionGlobal.y + child.data.positionLocal.y + self.data.offsetY
        child.data.sizeGlobal.w = child.data.sizeLocal.w
        child.data.sizeGlobal.h = child.data.sizeLocal.h

        local x = child.data.positionGlobal.x
        local y = child.data.positionGlobal.y
        local w = child.data.sizeGlobal.w
        local h = child.data.sizeGlobal.h

        if child.data.overflow == OVERFLOW.VISIBLE then
            child.data.overflowBox.left = self.data.overflowBox.left
            child.data.overflowBox.top = self.data.overflowBox.top
            child.data.overflowBox.right = self.data.overflowBox.right
            child.data.overflowBox.bottom = self.data.overflowBox.bottom
        else
            child.data.overflowBox.left = math.max( x, self.data.overflowBox.left )
            child.data.overflowBox.top = math.max( y, self.data.overflowBox.top )
            child.data.overflowBox.right = math.min( x + w, self.data.overflowBox.right )
            child.data.overflowBox.bottom = math.min( y + h, self.data.overflowBox.bottom )
        end

        child.data.hitbox.left = math.clamp( math.max( x, child.data.overflowBox.left ), child.data.overflowBox.left, child.data.overflowBox.right )
        child.data.hitbox.top = math.clamp( math.max( y, child.data.overflowBox.top ), child.data.overflowBox.top, child.data.overflowBox.bottom )
        child.data.hitbox.right = math.clamp( math.min( x + w, child.data.overflowBox.right ), child.data.overflowBox.left, child.data.overflowBox.right )
        child.data.hitbox.bottom = math.clamp( math.min( y + h, child.data.overflowBox.bottom ), child.data.overflowBox.top, child.data.overflowBox.bottom )

        child.data.shouldUseStencil = ( x < child.data.overflowBox.left ) or ( y < child.data.overflowBox.top ) or ( ( x + w ) > child.data.overflowBox.right ) or ( ( y + h ) > child.data.overflowBox.bottom )
        child.data.shouldDraw = not ( ( x > child.data.overflowBox.right ) or ( y > child.data.overflowBox.bottom ) or ( ( x + w ) < child.data.overflowBox.left ) or ( ( y + h ) < child.data.overflowBox.top ) )

        child:sysRecalculation()
    end
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    if self.data.lines then
        render.setRGBA( self.data.colors.lines.r, self.data.colors.lines.g, self.data.colors.lines.b, self.data.colors.lines.a )

        local pos = 0

        for line = 1, math.ceil( self.data.sizeGlobal.w / self.data.linesDistance ) do
            pos = self.data.positionGlobal.x + self.data.linesDistance * line + ( self.data.offsetX % self.data.linesDistance ) - self.data.linesDistance
            if pos >= self.data.positionGlobal.x + self.data.sizeGlobal.w then continue end
            render.drawLine( pos, self.data.positionGlobal.y, pos, self.data.positionGlobal.y + self.data.sizeGlobal.h )
        end

        for line = 1, math.ceil( self.data.sizeGlobal.h / self.data.linesDistance ) do
            pos = self.data.positionGlobal.y + self.data.linesDistance * line + ( self.data.offsetY % self.data.linesDistance ) - self.data.linesDistance
            if pos >= self.data.positionGlobal.y + self.data.sizeGlobal.h then continue end
            render.drawLine( self.data.positionGlobal.x, pos, self.data.positionGlobal.x + self.data.sizeGlobal.w, pos )
        end
    end
end


-- Возвращаем класс элемента
return Element
