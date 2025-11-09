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
    render.setRGBA( self.__style.palette.fill.r, self.__style.palette.fill.g, self.__style.palette.fill.b, self.__style.palette.fill.a )
    render.drawRect( self.__data.positionGlobal.x, self.__data.positionGlobal.y, self.__data.sizeGlobal.w, self.__data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
