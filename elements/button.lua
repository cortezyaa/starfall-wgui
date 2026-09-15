--@name wgui/e/button


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/button", BaseElement )
Element.static.elementName = "button"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.colors.fill = table.rgba( self.data.palette.button )
    self.data.colors.text = table.rgba( self.data.palette.text )

    self.data.text = nil
    self.data.textFont = "ChatFont"

    self.data.textAlignX = TEXT_ALIGN.CENTER

    self.data.textStencil = false
end


-- Оптимизация?
local math_lerp = math.lerp
local math_max = math.max
local math_min = math.min
local render_setRGBA = render.setRGBA
local render_drawRectFast = render.drawRectFast
local render_setFont = render.setFont
local render_getTextSize = render.getTextSize
local render_drawSimpleText = render.drawSimpleText
local render_setStencilEnable = render.setStencilEnable
local render_clearStencil = render.clearStencil
local render_setStencilTestMask = render.setStencilTestMask
local render_setStencilWriteMask = render.setStencilWriteMask
local render_setStencilPassOperation = render.setStencilPassOperation
local render_setStencilZFailOperation = render.setStencilZFailOperation
local render_setStencilCompareFunction = render.setStencilCompareFunction
local render_setStencilReferenceValue = render.setStencilReferenceValue
local render_setStencilFailOperation = render.setStencilFailOperation


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    self.data.colors.fill.r = math_lerp( self.data.transition, self.data.palette.button.r, self.data.palette.button_hover.r )
    self.data.colors.fill.g = math_lerp( self.data.transition, self.data.palette.button.g, self.data.palette.button_hover.g )
    self.data.colors.fill.b = math_lerp( self.data.transition, self.data.palette.button.b, self.data.palette.button_hover.b )
    self.data.colors.fill.a = math_lerp( self.data.transition, self.data.palette.button.a, self.data.palette.button_hover.a )

    self.data.colors.text.r = math_lerp( self.data.transition, self.data.palette.text.r, self.data.palette.text_hover.r )
    self.data.colors.text.g = math_lerp( self.data.transition, self.data.palette.text.g, self.data.palette.text_hover.g )
    self.data.colors.text.b = math_lerp( self.data.transition, self.data.palette.text.b, self.data.palette.text_hover.b )
    self.data.colors.text.a = math_lerp( self.data.transition, self.data.palette.text.a, self.data.palette.text_hover.a )
end


-- Функция установки текста
Element.setText = function( self, text )
    self:sysValidate()
    checkType( text, { "nil", "string" } )

    if text == nil or text == "" then
        self.data.text = nil
        return
    end

    self.data.text = text
end

-- Функция получения текста
Element.getText = function( self )
    self:sysValidate()
    return self.data.text
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
    render_setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Функция отрисовки текста
local tx, tw, th, ts = 0, 0, 0, 4
Element.paintText = function( self )
    render_setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a )
    render_setFont( self.data.textFont )

    tw, th = render_getTextSize( self.data.text )
    self.data.textStencil = ( tw > ( self.data.sizeGlobal.w - ts ) ) or ( th > ( self.data.sizeGlobal.h - ts ) )

    if      self.data.textAlignX == TEXT_ALIGN.LEFT     then tx = self.data.positionGlobal.x + ts
    elseif  self.data.textAlignX == TEXT_ALIGN.CENTER   then tx = self.data.positionGlobal.x + self.data.sizeGlobal.w / 2
    elseif  self.data.textAlignX == TEXT_ALIGN.RIGHT    then tx = self.data.positionGlobal.x + self.data.sizeGlobal.w - ts
    end

    render_drawSimpleText( tx, self.data.positionGlobal.y + self.data.sizeGlobal.h / 2, self.data.text, self.data.textAlignX, TEXT_ALIGN.CENTER )
end


-- Функции рендера элемента
local sx, sy, sw, sh = 0, 0, 0, 0
local oldtransition

Element.render = function( self )
    if not self.valid then return end
    
    if self.data.noDraw then return end

    oldtransition = self.data.transition
    self.data.transition = math_lerp( self.data.transition + ( self.data.hover and 1 or -1 ) * ( ( timer.realtime() - self.data.realtime ) / self.data.transitionTime ), 0, 1 )

    if self.data.transition ~= oldtransition then
        self:sysRecalculateColors()
    end

    self.data.realtime = timer.realtime()

    if self.data.shouldDraw then
        if self.data.shouldUseStencil then
            render_setStencilEnable( true )
            render_clearStencil()
            render_setStencilTestMask( 255 )
            render_setStencilWriteMask( 255 )
            render_setStencilPassOperation( STENCIL.KEEP )
            render_setStencilZFailOperation( STENCIL.KEEP )
            render_setStencilCompareFunction( STENCIL.NEVER )
            render_setStencilReferenceValue( 1 )
            render_setStencilFailOperation( STENCIL.REPLACE )

            render_drawRectFast( 
                self.data.overflowBox.left, 
                self.data.overflowBox.top, 
                self.data.overflowBox.right - self.data.overflowBox.left,
                self.data.overflowBox.bottom - self.data.overflowBox.top
            )

            render_setStencilFailOperation( STENCIL.KEEP )
            render_setStencilCompareFunction( STENCIL.EQUAL )

            self:paint()

            render_setStencilEnable( false )
        else
            self:paint()
        end

        if self.data.text ~= nil and self.data.text ~= "" then
            if self.data.shouldUseStencil or self.data.textStencil then
                render_setStencilEnable( true )
                render_clearStencil()
                render_setStencilTestMask( 255 )
                render_setStencilWriteMask( 255 )
                render_setStencilPassOperation( STENCIL.KEEP )
                render_setStencilZFailOperation( STENCIL.KEEP )
                render_setStencilCompareFunction( STENCIL.NEVER )
                render_setStencilReferenceValue( 1 )
                render_setStencilFailOperation( STENCIL.REPLACE )

                sx = math_max( self.data.overflowBox.left, self.data.positionGlobal.x + ts )
                sy = math_max( self.data.overflowBox.top, self.data.positionGlobal.y + ts )
                sw = math_min( self.data.overflowBox.right, self.data.positionGlobal.x + self.data.sizeGlobal.w - ts ) - sx
                sh = math_min( self.data.overflowBox.bottom, self.data.positionGlobal.y + self.data.sizeGlobal.h - ts ) - sy

                render_drawRectFast( sx, sy, sw, sh )

                render_setStencilFailOperation( STENCIL.KEEP )
                render_setStencilCompareFunction( STENCIL.EQUAL )

                self:paintText()

                render_setStencilEnable( false )
            else
                self:paintText()
            end
        end
    end

    for _, child in pairs( self.data.children ) do
        child:render()
    end
end


-- Возвращаем класс элемента
return Element
