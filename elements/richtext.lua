--@name wgui/e/richtext


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/richtext", BaseElement )
Element.static.elementName = "richtext"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
    
    -- self.data.colors.fill = table.rgba( self.data.palette.fill )

    self.data.segments = {}
end


-- Функция отрисовки элемента
Element.paint = function( self )
    -- render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    -- render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
