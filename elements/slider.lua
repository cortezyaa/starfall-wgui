--@name wgui/e/slider


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/slider", BaseElement )
Element.static.elementName = "slider"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.horizontal = false

    self.data.value = 0
    self.data.valueSnap = 0

    self.data.colors.fill = table.rgba( self.data.palette.button )
    self.data.colors.thumb = table.rgba( self.data.palette.button_selected )

    -- Ивенты
    self.events.system.hoverclick = function( self )
        self.data.transition = 1

        local delta = self.data.renderSpace.cursor.position[ self.data.horizontal and "x" or "y" ] - self.data.positionGlobal[ self.data.horizontal and "x" or "y" ]
        local value = math.clamp( delta / self.data.sizeGlobal[ self.data.horizontal and "w" or "h" ], 0, 1 )

        if self.data.valueSnap and self.data.valueSnap ~= 0 then
            value = value - ( value % self.data.valueSnap )
        end

        if self.data.value ~= value then
            self:setValue( value )
        end
    end
end


-- Оптимизация?
local math_lerp = math.lerp
local render_setRGBA = render.setRGBA
local render_drawRectFast = render.drawRectFast


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    self.data.colors.thumb.r = math_lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
    self.data.colors.thumb.g = math_lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
    self.data.colors.thumb.b = math_lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
    self.data.colors.thumb.a = math_lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
end


-- Функции управления ориентацией элемента
Element.setHorizontal = function( self, horizontal )
    self:sysValidate()
    checkType( horizontal, "boolean" )

    self.data.horizontal = horizontal
end

Element.getHorizontal = function( self )
    self:sysValidate()
    return self.data.horizontal
end


-- Функции управления snap'ом элемента
Element.setSnap = function( self, snap )
    self:sysValidate()
    checkType( snap, "number" )

    self.data.valueSnap = snap
end

Element.getSnap = function( self )
    self:sysValidate()
    return self.data.valueSnap
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render_setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    render_setRGBA( self.data.colors.thumb.r, self.data.colors.thumb.g, self.data.colors.thumb.b, self.data.colors.thumb.a )

    if self.data.horizontal then
        render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w * self.data.value, self.data.sizeGlobal.h )
    else
        render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h * self.data.value )
    end
end


-- Возвращаем класс элемента
return Element
