--@name wgui/e/button


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/button", BaseElement )
Element.static.elementName = "button"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    self.data.colors.main.r = math.lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
    self.data.colors.main.g = math.lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
    self.data.colors.main.b = math.lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
    self.data.colors.main.a = math.lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.main.r, self.data.colors.main.g, self.data.colors.main.b, self.data.colors.main.a )
    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
