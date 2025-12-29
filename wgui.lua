--@name wgui
--@author cortez

--@includedir ./utils/
--@includedir ./elements/


-- Включение утилит
requiredir( "./utils/" )


-- Создание таблиц библиотеки
wgui = {}
wgui.registred = {}
wgui.renderSpaces = { HUD = {}, SCREEN = {}, WORLD = {} }
wgui.links = {}

-- debug
wgui.debug = true

-- Cтандартная таблица цветов
wgui.palette = {
    fill = Color( 20, 20, 20, 255 ),
    border = Color( 130, 50, 255, 255 ),

    button = Color( 40, 40, 40, 255 ),
    button_hover = Color( 80, 80, 80, 255 ),

    button_selected = Color( 130, 50, 255, 255 ),
    button_selected_hover = Color( 190, 110, 255, 255 ),
    
    text = Color( 180, 180, 180, 255 ),
    text_hover = Color( 255, 255, 255, 255 ),
}


-- Функция создания элемента
wgui.create = function( elementName, parent )
    checkType( elementName, "string" )
    checkType( parent, "wgui" )

    if not wgui.isRegistred( elementName ) then
        throw( "Specified element is not registred" )
    end

    local element = wgui.registred[ elementName ]:new()
    element:sysRecalculateColors()

    element:setParent( parent )

    return element
end


-- Функция создания renderSpace элемента
wgui.createRenderSpace = function( renderSpaceType )
    checkType( renderSpaceType, "number" )
    checkEnum( renderSpaceType, "RENDERSPACE" )

    if not wgui.isRegistred( RENDERSPACENAME[ renderSpaceType ] ) then
        throw( "Specified element is not registred" )
    end

    local element = wgui.registred[ RENDERSPACENAME[ renderSpaceType ] ]:new()

    if renderSpaceType == RENDERSPACE.HUD then
        element.data.sizeLocal.w, element.data.sizeLocal.h = render.getGameResolution()
        element:sysRecalculate()

        table.insert( wgui.renderSpaces.HUD, element )
    elseif renderSpaceType == RENDERSPACE.SCREEN then
        element.data.sizeLocal.w, element.data.sizeLocal.h = 1024, 1024 -- Стандартное разрешение renderTarget'а
        element:sysRecalculate()

        table.insert( wgui.renderSpaces.SCREEN, element )
    elseif renderSpaceType == RENDERSPACE.WORLD then
        element.data.sizeLocal.w, element.data.sizeLocal.h = 1024, 1024
        element:sysRecalculate()
        
        table.insert( wgui.renderSpaces.WORLD, element )
    end

    return element
end


