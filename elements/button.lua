--@name wgui/e/button


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/button", BaseElement )
Element.static.elementName = "button"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.colors.fill = table.rgba()
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
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
