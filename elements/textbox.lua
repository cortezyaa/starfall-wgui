--@name wgui/e/textbox


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/textbox", BaseElement )
Element.static.elementName = "textbox"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.colors.fill = table.rgba( self.data.palette.fill )
    self.data.colors.border = table.rgba( self.data.palette.button )
    self.data.colors.text = table.rgba( self.data.palette.text )

    self.data.keyboardInput = true

    self.data.value = "string"
    self.data.font = "ChatFont"

    -- Ивенты
    self.events.system.focuson = function( self )
        self:sysRecalculateColors()

        if not input.isControlLocked() and input.canLockControls() then
            input.lockControls( true )
        end
    end

    self.events.system.focusoff = function( self )
        self:sysRecalculateColors()

        if input.isControlLocked() then
            input.lockControls( false )
        end
    end
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    if self.data.focus then
        self.data.colors.border.r = math.lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
        self.data.colors.border.g = math.lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
        self.data.colors.border.b = math.lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
        self.data.colors.border.a = math.lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
    else
        self.data.colors.border.r = math.lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
        self.data.colors.border.g = math.lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
        self.data.colors.border.b = math.lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
        self.data.colors.border.a = math.lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )
    end
end


-- Функция проверки возможностьи фокуса на элементе
Element.sysFocus = function( self )
    return input.canLockControls()
end


-- Функция установки шрифта
Element.setFont = function( self, font )
    self:sysValidate()
    checkType( font, "string" )

    self.data.font = font
end

-- Функция получения шрифта
Element.getFont = function( self )
    self:sysValidate()
    return self.data.font
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.border.r, self.data.colors.border.g, self.data.colors.border.b, self.data.colors.border.a )
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render.drawRectFast( self.data.positionGlobal.x + 1, self.data.positionGlobal.y + 1, self.data.sizeGlobal.w - 2, self.data.sizeGlobal.h - 2 )
    
    render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a )
    render.setFont( self.data.font )
    render.drawSimpleText( self.data.positionGlobal.x + self.data.sizeGlobal.w / 2, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.value, TEXT_ALIGN.CENTER, TEXT_ALIGN.CENTER )

    if self.data.focus then -- ну блять эта косочка
        local w, h = render.getTextSize( self.data.value )
        render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a - math.abs( math.tan( timer.curtime() * 2 ) ) * 155 )
        render.drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w / 2 + w / 2 + 2, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 - h / 2, 1, h )
    end

    if input.lockedControlCooldown + input.lockCooldown >= timer.curtime() then
        render.setRGBA( self.data.colors.border.r, self.data.colors.border.g, self.data.colors.border.b, self.data.colors.border.a )
        render.drawRectFast( 
            self.data.positionGlobal.x, 
            self.data.positionGlobal.y - 2 + self.data.sizeGlobal.h, 
            self.data.sizeGlobal.w * ( ( timer.curtime() - input.lockedControlCooldown ) / input.lockCooldown ), 
            2
        )
    end
end


-- Возвращаем класс элемента
return Element
