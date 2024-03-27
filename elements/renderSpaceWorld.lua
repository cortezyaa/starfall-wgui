--@name wgui/e/renderSpaceWorld
--@author cortez


-- Creating an Element class
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/renderSpaceWorld", BaseElement )
Element.static.elementName = "renderSpaceWorld"

-- Function causes an error when someone tries to interact with the element
Element.static.interactionFailure = function( self )
    error( "You cannot interact with 'renderSpaceWorld' element" )
    return nil
end


-- Initialization function
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    -- self.cursor2d = { x = nil, y = nil }
    
    -- должна быть матрица, к которой будет всё привязано
end

-- Overwrite default methods
local function overwriteMethods()
    local whitelist = {
        [ "initialize" ] = true,
        [ "__tostring" ] = true,
    }

    for methodName, methodFunction in pairs( BaseElement.__declaredMethods ) do
        if whitelist[ methodName ] then continue end
        Element[ methodName ] = Element.static.interactionFailure
    end
end

overwriteMethods()

-- Position
Element.setPosition = function( self, position )
    -- устанавливает позицию элемента в мире
end


-- Return an Element class
return Element
