--@name wgui/e/list


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/list", BaseElement )
Element.static.elementName = "list"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.horizontal = false

    self.data.value = 0
    self.data.valueOld = 0

    self.data.thumbWidth = 15
    self.data.thumbLength = 0
    self.data.thumbOffset = 0

    self.data.overflow = OVERFLOW.HIDDEN

    self.data.colors.fill = table.rgba( self.data.palette.fill )
    self.data.colors.back = table.rgba( self.data.palette.button )
    self.data.colors.thumb = table.rgba( self.data.palette.button_selected )

    -- Ивенты
    self.events.system.click = function( self )
        self.data.valueOld = self.data.value
    end

    self.events.system.hoverclick = function( self )
        self.data.transition = 1

        local delta = self.data.renderSpace.cursor.position[ self.data.horizontal and "x" or "y" ] - self.data.renderSpace.cursor.clickPosition[ self.data.horizontal and "x" or "y" ]
        local track = self.data.sizeGlobal[ self.data.horizontal and "w" or "h" ] - self.data.thumbLength
        local value = math.clamp( ( ( track * self.data.valueOld ) + delta ) / track, 0, 1 )

        self:setValue( value )
    end
    
    self.events.system.valuechanged = function( self, value, valueOld )
        self:sysRecalculate()
    end

    self.events.system.childrenadded = function( self, child )
        child:dock( DOCK[ self.data.horizontal and "LEFT" or "TOP" ] )
    end
end


-- Оптимизация?
local math_lerp = math.lerp
local math_max = math.max
local math_min = math.min
local math_clamp = math.clamp
local render_setRGBA = render.setRGBA
local render_drawRectFast = render.drawRectFast


-- Системная функция перерасчета элемента
local self_data, self_pgx, self_pgy
local children, child_data, child_margin, cx, cy, cw, ch, coLeft, coTop, coRight, coBottom
local spaceLeft, spaceTop, spaceRight, spaceBottom
local lHoriz, lWidth, lSpace, lOffset, lTrack

