--@name wgui
--@author cortez

--@includedir ./utils/
--@includedir ./elements/


-- Включение утилит
requiredir( "./utils/" )


-- Создание таблиц библиотеки
wgui = {}
wgui.registred = {}
wgui.renderSpace = {}


-- Cтандартная таблица цветов
wgui.palette = {
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

    local element = wgui.registred[ elementName ]:new()

    if parentType == "number" then
        if parent == RENDERSPACE.HUD then
            element:setParent( wgui.renderSpace.hud )
        elseif parent == RENDERSPACE.SCREEN then
            element:setParent( wgui.renderSpace.screen )
        end
    else
        element:setParent( parent )
    end

    return element
end


-- Функция проверки зарегестрирован элемент или нет
wgui.isRegister = function( elementName )
    checkType( elementName, "string" )
    return not not wgui.registred[ elementName ]
end


-- Функиця регистрации элемента
wgui.register = function( elementName, elementClass )
    checkType( elementName, "string" )
    checkType( elementClass, "table" )

    wgui.registred[ elementName ] = elementClass
end


-- Регистрация элементов
local function registerIncludedElements()
    local custom = {
        [ "base" ] = function() end,
        [ "renderSpace" ] = function( elementClass )
            local scrw, scrh = render.getGameResolution()

            -- hud
            wgui.renderSpace.hud = elementClass:new()
            wgui.renderSpace.hud.data.hud = true
            wgui.renderSpace.hud.data.sizeLocal = { w = scrw, h = scrh }
            wgui.renderSpace.hud.data.type = RENDERSPACE.HUD
            wgui.renderSpace.hud:sysRecalculate()

            -- screen
            wgui.renderSpace.screen = elementClass:new()
            wgui.renderSpace.screen.data.sizeLocal = { w = 1024, h = 1024 }
            wgui.renderSpace.screen.data.type = RENDERSPACE.SCREEN
            wgui.renderSpace.screen:sysRecalculate()
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


-- hooks
hook.add( "InputPressed", "wgui:hook:InputPressed", function( key )
    for _, rs in pairs( wgui.renderSpace ) do
        if not rs.cursor.enabled then continue end -- Проверка активен ли курсор renderSpace
        -- if not rs.data.hoverElement then continue end

        local hover = rs.data.hoverElement

        if key == 107 then
            if hover then
                if ( rs.cursor.dblclickElement == hover ) and ( ( timer.curtime() - rs.cursor.dblclickTime ) < 0.2 ) then
                    hover.events.dblclick( hover )
                    rs.cursor.dblclickTime = 0
                    rs.cursor.dblclickElement = nil
                else
                    hover.events.click( hover )
                    rs.cursor.dblclickTime = timer.curtime()
                    rs.cursor.dblclickElement = hover
                end
            end

            rs.cursor.keyLeft = true
            rs.cursor.clickTime = timer.curtime()
            rs.cursor.clickElement = hover
        elseif key == 108 then
            if hover then
                hover.events.rightclick( hover )
            end

            rs.cursor.keyRight = true
        end
    end
end )

hook.add( "InputReleased", "wgui:hook:InputReleased", function( key )
    for _, rs in pairs( wgui.renderSpace ) do
        if not ( rs.cursor.keyLeft or rs.cursor.keyRight ) then continue end

        if key == 107 then
            rs.cursor.keyLeft = false
            rs.cursor.clickElement = nil
        elseif key == 108 then
            rs.cursor.keyRight = false
        end
    end
end )

hook.add( "onScreenSizeChanged", "wgui:hook:onScreenSizeChanged", function( w, h )
    wgui.renderSpace.hud.data.sizeLocal = { w = w, h = h }
    wgui.renderSpace.hud:sysRecalculate()
end )

hook.add( "RenderOffscreen", "wgui:hook:RenderOffscreen", function()
    -- screen render
    -- тута будет рендер рендерспейсав на рендертаргетах
    -- у каждава рендерспейса СВОй рендертаргет
    -- чооооо
end )

hook.add( "render", "wgui:hook:render", function()
    -- screen render
    -- а тут будит проста рендер рендертаргетов л о л
    -- типа renderSpace:process() л о л
end )

hook.add( "drawhud", "wgui:hook:drawhud", function()
    wgui.renderSpace.hud:process()
end )


return wgui
