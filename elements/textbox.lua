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

    self.data.value = ""
    self.data.oldvalue = self.data.value

    self.data.textFont = "ChatFont"
    self.data.textAlignX = TEXT_ALIGN.CENTER
    self.data.textStencil = false

    -- Ивенты
    self.events.system.focuson = function( self )
        self:sysRecalculateColors()

        if not input.isControlLocked() then
            input.lockControls( true )
        end

        self.data.oldvalue = self.data.value
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

        self.data.colors.text.r = self.data.palette.text_hover.r
        self.data.colors.text.g = self.data.palette.text_hover.g
        self.data.colors.text.b = self.data.palette.text_hover.b
        self.data.colors.text.a = self.data.palette.text_hover.a
    else
        self.data.colors.border.r = math.lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
        self.data.colors.border.g = math.lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
        self.data.colors.border.b = math.lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
        self.data.colors.border.a = math.lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )

        self.data.colors.text.r = self.data.palette.text.r
        self.data.colors.text.g = self.data.palette.text.g
        self.data.colors.text.b = self.data.palette.text.b
        self.data.colors.text.a = self.data.palette.text.a
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


-- Функции установки выравнивания
Element.setAlignX = function( self, align )
    self:sysValidate()
    checkType( align, "number" )
    checkEnum( align, "TEXT_ALIGN" )

    self.data.textAlignX = align
end

-- Функция получения выравнивания
Element.getAlignX = function( self )
    self:sysValidate()
    return self.data.textAlignX
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.border.r, self.data.colors.border.g, self.data.colors.border.b, self.data.colors.border.a )
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render.drawRectFast( self.data.positionGlobal.x + 1, self.data.positionGlobal.y + 1, self.data.sizeGlobal.w - 2, self.data.sizeGlobal.h - 2 )

    if input.lockedControlCooldown + input.lockCooldown >= timer.realtime() then
        render.setRGBA( self.data.colors.border.r, self.data.colors.border.g, self.data.colors.border.b, self.data.colors.border.a )
        render.drawRectFast( 
            self.data.positionGlobal.x, 
            self.data.positionGlobal.y - 2 + self.data.sizeGlobal.h, 
            self.data.sizeGlobal.w * ( ( timer.realtime() - input.lockedControlCooldown ) / input.lockCooldown ), 
            2
        )
    end
end


-- Функция отрисовки текста
local tx, tw, th, ts = 0, 0, 0, 4
Element.paintText = function( self )
    render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a )
    render.setFont( self.data.textFont )

    tw, th = render.getTextSize( self.data.value )
    self.data.textStencil = ( tw > ( self.data.sizeGlobal.w - ts ) ) or ( th > ( self.data.sizeGlobal.h - ts ) )

    if      self.data.textAlignX == TEXT_ALIGN.LEFT     then tx = self.data.positionGlobal.x + ts
    elseif  self.data.textAlignX == TEXT_ALIGN.CENTER   then tx = self.data.positionGlobal.x + self.data.sizeGlobal.w / 2
    elseif  self.data.textAlignX == TEXT_ALIGN.RIGHT    then tx = self.data.positionGlobal.x + self.data.sizeGlobal.w - ts - 3
    end

    render.drawSimpleText( tx, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.value, self.data.textAlignX, TEXT_ALIGN.CENTER )

    if self.data.focus then -- тип курсор
        render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a * math.abs( math.sin( timer.realtime() * 3 ) ) )
        render.drawRectFast( tx + 2 + ( tw / 2 ) * ( 2 - self.data.textAlignX ), self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 - th / 2, 1, th )
    end
end


-- Функции рендера элемента
local sx, sy, sw, sh = 0, 0, 0, 0
Element.render = function( self )
    if not self.valid then return end
    
    if self.data.noDraw then return end

    local oldtransition = self.data.transition
    self.data.transition = math.lerp( self.data.transition + ( self.data.hover and 1 or -1 ) * ( ( timer.realtime() - self.data.realtime ) / self.data.transitionTime ), 0, 1 )

    if self.data.transition ~= oldtransition then
        self:sysRecalculateColors()
    end

    self.data.realtime = timer.realtime()

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

            sx = math.max( self.data.overflowBox.left, self.data.positionGlobal.x + ts )
            sy = math.max( self.data.overflowBox.top, self.data.positionGlobal.y + ts )
            sw = math.min( self.data.overflowBox.right, self.data.positionGlobal.x + self.data.sizeGlobal.w - ts ) - sx
            sh = math.min( self.data.overflowBox.bottom, self.data.positionGlobal.y + self.data.sizeGlobal.h - ts ) - sy

            render.drawRectFast( sx, sy, sw, sh )

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
