--@name wgui/e/renderSpace
--@author cortez


-- Creating an Element class
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/renderSpace", BaseElement )
Element.static.elementName = "renderSpace"

-- Function causes an error when someone tries to interact with the element
Element.static.interactionFailure = function( self )
    error( "You cannot interact with 'renderSpace' element" )
    return nil
end


-- Initialization function
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
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


-- Return an Element class
return Element
