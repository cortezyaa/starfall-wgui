--@name wgui/e/panel


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/panel", BaseElement )
Element.static.elementName = "panel"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end

-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.palette.fill.r, self.data.palette.fill.g, self.data.palette.fill.b, self.data.palette.fill.a )
    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
