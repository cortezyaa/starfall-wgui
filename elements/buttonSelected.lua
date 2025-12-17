--@name wgui/e/buttonSelected


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/buttonSelected", BaseElement )
Element.static.elementName = "buttonSelected"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    -- Ивенты
    self.events.system.click = function( self )
        self:setValue( not self.data.value )
    end
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    if self.data.value then
        self.data.colors.main.r = math.lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
        self.data.colors.main.g = math.lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
        self.data.colors.main.b = math.lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
        self.data.colors.main.a = math.lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
    else
        self.data.colors.main.r = math.lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
        self.data.colors.main.g = math.lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
        self.data.colors.main.b = math.lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
        self.data.colors.main.a = math.lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )
    end
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.main.r, self.data.colors.main.g, self.data.colors.main.b, self.data.colors.main.a )
    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
