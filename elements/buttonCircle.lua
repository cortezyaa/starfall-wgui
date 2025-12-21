--@name wgui/e/buttonCircle

-- EXPERIMENTAL
-- WILL BE REMOVED


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/buttonCircle", BaseElement )
Element.static.elementName = "buttonCircle"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
    
    self.data.colors.fill = table.rgba()
end


-- Хитскан функция
Element.hitscan = function( self, x, y )
    if not ( x >= self.data.hitbox.left and x <= self.data.hitbox.right and y >= self.data.hitbox.top and y <= self.data.hitbox.bottom ) then return false end
    return ( self.data.sizeGlobal.w / 2 ) > math.sqrt( math.pow( ( self.data.positionGlobal.x + self.data.sizeGlobal.w / 2 ) - x, 2 ) + math.pow( ( self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 ) - y, 2 ) )
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    self.data.colors.fill.r = math.lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
    self.data.colors.fill.g = math.lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
    self.data.colors.fill.b = math.lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
    self.data.colors.fill.a = math.lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )

    render.drawFilledCircle( self.data.positionGlobal.x + self.data.sizeGlobal.w / 2, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.sizeGlobal.w / 2 )
end


-- Возвращаем класс элемента
return Element