-- Функция проверки зарегестрирован элемент или нет
wgui.isRegistred = function( elementName )
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
hook.add( "InputPressed", "wgui:hook:InputPressed", function( button )
    for rst, category in pairs( wgui.renderSpaces ) do
        for _, rs in pairs( category ) do
            if not rs.cursor.enabled then continue end -- Проверка активен ли курсор

            local focus = rs.data.focusElement

            if focus and focus.data.keyboardInput == true then
                local key = KEYBOARD[ ( input.isShiftDown() and "u" or "" ) .. tostring( button ) ]

                if key then
                    if key == "ENTER" then
                        focus.data.focus = false
                        focus:callEvent( WGUIEVENTS.FOCUSOFF )
                        rs.data.focusElement = nil
                        focus:setValue( focus.data.value )
                    elseif key == "BACKSPACE" then
                        focus.data.value = string.sub( focus.data.value, 1, #focus.data.value - 1 )
                    else
                        focus.data.value = focus.data.value .. key
                    end
                end

                continue
            end

            local hover = rs.data.hoverElement

            if button == 107 or ( button == 15 and rst ~= RENDERSPACENAME[ RENDERSPACE.HUD ] ) then
                if hover then
                    if ( rs.cursor.dblclickElement == hover ) and ( ( timer.curtime() - rs.cursor.dblclickTime ) < 0.2 ) then
                        hover:callEvent( WGUIEVENTS.DOUBLECLICK )
                        rs.cursor.dblclickTime = 0
                        rs.cursor.dblclickElement = nil
                    else
                        hover:callEvent( WGUIEVENTS.CLICK )
                        rs.cursor.dblclickTime = timer.curtime()
                        rs.cursor.dblclickElement = hover
                    end
                end

                rs.cursor.keyLeft = true
                rs.cursor.clickTime = timer.curtime()
                rs.cursor.clickElement = hover
                rs.cursor.clickPosition.x, rs.cursor.clickPosition.y = rs.cursor.position.x, rs.cursor.position.y

                if rs.data.focusElement ~= hover then
                    local oldfocus = rs.data.focusElement

                    if rs.data.focusElement then
                        rs.data.focusElement.data.focus = false
                        rs.data.focusElement:callEvent( WGUIEVENTS.FOCUSOFF )
                    end

                    rs.data.focusElement = hover.isRenderSpace == true and nil or hover
                    rs:callEvent( WGUIEVENTS.FOCUSCHANGED, rs.data.focusElement, oldfocus )

                    if rs.data.focusElement then
                        rs.data.focusElement.data.focus = true
                        rs.data.focusElement:callEvent( WGUIEVENTS.FOCUSON )
                    end
                end
            elseif button == 108 then
                if hover then
                    hover:callEvent( WGUIEVENTS.RIGHTCLICK )
                end

                rs.cursor.keyRight = true
            end
        end
    end
end )

hook.add( "InputReleased", "wgui:hook:InputReleased", function( button )
    for rst, category in pairs( wgui.renderSpaces ) do
        for _, rs in pairs( category ) do
            if not ( rs.cursor.keyLeft or rs.cursor.keyRight ) then continue end

            if button == 107 or ( button == 15 and rst ~= RENDERSPACENAME[ RENDERSPACE.HUD ] ) then
                rs.cursor.clickElement:callEvent( WGUIEVENTS.CLICKRELEASE )
                rs.cursor.keyLeft = false
                rs.cursor.clickElement = nil
            elseif button == 108 then
                rs.cursor.keyRight = false
            end
        end
    end
end )

hook.add( "onScreenSizeChanged", "wgui:hook:onScreenSizeChanged", function( w, h )
    for _, rs in pairs( wgui.renderSpaces.HUD ) do
        rs.data.sizeLocal.w, rs.data.sizeLocal.h = w, h
        rs:sysRecalculate()
    end
end )

hook.add( "DrawHUD", "wgui:hook:DrawHUD", function()
    for _, rs in pairs( wgui.renderSpaces.HUD ) do
        rs:process()
    end
end )

hook.add( "RenderOffscreen", "wgui:hook:RenderOffscreen", function()
    for _, rs in pairs( wgui.renderSpaces.SCREEN ) do
        rs:process()
    end
end )

hook.add( "render", "wgui:hook:render", function()
    local screen = render.getScreenEntity()

    for _, rs in pairs( wgui.renderSpaces.SCREEN ) do
        if rs.data.screen ~= screen then continue end

        local w, h = render.getResolution()
        local x, y = render.cursorPos()
        rs.cursor.enabled = not not x

        if rs.cursor.enabled and ( x ~= rs.cursor.position.x or y ~= rs.cursor.position.y ) then
            rs.cursor.position.x, rs.cursor.position.y = math.round( x / w * rs.data.sizeGlobal.w ), math.round( y / h * rs.data.sizeGlobal.h )
            rs:callEvent( WGUIEVENTS.CURSORMOVED, rs.cursor.position.x, rs.cursor.position.y )
        end

        render.setRenderTargetTexture( rs.data.renderTarget )
        render.drawTexturedRect( 0, 0, w, h )
    end
end )

hook.add( "PostDrawOpaqueRenderables", "wgui:hook:PostDrawOpaqueRenderables", function()
    for _, rs in pairs( wgui.renderSpaces.WORLD ) do
        rs:process()
    end
end )

-- Подчищаю мусор?
hook.add( "Removed", "wgui:hook:Removed", function()
    for _, rs in pairs( wgui.renderSpaces.SCREEN ) do
        rs:callEvent( WGUIEVENTS.REMOVED ) 
    end
end )


return wgui
