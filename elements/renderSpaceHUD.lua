--@name wgui/e/renderSpaceHUD


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceHUD", BaseElement )
Element.static.elementName = "renderSpaceHUD"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end


-- Возвращаем класс элемента
return Element
