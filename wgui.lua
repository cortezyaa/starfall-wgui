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


-- Cтандартная таблица цветов
wgui.__style = {}
wgui.__style.transitionLevel = 0 -- Не трогать
wgui.__style.transitionTime = 0.25 -- Трогать ❤
wgui.__style.palette = {
    fill = Color( 20, 20, 20, 255 ),
    border = Color( 130, 50, 255, 255 ),

    button = Color( 40, 40, 40, 255 ),
    button_hover = Color( 80, 80, 80, 255 ),

    button_text = Color( 180, 180, 180, 255 ),
    button_text_hover = Color( 255, 255, 255, 255 ),

    button_selected = Color( 130, 50, 255, 255 ),
    button_selected_hover = Color( 190, 110, 255, 255 ),
}


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
            local scrw, scrh = render.getGameResolution()

            -- hud
            wgui.__renderSpace.hud = elementClass:new()
            wgui.__renderSpace.hud.__data.hud = true
            wgui.__renderSpace.hud.__data.sizeLocal = { w = scrw, h = scrh }
            wgui.__renderSpace.hud:__recalculate()

            -- screen
            wgui.__renderSpace.screen = elementClass:new()
            wgui.__renderSpace.screen.__data.sizeLocal = { w = 1024, h = 1024 }
            wgui.__renderSpace.screen:__recalculate()
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


-- hud
hook.add( "onScreenSizeChanged", "wgui:hook:onScreenSizeChanged", function( w, h )
    wgui.__renderSpace.hud.__data.sizeLocal = { w = w, h = h }
    wgui.__renderSpace.hud:__recalculate()
end )

hook.add( "drawhud", "wgui:hook:drawhud", function()
    wgui.__renderSpace.hud:process()
end )



return wgui
