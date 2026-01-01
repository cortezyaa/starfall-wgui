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

    self.data.spaceSize = 0
    self.data.spaceOffset = 0

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


-- Системная функция перерасчета элемента
Element.sysRecalculation = function( self )
    local fill = {}
    local space = {
        left = self.data.dockPadding.left,
        top = self.data.dockPadding.top,
        right = self.data.sizeGlobal.w - self.data.dockPadding.right - ( self.data.horizontal and 0 or self.data.thumbWidth ),
        bottom = self.data.sizeGlobal.h - self.data.dockPadding.bottom - ( self.data.horizontal and self.data.thumbWidth or 0 )
    }

    if self.data.horizontal then
        self.data.hitbox.top = self.data.hitbox.bottom - ( self.data.hitbox.top == self.data.hitbox.bottom and 0 or self.data.thumbWidth )
    else
        self.data.hitbox.left = self.data.hitbox.right - ( self.data.hitbox.left == self.data.hitbox.right and 0 or self.data.thumbWidth )
    end

    for _, child in pairs( self.data.children ) do
        if child.data.dock == DOCK.NODOCK then
            child.data.positionGlobal.x = self.data.positionGlobal.x + child.data.positionLocal.x
            child.data.positionGlobal.y = self.data.positionGlobal.y + child.data.positionLocal.y

            child.data.sizeGlobal.w = child.data.sizeLocal.w
            child.data.sizeGlobal.h = child.data.sizeLocal.h
        elseif child.data.dock == DOCK.FILL then
            table.insert( fill, child )
        elseif child.data.dock == DOCK.LEFT then
            child.data.positionGlobal.x = self.data.positionGlobal.x + space.left + child.data.dockMargin.left
            child.data.positionGlobal.y = self.data.positionGlobal.y + space.top + child.data.dockMargin.top

            child.data.sizeGlobal.w = child.data.sizeLocal.w
            child.data.sizeGlobal.h = space.bottom - space.top - child.data.dockMargin.top - child.data.dockMargin.bottom

            space.left = space.left + child.data.sizeGlobal.w + child.data.dockMargin.left + child.data.dockMargin.right
        elseif child.data.dock == DOCK.TOP then
            child.data.positionGlobal.x = self.data.positionGlobal.x + space.left + child.data.dockMargin.left
            child.data.positionGlobal.y = self.data.positionGlobal.y + space.top + child.data.dockMargin.top

            child.data.sizeGlobal.w = space.right - space.left - child.data.dockMargin.left - child.data.dockMargin.right
            child.data.sizeGlobal.h = child.data.sizeLocal.h

            space.top = space.top + child.data.sizeGlobal.h + child.data.dockMargin.top + child.data.dockMargin.bottom
        elseif child.data.dock == DOCK.RIGHT then
            child.data.positionGlobal.x = self.data.positionGlobal.x + space.right - child.data.sizeLocal.w - child.data.dockMargin.right
            child.data.positionGlobal.y = self.data.positionGlobal.y + space.top + child.data.dockMargin.top
                
            child.data.sizeGlobal.w = child.data.sizeLocal.w
            child.data.sizeGlobal.h = space.bottom - space.top - child.data.dockMargin.top - child.data.dockMargin.bottom
                
            space.right = space.right - child.data.sizeGlobal.w - child.data.dockMargin.left - child.data.dockMargin.right
        elseif child.data.dock == DOCK.BOTTOM then
            child.data.positionGlobal.x = self.data.positionGlobal.x + space.left + child.data.dockMargin.left
            child.data.positionGlobal.y = self.data.positionGlobal.y + space.bottom - child.data.sizeLocal.h - child.data.dockMargin.bottom
                
            child.data.sizeGlobal.w = space.right - space.left - child.data.dockMargin.left - child.data.dockMargin.right
            child.data.sizeGlobal.h = child.data.sizeLocal.h
                
            space.bottom = space.bottom - child.data.sizeGlobal.h - child.data.dockMargin.top - child.data.dockMargin.bottom
        end
    end

    self.data.spaceSize = 0

    for _, child in pairs( self.data.children ) do
        if table.hasValue( fill, child ) then
            child.data.positionGlobal.x = self.data.positionGlobal.x + space.left + child.data.dockMargin.left
            child.data.positionGlobal.y = self.data.positionGlobal.y + space.top + child.data.dockMargin.top
            
            child.data.sizeGlobal.w = space.right - space.left - child.data.dockMargin.left - child.data.dockMargin.right
            child.data.sizeGlobal.h = space.bottom - space.top - child.data.dockMargin.top - child.data.dockMargin.bottom
        end

        self.data.spaceSize = self.data.spaceSize + child.data.sizeGlobal[ self.data.horizontal and "w" or "h" ]
    end
    
    self.data.thumbLength = self.data.sizeGlobal[ self.data.horizontal and "w" or "h" ] * math.min( 1, self.data.sizeGlobal[ self.data.horizontal and "w" or "h" ] / self.data.spaceSize )
    self.data.thumbOffset = self.data.value * ( self.data.sizeGlobal[ self.data.horizontal and "w" or "h" ] - self.data.thumbLength )
    local track = ( self.data.spaceSize - self.data.sizeGlobal[ self.data.horizontal and "w" or "h" ] )
    self.data.spaceOffset = track <= 0 and 0 or track * self.data.value

    for _, child in pairs( self.data.children ) do
        child.data.positionGlobal[ self.data.horizontal and "x" or "y" ] = child.data.positionGlobal[ self.data.horizontal and "x" or "y" ] - self.data.spaceOffset

        local x = child.data.positionGlobal.x
        local y = child.data.positionGlobal.y
        local w = child.data.sizeGlobal.w
        local h = child.data.sizeGlobal.h

        if child.data.overflow == OVERFLOW.VISIBLE then
            child.data.overflowBox.left = self.data.overflowBox.left
            child.data.overflowBox.top = self.data.overflowBox.top
            child.data.overflowBox.right = self.data.overflowBox.right
            child.data.overflowBox.bottom = self.data.overflowBox.bottom
        else
            child.data.overflowBox.left = math.max( x, self.data.overflowBox.left )
            child.data.overflowBox.top = math.max( y, self.data.overflowBox.top )
            child.data.overflowBox.right = math.min( x + w, self.data.overflowBox.right )
            child.data.overflowBox.bottom = math.min( y + h, self.data.overflowBox.bottom )
        end

        child.data.hitbox.left = math.clamp( math.max( x, child.data.overflowBox.left ), child.data.overflowBox.left, child.data.overflowBox.right )
        child.data.hitbox.top = math.clamp( math.max( y, child.data.overflowBox.top ), child.data.overflowBox.top, child.data.overflowBox.bottom )
        child.data.hitbox.right = math.clamp( math.min( x + w, child.data.overflowBox.right ), child.data.overflowBox.left, child.data.overflowBox.right )
        child.data.hitbox.bottom = math.clamp( math.min( y + h, child.data.overflowBox.bottom ), child.data.overflowBox.top, child.data.overflowBox.bottom )

        child.data.shouldUseStencil = ( x < child.data.overflowBox.left ) or ( y < child.data.overflowBox.top ) or ( ( x + w ) > child.data.overflowBox.right ) or ( ( y + h ) > child.data.overflowBox.bottom )
        child.data.shouldDraw = not ( ( x > child.data.overflowBox.right ) or ( y > child.data.overflowBox.bottom ) or ( ( x + w ) < child.data.overflowBox.left ) or ( ( y + h ) < child.data.overflowBox.top ) )

        child:sysRecalculation()
    end
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    self.data.colors.thumb.r = math.lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
    self.data.colors.thumb.g = math.lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
    self.data.colors.thumb.b = math.lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
    self.data.colors.thumb.a = math.lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
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
    render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
    render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    if self.data.horizontal then
        render.setRGBA( self.data.colors.back.r, self.data.colors.back.g, self.data.colors.back.b, self.data.colors.back.a )
        render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y + self.data.sizeGlobal.h - self.data.thumbWidth, self.data.sizeGlobal.w, self.data.thumbWidth )

        render.setRGBA( self.data.colors.thumb.r, self.data.colors.thumb.g, self.data.colors.thumb.b, self.data.colors.thumb.a )
        render.drawRectFast( self.data.positionGlobal.x + self.data.thumbOffset, self.data.positionGlobal.y + self.data.sizeGlobal.h - self.data.thumbWidth, self.data.thumbLength, self.data.thumbWidth )
    else
        render.setRGBA( self.data.colors.back.r, self.data.colors.back.g, self.data.colors.back.b, self.data.colors.back.a )
        render.drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w - self.data.thumbWidth, self.data.positionGlobal.y, self.data.thumbWidth, self.data.sizeGlobal.h )

        render.setRGBA( self.data.colors.thumb.r, self.data.colors.thumb.g, self.data.colors.thumb.b, self.data.colors.thumb.a )
        render.drawRectFast( self.data.positionGlobal.x + self.data.sizeGlobal.w - self.data.thumbWidth, self.data.positionGlobal.y + self.data.thumbOffset, self.data.thumbWidth, self.data.thumbLength )
    end
end


-- Возвращаем класс элемента
return Element
