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

    button_text = Color( 180, 180, 180, 255 ),
    button_text_hover = Color( 255, 255, 255, 255 ),

    button_selected = Color( 130, 50, 255, 255 ),
    button_selected_hover = Color( 190, 110, 255, 255 ),
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
hook.add( "InputPressed", "wgui:hook:InputPressed", function( key )
    for _, category in pairs( wgui.renderSpaces ) do
        for _, rs in pairs( category ) do
            if not rs.cursor.enabled then continue end -- Проверка активен ли курсор

            local hover = rs.data.hoverElement

            if key == 107 then
                if hover then
                    if ( rs.cursor.dblclickElement == hover ) and ( ( timer.curtime() - rs.cursor.dblclickTime ) < 0.2 ) then
                        hover:callEvent( "doubleclick" )
                        rs.cursor.dblclickTime = 0
                        rs.cursor.dblclickElement = nil
                    else
                        hover:callEvent( "click" )
                        rs.cursor.dblclickTime = timer.curtime()
                        rs.cursor.dblclickElement = hover
                    end
                end

                rs.cursor.keyLeft = true
                rs.cursor.clickTime = timer.curtime()
                rs.cursor.clickElement = hover
            elseif key == 108 then
                if hover then
                    hover:callEvent( "rightclick" )
                end

                rs.cursor.keyRight = true
            end
        end
    end
end )

hook.add( "InputReleased", "wgui:hook:InputReleased", function( key )
    for _, category in pairs( wgui.renderSpaces ) do
        for _, rs in pairs( category ) do
            if not ( rs.cursor.keyLeft or rs.cursor.keyRight ) then continue end

            if key == 107 then
                rs.cursor.keyLeft = false
                rs.cursor.clickElement = nil
            elseif key == 108 then
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
            rs:callEvent( "cursormoved", rs.cursor.position.x, rs.cursor.position.y )
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
        rs:callEvent( "removed" )
    end
end )


return wgui
