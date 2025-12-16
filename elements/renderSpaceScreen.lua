--@name wgui/e/renderSpaceScreen


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceScreen", BaseElement )
Element.static.elementName = "renderSpaceScreen"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.isRenderSpace = true
    self.data.type = RENDERSPACE.SCREEN

    self.data.renderTarget = "wgui:" .. self.uid
    
    if render.renderTargetExists( self.data.renderTarget ) then
        render.destroyRenderTarget( self.data.renderTarget )
    end

    render.createRenderTarget( self.data.renderTarget )
end


-- Возвращаем класс элемента
return Element
