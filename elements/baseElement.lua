--@name wgui/e/baseElement
--@author cortez


-- Including utils
requiredir( "../utils/" ) --@includedir ../utils/


-- Creating an Element class
local Element = class( "wgui/e/baseElement" )
Element.static.elementName = "baseElement"

-- Function for generating uid
Element.static.chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
Element.static.charsLength = string.len( Element.static.chars )
Element.static.uid = function()
    local uid = ""

    for _ = 1, 10 do
        uid = uid .. Element.static.chars[ math.random( 1, Element.static.charsLength ) ]
    end

    return uid
end

-- Function checks the validity of the element and if it is not valid, it raises an error
Element.static.validate = function( self )
    if self.__valid then return end
    error( "Element is not valid" )
end

-- Function for recalculating the position, size, docking of an element when changing
Element.static.calculate = function( self, ignore )

    
    --[[
        Я В РОТ ЭТОГО ЕБАЛ
        БЕЗ ПИВА НЕ РАЗОБРАТЬСЯ

    if self.__data.dockType == DOCK.NODOCK then
        self.__data.positionGlobal.x = self.__data.positionLocal.x + ( self.__data.parent and self.__data.parent.__data.positionGlobal.x or 0 )
        self.__data.positionGlobal.y = self.__data.positionLocal.y + ( self.__data.parent and self.__data.parent.__data.positionGlobal.y or 0 )
        self.__data.sizeGlobal.w = self.__data.sizeLocal.w
        self.__data.sizeGlobal.h = self.__data.sizeLocal.h
    else
        if self.__data.parent ~= nil then
            if self.__data.parent ~= ignore then
                Element.static.calculate( self.__data.parent, self )
            end
        else
            -- Element.static.calculate( self.__data.renderSpace, self )

        end
    end

    local fillElements = {}
    local space = { l = 0, t = 0, r = self.__data.sizeGlobal.w, b = self.__data.sizeGlobal.h }

    if self.__data.parent then
        space.l = space.l + self.__data.parent.__data.dockPaddingLeft
        space.t = space.t + self.__data.parent.__data.dockPaddingTop
        space.r = space.r - self.__data.parent.__data.dockPaddingRight
        space.b = space.b - self.__data.parent.__data.dockPaddingBottom
    end

    for _, child in pairs( self.__data.children ) do


        if child.__data.dockType == DOCK.FILL then
            table.insert( fillElements, child )
        elseif child.__data.dockType == DOCK.LEFT then
            self.__data.sizeGlobal.w = self.__data.sizeLocal.w - self.__data.dockMarginLeft - self.__data.dockMarginRight
            self.__data.sizeGlobal.h = space.b - space.t - self.__data.dockMarginTop - self.__data.dockMarginBottom
            self.__data.positionGlobal.x = space.l + self.__data.dockMarginLeft
            self.__data.positionGlobal.y = space.t + self.__data.dockMarginTop

            space.l = space.l + self.__data.sizeLocal.w + self.__data.dockMarginLeft + self.__data.dockMarginRight
        elseif child.__data.dockType == DOCK.RIGHT then
            self.__data.sizeGlobal.w = self.__data.sizeLocal.w - self.__data.dockMarginLeft - self.__data.dockMarginRight
            self.__data.sizeGlobal.h = space.b - space.t - self.__data.dockMarginTop - self.__data.dockMarginBottom
            self.__data.positionGlobal.x = space.r - self.__data.dockMarginRight - self.__data.dockMarginLeft - self.__data.sizeGlobal.w
            self.__data.positionGlobal.y = space.t + self.__data.dockMarginTop

            space.r = space.r - self.__data.sizeGlobal.w - self.__data.dockMarginLeft - self.__data.dockMarginRight
        elseif child.__data.dockType == DOCK.TOP then
            self.__data.sizeGlobal.w = space.r - space.l - self.__data.dockMarginLeft - self.__data.dockMarginRight
            self.__data.sizeGlobal.h = self.__data.sizeLocal.h - self.__data.dockMarginTop - self.__data.dockMarginBottom
            self.__data.positionGlobal.x = space.l + self.__data.dockMarginLeft
            self.__data.positionGlobal.y = space.t + self.__data.dockMarginTop

            space.t = space.t + self.__data.sizeGlobal.h + self.__data.dockMarginTop + self.__data.dockMarginBottom
        elseif child.__data.dockType == DOCK.BOTTOM then
            self.__data.sizeGlobal.w = space.r - space.l - self.__data.dockMarginLeft - self.__data.dockMarginRight
            self.__data.sizeGlobal.h = self.__data.sizeLocal.h - self.__data.dockMarginTop - self.__data.dockMarginBottom
            self.__data.positionGlobal.x = space.l + self.__data.dockMarginLeft
            self.__data.positionGlobal.y = space.b + self.__data.dockMarginTop - self.__data.dockMarginBottom - self.__data.sizeGlobal.h

            space.b = space.b - self.__data.sizeGlobal.h - self.__data.dockMarginTop - self.__data.dockMarginBottom
        end
    end

    for _, child in pairs( fillElements ) do
        
    end

    for _, child in pairs( self.__data.children ) do
        if child == ignore then return end
        Element.static.calculate( child, self )
    end]]--



    
