--@name wgui/e/renderSpaceWorld


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceWorld", BaseElement )
Element.static.elementName = "renderSpaceWorld"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.isRenderSpace = true
    self.data.type = RENDERSPACE.WORLD

    self.data.worldPosition = Vector( 0, 0, 0 )
    self.data.worldAngle = Angle( 0, 0, 0 )
end


-- Возвращаем класс элемента
return Element
