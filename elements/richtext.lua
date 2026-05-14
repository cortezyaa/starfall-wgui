--@name wgui/e/richtext


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/richtext", BaseElement )
Element.static.elementName = "richtext"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
    
    self.data.colors.text = table.rgba( self.data.palette.text )
    self.data.segments = {}

    --[[
    мхм чет пока не придумал как реализовать.

    {
        callback = $function,
        text = $string,
        font = $string (font),
        position = { x = $number, y = $number },
        size = { w = $number, h = $number }
    }
    --]]

    -- self.events.system.click = function( self )
    --     local cursor = self.data.renderSpace.cursor
    -- end
end


-- Функция отрисовки элемента
Element.paint = function( self )
    -- render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    -- render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    -- render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a )
    -- render.setFont( "ChatFont" )
end


-- Возвращаем класс элемента
return Element
