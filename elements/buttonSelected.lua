--@name wgui/e/buttonSelected


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/buttonSelected", BaseElement )
Element.static.elementName = "buttonSelected"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end

-- Функция отрисовки элемента
Element.paint = function( self )
    if self.data.value then
        render.setRGBA( 
            math.lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r ), 
            math.lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g ), 
            math.lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b ), 
            math.lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
        )
    else
        render.setRGBA( 
            math.lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r ), 
            math.lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g ), 
            math.lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b ), 
            math.lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )
        )
    end

    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