Element.sysRecalculation = function( self )
    self_data = self.data
    self_pgx = self_data.positionGlobal.x
    self_pgy = self_data.positionGlobal.y

    children = self_data.children

    lHoriz = self_data.horizontal
    lWidth = self_data.thumbWidth
    lSpace = 0
    lOffset = 0

    spaceLeft = self_data.dockPadding.left
    spaceTop = self_data.dockPadding.top
    spaceRight = self_data.sizeGlobal.w - self_data.dockPadding.right - ( lHoriz and 0 or lWidth )
    spaceBottom = self_data.sizeGlobal.h - self_data.dockPadding.bottom - ( lHoriz and lWidth or 0 )

    if lHoriz then
        self_data.hitbox.top = math_min( self_data.hitbox.bottom, self_pgy + self_data.sizeGlobal.h - lWidth )
    else
        self_data.hitbox.left = math_min( self_data.hitbox.right, self_pgx + self_data.sizeGlobal.w - lWidth )
    end

    for _, child in pairs( children ) do
        child_data = child.data
        child_margin = child_data.dockMargin

        if child_data.dock == DOCK.NODOCK then
            child_data.sizeGlobal.w = child_data.sizeLocal.w
            child_data.sizeGlobal.h = child_data.sizeLocal.h

            child_data.positionGlobal.x = self_pgx + child_data.positionLocal.x
            child_data.positionGlobal.y = self_pgy + child_data.positionLocal.y
        else
            if child_data.dock == DOCK.LEFT then
                child_data.sizeGlobal.w = child_data.sizeLocal.w -- math_max( 0, math_min( child_data.sizeLocal.w, spaceRight - spaceLeft ) )
                child_data.sizeGlobal.h = math_max( 0, spaceBottom - spaceTop - child_margin.top - child_margin.bottom )

                child_data.positionGlobal.x = self_pgx + spaceLeft + child_margin.left
                child_data.positionGlobal.y = self_pgy + spaceTop + child_margin.top

                spaceLeft = spaceLeft + child_data.sizeGlobal.w + child_margin.left + child_margin.right
            elseif child_data.dock == DOCK.TOP then
                child_data.sizeGlobal.w = math_max( 0, spaceRight - spaceLeft - child_margin.left - child_margin.right )
                child_data.sizeGlobal.h = child_data.sizeLocal.h -- math_max( 0, math_min( child_data.sizeLocal.h, spaceBottom - spaceTop ) )

                child_data.positionGlobal.x = self_pgx + spaceLeft + child_margin.left
                child_data.positionGlobal.y = self_pgy + spaceTop + child_margin.top

                spaceTop = spaceTop + child_data.sizeGlobal.h + child_margin.top + child_margin.bottom
            end
        end

        lSpace = lSpace + child_data.sizeGlobal[ lHoriz and "w" or "h" ]
    end

    self_data.thumbLength = self_data.sizeGlobal[ lHoriz and "w" or "h" ] * math.min( 1, self_data.sizeGlobal[ lHoriz and "w" or "h" ] / lSpace )
    self_data.thumbOffset = self_data.value * ( self_data.sizeGlobal[ lHoriz and "w" or "h" ] - self_data.thumbLength )
    lTrack = ( lSpace - self_data.sizeGlobal[ lHoriz and "w" or "h" ] )
    lOffset = lTrack <= 0 and 0 or lTrack * self_data.value

    for _, child in pairs( children ) do
        child_data.positionGlobal[ lHoriz and "x" or "y" ] = child_data.positionGlobal[ lHoriz and "x" or "y" ] - lOffset

        cx = child_data.positionGlobal.x
        cy = child_data.positionGlobal.y
        cw = child_data.sizeGlobal.w
        ch = child_data.sizeGlobal.h

        if child_data.overflow == OVERFLOW.VISIBLE then
            child_data.overflowBox.left = self_data.overflowBox.left
            child_data.overflowBox.top = self_data.overflowBox.top
            child_data.overflowBox.right = self_data.overflowBox.right
            child_data.overflowBox.bottom = self_data.overflowBox.bottom
        else
            child_data.overflowBox.left = math_clamp( cx, self_data.overflowBox.left, self_data.overflowBox.right )
            child_data.overflowBox.top = math_clamp( cy, self_data.overflowBox.top, self_data.overflowBox.bottom )
            child_data.overflowBox.right = math_clamp( cx + cw, self_data.overflowBox.left, self_data.overflowBox.right )
            child_data.overflowBox.bottom = math_clamp( cy + ch, self_data.overflowBox.top, self_data.overflowBox.bottom )
        end

        coLeft = child_data.overflowBox.left
        coTop = child_data.overflowBox.top
        coRight = child_data.overflowBox.right
        coBottom = child_data.overflowBox.bottom

        child_data.hitbox.left = math_clamp( math_max( cx, coLeft ), coLeft, coRight )
        child_data.hitbox.top = math_clamp( math_max( cy, coTop ), coTop, coBottom )
        child_data.hitbox.right = math_clamp( math_min( cx + cw, coRight ), coLeft, coRight )
        child_data.hitbox.bottom = math_clamp( math_min( cy + ch, coBottom ), coTop, coBottom )

        child_data.shouldUseStencil = 
            ( cx < coLeft ) or 
            ( cy < coTop ) or 
            ( ( cx + cw ) > coRight ) or 
            ( ( cy + ch ) > coBottom )

        child_data.shouldDraw = 
            ( cw >= 0 and ch >= 0 ) and
            ( cx <= coRight ) and
            ( cy <= coBottom ) and
            ( ( cx + cw ) >= coLeft ) and
            ( ( cy + ch ) >= coTop )

        child:sysRecalculation()
    end
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    self.data.colors.thumb.r = math_lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
    self.data.colors.thumb.g = math_lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
    self.data.colors.thumb.b = math_lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
    self.data.colors.thumb.a = math_lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
end


-- Функции управления ориентацией элементов
Element.setHorizontal = function( self, horizontal )
    self:sysValidate()
    checkType( horizontal, "boolean" )

    self.data.horizontal = horizontal

    for _, child in pairs( self.data.children ) do
        child:dock( DOCK[ self.data.horizontal and "LEFT" or "TOP" ] )
    end

    self:sysRecalculate()
end

Element.getHorizontal = function( self )
    self:sysValidate()
    return self.data.horizontal
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render_setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    if self.data.horizontal then
        render_setRGBA( self.data.colors.back.r, self.data.colors.back.g, self.data.colors.back.b, self.data.colors.back.a )
        render_drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y + self.data.sizeGlobal.h - self.data.thumbWidth, self.data.sizeGlobal.w, self.data.thumbWidth )

        render_setRGBA( self.data.colors.thumb.r, self.data.colors.thumb.g, self.data.colors.thumb.b, self.data.colors.thumb.a )
        render_drawRectFast( self.data.positionGlobal.x + self.data.thumbOffset, self.data.positionGlobal.y + self.data.sizeGlobal.h - self.data.thumbWidth, self.data.thumbLength, self.data.thumbWidth )
    else
        render_setRGBA( self.data.colors.back.r, self.data.colors.back.g, self.data.colors.back.b, self.data.colors.back.a )
        render_drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w - self.data.thumbWidth, self.data.positionGlobal.y, self.data.thumbWidth, self.data.sizeGlobal.h )

        render_setRGBA( self.data.colors.thumb.r, self.data.colors.thumb.g, self.data.colors.thumb.b, self.data.colors.thumb.a )
        render_drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w - self.data.thumbWidth, self.data.positionGlobal.y + self.data.thumbOffset, self.data.thumbWidth, self.data.thumbLength )
    end
end


-- Возвращаем класс элемента
return Element
