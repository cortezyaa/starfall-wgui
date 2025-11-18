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
            wgui.renderSpace.hud.rstype = RENDERSPACE.HUD
            wgui.renderSpace.hud:sysRecalculate()

            -- screen
            wgui.renderSpace.screen = elementClass:new()
            wgui.renderSpace.screen.data.sizeLocal = { w = 1024, h = 1024 }
            wgui.renderSpace.screen.rstype = RENDERSPACE.SCREEN
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
    for key, rs in pairs( wgui.renderSpace ) do
        if not rs.data.value then continue end -- Проверка активен ли renderSpace

        if key == 107 then
            
        elseif key == 108 then
            
        end
    end

    -- if not self.cursor.enabled then return end
    -- if not self.data.hoverElement then return end

    -- local hover = self.data.hoverElement

    -- if key == 107 then
    --     if ( self.cursor.element == self.data.hoverElement ) and ( ( timer.curtime() - self.cursor.time ) < 0.2 ) then
    --         hover.events.dblclick( hover )
    --         self.cursor.time = 0
    --         self.cursor.element = nil
    --     else
    --         hover.events.click( hover )
    --         self.cursor.time = timer.curtime()
    --         self.cursor.element = hover
    --     end

    --     self.cursor.keydown = true
    -- elseif key == 108 then
    --     hover.events.rightclick( hover )
    -- end
end )

hook.add( "InputReleased", "wgui:hook:InputReleased", function( key )
    for key, rs in pairs( wgui.renderSpace ) do
        if not rs.value then continue end

        -- a
    end
end )

hook.add( "onScreenSizeChanged", "wgui:hook:onScreenSizeChanged", function( w, h )
    wgui.renderSpace.hud.data.sizeLocal = { w = w, h = h }
    wgui.renderSpace.hud:sysRecalculate()
end )

hook.add( "drawhud", "wgui:hook:drawhud", function()
    wgui.renderSpace.hud:process()
end )



return wgui
