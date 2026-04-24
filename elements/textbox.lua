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
    self.data.textFont = "ChatFont"
    self.data.textAlign = TEXT_ALIGN.CENTER
    self.data.textStencil = false

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

    self.events.system.removed = function( self )
        if self.data.focus and input.isControlLocked() then
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

    self.data.textFont = font
end

-- Функция получения шрифта
Element.getFont = function( self )
    self:sysValidate()
    return self.data.textFont
end


-- Функция установки выравнивания
Element.setAlign = function( self, align )
    self:sysValidate()
    checkType( align, "number" )

    self.data.textAlign = align
end

-- Функция получения выравнивания
Element.getAlign = function( self )
    self:sysValidate()
    return self.data.textAlign
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.border.r, self.data.colors.border.g, self.data.colors.border.b, self.data.colors.border.a )
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render.drawRectFast( self.data.positionGlobal.x + 1, self.data.positionGlobal.y + 1, self.data.sizeGlobal.w - 2, self.data.sizeGlobal.h - 2 )

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


-- Функция отрисовки текста
Element.paintText = function( self )
    render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a )
    render.setFont( self.data.textFont )

    local w, h = render.getTextSize( self.data.value )
    self.data.textStencil = w > ( self.data.sizeGlobal.w - 14 )

    if self.data.textAlign == TEXT_ALIGN.LEFT then
        render.drawSimpleText( self.data.positionGlobal.x + 7, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.value, TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER )
    elseif self.data.textAlign == TEXT_ALIGN.RIGHT then
        render.drawSimpleText( self.data.positionGlobal.x + self.data.sizeGlobal.w - 10, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.value, TEXT_ALIGN.RIGHT, TEXT_ALIGN.CENTER )
    elseif self.data.textAlign == TEXT_ALIGN.CENTER then
        render.drawSimpleText( self.data.positionGlobal.x + self.data.sizeGlobal.w / 2, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.value, TEXT_ALIGN.CENTER, TEXT_ALIGN.CENTER )
    end

    if self.data.focus then
        render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a - math.abs( math.tan( timer.curtime() * 3 ) ) * 155 )

        if self.data.textAlign == TEXT_ALIGN.LEFT then
            render.drawRectFast( self.data.positionGlobal.x + w + 10, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 - h / 2, 1, h )
        elseif self.data.textAlign == TEXT_ALIGN.RIGHT then
            render.drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w - 7, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 - h / 2, 1, h )
        elseif self.data.textAlign == TEXT_ALIGN.CENTER then
            render.drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w / 2 + w / 2 + 2, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 - h / 2, 1, h )
        end
    end
end


-- Функции рендера элемента
Element.render = function( self )
    if not self.valid then return end
    
    if self.data.noDraw then return end

    local oldtransition = self.data.transition
    self.data.transition = math.lerp( self.data.transition + ( self.data.hover and 1 or -1 ) * ( ( timer.curtime() - self.data.curtime ) / self.data.transitionTime ), 0, 1 )

    if self.data.transition ~= oldtransition then
        self:sysRecalculateColors()
    end

    self.data.curtime = timer.curtime()

    if self.data.shouldDraw then
        if self.data.shouldUseStencil then
            render.setStencilEnable( true )
            render.clearStencil()
            render.setStencilTestMask( 255 )
            render.setStencilWriteMask( 255 )
            render.setStencilPassOperation( STENCIL.KEEP )
            render.setStencilZFailOperation( STENCIL.KEEP )
            render.setStencilCompareFunction( STENCIL.NEVER )
            render.setStencilReferenceValue( 1 )
            render.setStencilFailOperation( STENCIL.REPLACE )

            render.drawRectFast( 
                self.data.overflowBox.left, 
                self.data.overflowBox.top, 
                self.data.overflowBox.right - self.data.overflowBox.left,
                self.data.overflowBox.bottom - self.data.overflowBox.top
            )

            render.setStencilFailOperation( STENCIL.KEEP )
            render.setStencilCompareFunction( STENCIL.EQUAL )

            self:paint()

            render.setStencilEnable( false )
        else
            self:paint()
        end

        if self.data.shouldUseStencil or self.data.textStencil then
            render.setStencilEnable( true )
            render.clearStencil()
            render.setStencilTestMask( 255 )
            render.setStencilWriteMask( 255 )
            render.setStencilPassOperation( STENCIL.KEEP )
            render.setStencilZFailOperation( STENCIL.KEEP )
            render.setStencilCompareFunction( STENCIL.NEVER )
            render.setStencilReferenceValue( 1 )
            render.setStencilFailOperation( STENCIL.REPLACE )

            render.drawRectFast( 
                math.max( self.data.overflowBox.left, self.data.positionGlobal.x + 7 ), 
                math.max( self.data.overflowBox.top, self.data.positionGlobal.y ), 
                
                ( ( self.data.positionGlobal.x + self.data.sizeGlobal.w - 7 ) <= self.data.overflowBox.right ) 
                    and ( self.data.sizeGlobal.w - 14 ) 
                    or ( self.data.overflowBox.right - self.data.positionGlobal.x - 7 ),

                ( ( self.data.positionGlobal.y + self.data.sizeGlobal.h ) <= self.data.overflowBox.bottom ) 
                    and ( self.data.sizeGlobal.h ) 
                    or ( self.data.overflowBox.right - self.data.positionGlobal.y )
            )

            render.setStencilFailOperation( STENCIL.KEEP )
            render.setStencilCompareFunction( STENCIL.EQUAL )

            self:paintText()

            render.setStencilEnable( false )
        else
            self:paintText()
        end
    end

    for _, child in pairs( self.data.children ) do
        child:render()
    end
end


-- Возвращаем класс элемента
return Element
