--@name wgui/e/buttonSelected


-- Создание класса элемента
local BaseElement = require( "./button.lua" ) --@include ./button.lua
local Element = class( "wgui/buttonSelected", BaseElement )
Element.static.elementName = "buttonSelected"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.colors.fill = table.rgba( self.data.palette.button )
    self.data.colors.text = table.rgba( self.data.palette.text )

    self.data.text = nil
    self.data.textFont = "ChatFont"

    self.data.textAlignX = TEXT_ALIGN.CENTER

    self.data.textStencil = false

    -- Ивенты
    self.events.system.click = function( self )
        self:setValue( not self.data.value )
    end
end


-- Оптимизация?
local math = math
local math_lerp = math.lerp


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    if self.data.value then
        self.data.colors.fill.r = math_lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
        self.data.colors.fill.g = math_lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
        self.data.colors.fill.b = math_lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
        self.data.colors.fill.a = math_lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
    else
        self.data.colors.fill.r = math_lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
        self.data.colors.fill.g = math_lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
        self.data.colors.fill.b = math_lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
        self.data.colors.fill.a = math_lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )
    end

    self.data.colors.text.r = math_lerp( self.data.transition, self.data.palette.text.r, self.data.palette.text_hover.r )
    self.data.colors.text.g = math_lerp( self.data.transition, self.data.palette.text.g, self.data.palette.text_hover.g )
    self.data.colors.text.b = math_lerp( self.data.transition, self.data.palette.text.b, self.data.palette.text_hover.b )
    self.data.colors.text.a = math_lerp( self.data.transition, self.data.palette.text.a, self.data.palette.text_hover.a )
end


-- Возвращаем класс элемента
return Element
