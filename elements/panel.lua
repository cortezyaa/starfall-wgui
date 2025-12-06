--@name wgui/e/panel


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/panel", BaseElement )
Element.static.elementName = "panel"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
    
    self.data.colors.main.r = self.data.palette.fill.r
    self.data.colors.main.g = self.data.palette.fill.g
    self.data.colors.main.b = self.data.palette.fill.b
    self.data.colors.main.a = self.data.palette.fill.a
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.main.r, self.data.colors.main.g, self.data.colors.main.b, self.data.colors.main.a )
    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
