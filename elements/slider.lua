--@name wgui/e/slider
--@author cortez


-- Создание класса элемента
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/slider", BaseElement )
Element.static.elementName = "slider"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end

-- Функция рисования элемента
Element.paint = function( self )
    -- painting here
end


-- Возвращаем класс элемента
return Element
