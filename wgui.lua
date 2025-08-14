--@name wgui
--@author cortez

--@includedir ./utils/
--@includedir ./elements/


-- Включение утилит
requiredir( "./utils/" )



-- Создание таблиц библиотеки
wgui = {}
wgui.__registred = {}
wgui.__renderSpace = {}


-- Функция создания элемента
wgui.create = function( elementName, parent )
    checkType( elementName, "string" )
    local _, parentType = checkType( parent, { "wgui", "number" } )

    if not wgui.isRegister( elementName ) then
        throw( "Specified element is not registred" )
    end

    local element = wgui.__registred[ elementName ]:new()

    if parentType == "number" then
        if parent == RENDERSPACE.HUD then
            element:setParent( wgui.__renderSpace.hud )
        elseif parent == RENDERSPACE.SCREEN then
            element:setParent( wgui.__renderSpace.screen )
        end
    else
        element:setParent( parent )
    end

    return element
end


-- Функция проверки зарегестрирован элемент или нет
wgui.isRegister = function( elementName )
    checkType( elementName, "string" )
    return not not wgui.__registred[ elementName ]
end


-- Функиця регистрации элемента
wgui.register = function( elementName, elementClass )
    checkType( elementName, "string" )
    checkType( elementClass, "table" )

    wgui.__registred[ elementName ] = elementClass
end







-- Регистрация элементов
local function registerIncludedElements()
    local custom = {
        [ "base" ] = function() end,
        [ "renderSpace" ] = function( elementClass )
            -- hud
            wgui.__renderSpace.hud = elementClass:new()
            local scrw, scrh = render.getGameResolution()
            wgui.__renderSpace.hud.__data.overflowBox = { left = 0, top = 0, right = scrw, bottom = scrh }
            wgui.__renderSpace.hud.__data.hitbox = { left = 0, top = 0, right = scrw, bottom = scrh }
            wgui.__renderSpace.hud.__data.sizeLocal = { w = scrw, h = scrh }
            wgui.__renderSpace.hud.__data.sizeGlobal = { w = scrw, h = scrh }

            -- screen
            wgui.__renderSpace.screen = elementClass:new()
            wgui.__renderSpace.screen.__data.overflowBox = { left = 0, top = 0, right = 1024, bottom = 1024 }
            wgui.__renderSpace.screen.__data.hitbox = { left = 0, top = 0, right = 1024, bottom = 1024 }
            wgui.__renderSpace.hud.__data.sizeLocal = { w = 1024, h = 1024 }
            wgui.__renderSpace.hud.__data.sizeGlobal = { w = 1024, h = 1024 }
        end
    }

    for _, elementClass in pairs( requiredir( "./elements/" ) ) do
        local elementName = elementClass.static.elementName

        if custom[ elementName ] then
            custom[ elementName ]( elementClass )
            continue
        end

        wgui.register( elementName, elementClass )
    end
end

registerIncludedElements()


-- debug
hook.add( "drawhud", "wgui:hook:drawhud", function()
    wgui.__renderSpace.hud:render()
end )


return wgui
