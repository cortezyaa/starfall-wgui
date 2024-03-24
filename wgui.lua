--@name wgui
--@author cortez

-- version : 0.1


--[[
    todo list:


    перерасчет элементов при изменении
        ? self.__shouldRecalculate
        чета надо придумать


    renderSpaceWorld
        придумать реализацию

        система должна:
            поддерживать несколько плоскостей для рендера
            правильно рассчитывать положения курсора на элементе
            выбирать приоритетную панель ( т.е. если несколько плоскостей находятся рядом )
                скорее всего надо будет брать глобал позицию курсора на каждой плоскости
                и выбирать ту плоскость, где курсор ближе к пользователю

        по возможности:
            добавить возможность рендера на изогнутых поверхностях
            выбор хука где рендерить


    Dock
        небольшая справочка а то я далбаеб забываю скил исуе
            padding - внутренний отступ
            margin - внешний отступ
        
        реализация примерно должна быть как в gmod'е
    
    
    hook'и
        -- ?
    
        
    позже: render, cursor, hover, drag & drop, callback'и, анимации
]]


-- Including utils
requiredir( "./utils/" ) --@includedir ../utils/


-- Creating main table
wgui = {}

-- Creating data table
wgui.__data = {}

wgui.__data.registred = {}

wgui.__data.rsHud = nil

wgui.__data.rsScreen = nil
wgui.__data.rsScreenRTname = "wguirsscreenrt"
wgui.__data.rsScreenRT = render.createRenderTarget( wgui.__data.rsScreenRTname )
wgui.__data.rsScreenMat = material.create( "gmodscreenspace" )
wgui.__data.rsScreenMat:setTextureRenderTarget( "$basetexture", wgui.__data.rsScreenRTname )

wgui.__data.rsWorld = {}
-- ? wgui.__data.rsWorldOrder = {}

-- smth like that
-- wgui.__data.__rsWorld = { rs = {}, order = {} }


--
wgui.isRegistred = function( elementName )
    checkType( elementName, "string" )

    return not not wgui.__data.registred[ elementName ]
end


--
wgui.register = function( elementName, elementClass )
    checkType( elementName, "string" )
    checkType( elementClass, "table" )

    if wgui.isRegistred( elementName ) then
        error( "Element with the specified name is already registered" )
    end

    wgui.__data.registred[ elementName ] = elementClass
end


-- 
wgui.create = function( elementName, parent )
    checkType( elementName, "string" )
    local _, parentT = checkType( parent, { "wgui", "number" } )

    if not wgui.isRegistred( elementName ) then
        error( "Specified element is not registered" )
    end

    local element = wgui.__data.registred[ elementName ]:new()

    if parentT == "number" then
        if parent == RENDERSPACE.HUD then
            element.__data.renderSpace = wgui.__data.rsHud
            table.insert( wgui.__data.rsHud.__data.children, element )
        elseif parent == RENDERSPACE.SCREEN then
            element.__data.renderSpace = wgui.__data.rsScreen
            table.insert( wgui.__data.rsScreen.__data.children, element )
        elseif parent == RENDERSPACE.WORLD then
            -- idk now
        end
    else
        element:setParent( parent )
    end

    return element
end


-- Including elements
--@includedir ./elements/
local registerIncludedElements = function()
    local custom = {
        [ "baseElement" ] = function( elementClass ) end,
        [ "renderSpace" ] = function( elementClass )
            wgui.__data.rsHud = elementClass:new()
            wgui.__data.rsScreen = elementClass:new()
        end,
    }

    for _, elementClass in pairs( requiredir( "./elements/" ) ) do
        local elementName = elementClass.static.elementName

        if custom[ elementName ] then
            custom[ elementName ]( elementClass )
        end

        wgui.register( elementName, elementClass )
    end
end

registerIncludedElements()


--
return wgui
