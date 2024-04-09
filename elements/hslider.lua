--@name wgui/e/hslider
--@author cortez


-- Создание класса элемента
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/hslider", BaseElement )
Element.static.elementName = "hslider"


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
