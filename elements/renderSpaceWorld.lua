--@name wgui/e/renderSpaceWorld


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceWorld", BaseElement )
Element.static.elementName = "renderSpaceWorld"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end


-- Возвращаем класс элемента
return Element
