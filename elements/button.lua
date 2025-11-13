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
        math.lerp( self.style.transitionLevel, self.style.palette.button.r, self.style.palette.button_hover.r ), 
        math.lerp( self.style.transitionLevel, self.style.palette.button.g, self.style.palette.button_hover.g ), 
        math.lerp( self.style.transitionLevel, self.style.palette.button.b, self.style.palette.button_hover.b ), 
        math.lerp( self.style.transitionLevel, self.style.palette.button.a, self.style.palette.button_hover.a )
    )

    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
