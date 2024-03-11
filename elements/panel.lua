--@name wgui/e/panel
--@author cortez


-- Creating an Element class
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/panel", BaseElement )
Element.static.elementName = "panel"


-- Initialization function
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end

-- Paint
Element.paint = function( self )
    -- painting here
end


-- Return an Element class
return Element
