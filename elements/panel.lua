--@name wgui/e/panel
--@author cortez


-- Создание класса элемента
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/panel", BaseElement )
Element.static.elementName = "panel"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.__data.color = Color( 255, 255, 255, 255 )
end

-- Функция рисования элемента
Element.paint = function( self )
    -- painting here

    render.setRGBA( self.__data.color.r, self.__data.color.g, self.__data.color.b, self.__data.color.a )
    render.drawRect( self.__data.positionGlobal.x, self.__data.positionGlobal.y, self.__data.sizeGlobal.w, self.__data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
