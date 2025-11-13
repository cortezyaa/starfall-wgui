--@name wgui/e/renderSpace


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpace", BaseElement )
Element.static.elementName = "renderSpace"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.rs = true
    self.data.hud = false

    self.data.hoverElement = nil

    -- cursor
    self.cursor = {}
    self.cursor.enabled = false
    self.cursor.position = { x = 0, y = 0 }

    -- events
end


-- Защита элемента от взаимодействий
-- local function overwriteDeclaredMethods()
--     local whitelist = {
--         [ "initialize" ] = true,
--         [ "render" ] = true,
--     }

--     for methodName, methodFunciton in pairs( BaseElement.declaredMethods ) do
--         if string.left( methodName, 2 ) == "" then continue end
--         if whitelist[ methodName ] then continue end
--         Element[ methodName ] = function() throw( "You cannot interact with 'renderSpace' element" ) end
--     end
-- end

-- overwriteDeclaredMethods()


-- Системная функция вызываемая для перерасчета элемента
Element.sysRecalculate = function( self )
    wgui.renderSpace.hud.data.sizeGlobal = { w = wgui.renderSpace.hud.data.sizeLocal.w, h = wgui.renderSpace.hud.data.sizeLocal.h } 
    wgui.renderSpace.hud.data.overflowBox = { left = 0, top = 0, right = wgui.renderSpace.hud.data.sizeLocal.w, bottom = wgui.renderSpace.hud.data.sizeLocal.h }
    wgui.renderSpace.hud.data.hitbox = { left = 0, top = 0, right = wgui.renderSpace.hud.data.sizeLocal.w, bottom = wgui.renderSpace.hud.data.sizeLocal.h }

    self:sysRecalculation()
end


-- cursor funcitons
Element.setCursorEnabled = function( self, enabled )
    self:sysValidate()

    self.cursor.enabled = enabled

    if self.data.hud then
        input.enableCursor( enabled )

        if enabled then
            -- тут какая та хуйня наддо продумать нормально

            hook.add( "InputPressed", "wgui:hook:InputPressed", function( key )
                if not self.cursor.enabled then return end
                if not self.data.hoverElement then return end

                if key == 107 then
                    -- ивент сюда
                elseif key == 108 then
                    -- ивент сюда
                end
            end )

            hook.add( "InputReleased", "wgui:hook:InputReleased", function( key )
                if not self.cursor.enabled then return end
                if not self.data.hoverElement then return end
                
                if key == 107 then
                    -- ивент сюда
                elseif key == 108 then
                    -- ивент сюда
                end
            end )

            hook.add( "MouseWheeled", "wgui:hook:MouseWheeled", function( delta )
                if not self.cursor.enabled then return end
                if not self.data.hoverElement then return end
                
                -- ивент сюда
            end )
        else
            hook.remove( "InputPressed", "wgui:hook:InputPressed" )
            hook.remove( "InputReleased", "wgui:hook:InputReleased" )
            hook.remove( "MouseWheeled", "wgui:hook:MouseWheeled" )
        end
    end
end


-- cursor pos
Element.getCursorPos = function( self )
    self:sysValidate()
    
    return self.cursor.position.x, self.cursor.position.y
end


-- process
local cursorProcessDone = false
local function cursorProcess( rs, self, x, y )
    for _, child in pairs( table.reverse( self.data.children ) ) do
        if cursorProcessDone then break end
        cursorProcess( rs, child, x, y )
    end
    
    if cursorProcessDone then return end
    if x >= self.data.hitbox.left and x <= self.data.hitbox.right and y >= self.data.hitbox.top and y <= self.data.hitbox.bottom then
        cursorProcessDone = true

        if rs.data.hoverElement ~= self then
            if rs.data.hoverElement ~= nil then
                rs.data.hoverElement.data.hover = false
                -- ивент сюда
                rs.data.hoverElement = nil
            end

            if self ~= rs then
                rs.data.hoverElement = self
                rs.data.hoverElement.data.hover = true
                -- ивент сюда
            end
        end
    end
end

Element.process = function( self )
    if self.cursor.enabled then
        if self.data.hud then
            local x, y = input.getCursorPos()

            if x ~= self.cursor.position.x or y ~= self.cursor.position.y then
                self.cursor.position.x, self.cursor.position.y = x, y
                -- ивент сюда
            end
        else
            -- starfall screen
        end

        cursorProcessDone = false
        cursorProcess( self, self, self.cursor.position.x, self.cursor.position.y )
    end

    self:render()

    -- debug
    wgui.renderSpace.hud:debugrender()
    render.drawCircle( self.cursor.position.x, self.cursor.position.y, 4 )
    render.drawSimpleText( self.cursor.position.x + 6, self.cursor.position.y, self.data.hoverElement and self.data.hoverElement.uid or "", TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER )
end


-- Возвращаем класс элемента
return Element
