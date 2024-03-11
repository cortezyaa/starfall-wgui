--@name wgui
--@author cortez

-- version : 0.1


-- Including utils
requiredir( "./utils/" ) --@includedir ../utils/


-- Creating main tables and variables
wgui = {}
wgui.__data = {}
wgui.__data.registred = {}
wgui.__data.renderSpaceHud = nil
wgui.__data.renderSpaceScreen = nil


--
wgui.create = function( elementName, parent )
    checkType( elementName, "string" )
    local _, parentType = checkType( parent, { "wgui", "number" } )

    local element = wgui.__data.registred[ elementName ]:new()

    if parentType == "wgui" then
        element:setParent( parent )
        element.__data.renderSpace = parent.__data.renderSpace
    else
        

        -- table.insert( element.__data.renderSpace.__data.children, element )
        -- element.__data.renderSpace = nil
    end

    return element
end

--
wgui.register = function( elementName, elementClass )
    checkType( elementName, "string" )
    checkType( elementClass, "table" )
    
    wgui.__data.registred[ elementName ] = elementClass
end


-- Including elements
--@includedir ./elements/
local function registerIncludedElements = function()
    local custom = {
        [ "baseElement" ] = function( elementClass ) end,
        [ "renderSpace" ] = function( elementClass )
            wgui.__data.renderSpaceHud = elementClass:new()
            wgui.__data.renderSpaceScreen = elementClass:new()
        end,
    }

    for _, elementClass in pairs( requiredir( "./elements/" ) ) do
        local elementName = elementClass.static.elementName

        if custom[ elementName ] then
            custom[ elementName ]( elementName )
            continue
        end

        wgui.register( elementName, elementClass )
    end
end

registerIncludedElements()


-- render


