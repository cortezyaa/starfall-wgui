--@name wgui/e/renderSpaceScreen


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceScreen", BaseElement )
Element.static.elementName = "renderSpaceScreen"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end


-- Возвращаем класс элемента
return Element