end


-- Initialization function
Element.initialize = function( self, elementName )
    checkType( elementName, "string" )

    self.__wgui = true
    self.__valid = true
     
    -- Element data
    self.__data = {}

    self.__data.uid = Element.static.uid()
    self.__data.elementName = elementName or Element.static.elementName

    self.__data.renderSpace = nil
    self.__data.parent = nil
    self.__data.children = {}

    self.__data.positionGlobal = { x = 0, y = 0 }
    self.__data.positionLocal = { x = 0, y = 0 }
    self.__data.sizeGlobal = { w = 0, h = 0 }
    self.__data.sizeLocal = { w = 0, h = 0 }

    self.__data.dockType = DOCK.NODOCK

    self.__data.dockMarginLeft = 0
    self.__data.dockMarginTop = 0
    self.__data.dockMarginRight = 0
    self.__data.dockMarginBottom = 0
    
    self.__data.dockPaddingLeft = 0
    self.__data.dockPaddingTop = 0
    self.__data.dockPaddingRight = 0
    self.__data.dockPaddingBottom = 0

    -- ? Element callbacks
    self.__callbacks = {}

    -- Aliases
end

-- Remove
Element.remove = function( self )
    Element.static.validate( self )

    for _, child in pairs( self.__data.children ) do
        child:remove()
    end

    if self.__data.parent then
        table.removeByValue( self.__data.parent.__data.children, self )
    else
        table.removeByValue( self.__data.renderSpace.__data.children, self )
    end

    self.__callback = {}
    self.__data = {}
    
    self.__valid = false
end

-- Valid
Element.isValid = function( self )
    return self.__valid
end

-- Parent and children
Element.setParent = function( self, parent )
    Element.static.validate( self )
    local _, parentType = checkType( parent, { "wgui", "nil" } )
    
    if parentType == "nil" then
        table.removeByValue( self.__data.parent, self )
        self.__data.parent = nil

        return
    end

    if parent == self.__data.parent then return end

    -- The universe almost exploded xd
    if table.hasValue( self.__data.children, parent ) then
        error( "Cannot parent child element" )
    end

    table.insert( parent.__data.children, self )
    self.__data.parent = parent

    Element.static.calculate( self )
end

Element.getParent = function( self )
    Element.static.validate( self )

    return self.__data.parent
end

Element.getChildren = function( self )
    Element.static.validate( self )

    return self.__data.children
end

-- Position
Element.setPosition = function( self, x, y )
    Element.static.validate( self )
    checkType( x, "number" )
    checkType( y, "number" )

    self.__data.positionLocal.x = x
    self.__data.positionLocal.y = y

    Element.static.calculate( self )
end

Element.getPosition = function( self )
    Element.static.validate( self )

    return self.__data.positionLocal.x, self.__data.positionLocal.y
end

Element.getPositionGlobal = function( self )
    Element.static.validate( self )

    return self.__data.positionGlobal.x, self.__data.positionGlobal.y
end

-- Size
Element.setSize = function( self, w, h )
    Element.static.validate( self )
    checkType( w, "number" )
    checkType( h, "number" )

    self.__data.sizeLocal.w = w
    self.__data.sizeLocal.h = h

    Element.static.calculate( self )
end

Element.getSize = function( self )
    Element.static.validate( self )

    return self.__data.sizeLocal.w, self.__data.sizeLocal.h
end

Element.getSizeGlobal = function( self )
    Element.static.validate( self )

    return self.__data.sizeGlobal.w, self.__data.sizeGlobal.h
end

-- Dock
Element.setDock = function( self, dockType )
    Element.static.validate( self )
    checkType( dockType, "number" )

    self.__data.dockType = dockType

    Element.static.calculate( self )
end

Element.setDockMargin = function( self, left, top, right, bottom )
    Element.static.validate( self )
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )

    self.__data.dockMarginLeft = left
    self.__data.dockMarginTop = top
    self.__data.dockMarginRight = right
    self.__data.dockMarginBottom = bottom

    Element.static.calculate( self )
end

Element.setDockPadding = function( self, left, top, right, bottom )
    Element.static.validate( self )
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )
    
    self.__data.dockPaddingLeft = left
    self.__data.dockPaddingTop = top
    self.__data.dockPaddingRight = right
    self.__data.dockPaddingBottom = bottom

    Element.static.calculate( self )
end

Element.getDock = function( self )
    Element.static.validate( self )

    return self.__data.dockType
end

Element.getDockMargin = function( self )
    Element.static.validate( self )

    return self.__data.dockMarginLeft, self.__data.dockMarginTop, self.__data.dockMarginRight, self.__data.dockMarginBottom
end

Element.getDockPadding = function( self )
    Element.static.validate( self )

    return self.__data.dockPaddingLeft, self.__data.dockPaddingTop, self.__data.dockPaddingRight, self.__data.dockPaddingBottom
end

-- Paint
Element.paint = function( self )
    return
end

-- Render
Element.render = function( self )
    if not self.__valid then return end

    self:paint()
end


-- Return an Element class
return Element
