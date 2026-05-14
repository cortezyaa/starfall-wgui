--@name wgui/e/label


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/label", BaseElement )
Element.static.elementName = "label"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.colors.fill = table.rgba( self.data.palette.button_hover )
    self.data.colors.text = table.rgba( self.data.palette.text )

    -- Текстовые переменные
    self.data.text = nil
    self.data.textFont = "ChatFont"

    self.data.textAlignX = TEXT_ALIGN.CENTER
    self.data.textAlignY = TEXT_ALIGN.CENTER

    self.data.textStencil = false
    self.data.textMultiline = false

    self.data.textWrap = false
    self.data.textWraped = nil
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    return
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
    self.data.textMultiline = string.match( self.data.text, "\n" ) ~= nil

    if self.data.textWrap then
        self.data.textWraped = nil
    end
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

Element.setAlignY = function( self, align )
    self:sysValidate()
    checkType( align, "number" )
    checkEnum( align, "TEXT_ALIGN" )

    self.data.textAlignY = align
end

Element.setAlign = function( self, alignx, aligny )
    self:setAlignX( alignx )
    self:setAlignX( aligny )
end

-- Функция получения выравнивания
Element.getAlignX = function( self )
    self:sysValidate()
    return self.data.textAlignX
end

Element.getAlignY = function( self )
    self:sysValidate()
    return self.data.textAlignY
end

Element.getAlign = function( self )
    self:sysValidate()
    return self.data.textAlignX, self.data.textAlignY
end


-- Функция переноса текста
Element.setWrap = function( self, wrap )
    self:sysValidate()
    checkType( wrap, "boolean" )

    self.data.textWrap = wrap
    self.data.textWraped = nil

    if not self.data.textWrap then
        self.data.textMultiline = string.match( self.data.text, "\n" ) ~= nil
    end
end

Element.getWrap = function( self )
    self:sysValidate()
    return self.data.textWrap
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Функция отрисовки текста
local text, tw, th, tx, ty, ts = "", 0, 0, 0, 0, 4
Element.paintText = function( self )
    render.setRGBA( self.data.colors.text.r, self.data.colors.text.g, self.data.colors.text.b, self.data.colors.text.a )
    render.setFont( self.data.textFont )

    -- расстанровка переносов
    if self.data.textWrap and not self.data.textWraped then
        self.data.textWraped = ""

        local line, wx, wy = "", 0, 0
        for _, word in pairs( string.explode( " ", self.data.text ) ) do
            word = word .. " "

            wx, wy = render.getTextSize( word )
            if wx > ( self.data.sizeGlobal.w - ts ) then
                self.data.textWraped = self.data.textWraped .. ( #line == 0 and "" or ( string.trim( line ) .. "\n" ) ) .. string.trim( word ) .. "\n"
                line = ""
                continue
            end

            wx, wy = render.getTextSize( line .. word )
            if wx > ( self.data.sizeGlobal.w - ts ) then
                self.data.textWraped = self.data.textWraped .. string.trim( line ) .. "\n"
                line = word
                continue
            end

            line = line .. word
        end

        self.data.textWraped = self.data.textWraped .. line
        self.data.textMultiline = string.match( self.data.textWraped, "\n" ) ~= nil
    end

    text = self.data.textWrap and self.data.textWraped or self.data.text

    tw, th = render.getTextSize( text )
    self.data.textStencil = ( tw > ( self.data.sizeGlobal.w - ts ) ) or ( th > ( self.data.sizeGlobal.h - ts ) )

    -- yanderedev момент 💀
    if      self.data.textAlignX == TEXT_ALIGN.LEFT     then tx = self.data.positionGlobal.x + ts
    elseif  self.data.textAlignX == TEXT_ALIGN.CENTER   then tx = self.data.positionGlobal.x + self.data.sizeGlobal.w / 2
    elseif  self.data.textAlignX == TEXT_ALIGN.RIGHT    then tx = self.data.positionGlobal.x + self.data.sizeGlobal.w - ts
    end

    if      self.data.textAlignY == TEXT_ALIGN.TOP      then ty = self.data.positionGlobal.y + ts
    elseif  self.data.textAlignY == TEXT_ALIGN.CENTER   then ty = self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 - th / 2
    elseif  self.data.textAlignY == TEXT_ALIGN.BOTTOM   then ty = self.data.positionGlobal.y + self.data.sizeGlobal.h - th - ts
    end

    render[ self.data.textMultiline and "drawText" or "drawSimpleText" ]( tx, ty, text, self.data.textAlignX, TEXT_ALIGN.TOP )
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

        if self.data.text ~= nil and self.data.text ~= "" then
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
    end

    for _, child in pairs( self.data.children ) do
        child:render()
    end
end


-- Возвращаем класс элемента
return Element
