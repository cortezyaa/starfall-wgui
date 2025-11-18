--@name wgui/e/button


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/button", BaseElement )
Element.static.elementName = "button"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end

-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( 
        math.lerp( self.data.transition, self.palette.button.r, self.palette.button_hover.r ), 
        math.lerp( self.data.transition, self.palette.button.g, self.palette.button_hover.g ), 
        math.lerp( self.data.transition, self.palette.button.b, self.palette.button_hover.b ), 
        math.lerp( self.data.transition, self.palette.button.a, self.palette.button_hover.a )
    )

    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
