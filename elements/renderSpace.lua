--@name wgui/e/renderSpace


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpace", BaseElement )
Element.static.elementName = "renderSpace"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.__data.rs = true
    self.__data.hud = false

    self.__data.hoverElement = nil

    -- cursor
    self.__cursor = {}
    self.__cursor.enabled = false
    self.__cursor.position = { x = 0, y = 0 }

    -- events
    self.__events.cursorMoved = function( x, y ) end
    self.__events.cursorPressed = function( key ) end
    self.__events.cursorReleased = function( key ) end
end


-- Защита элемента от взаимодействий
-- local function overwriteDeclaredMethods()
--     local whitelist = {
--         [ "initialize" ] = true,
--         [ "render" ] = true,
--     }

--     for methodName, methodFunciton in pairs( BaseElement.__declaredMethods ) do
--         if string.left( methodName, 2 ) == "__" then continue end
--         if whitelist[ methodName ] then continue end
--         Element[ methodName ] = function() throw( "You cannot interact with 'renderSpace' element" ) end
--     end
-- end

-- overwriteDeclaredMethods()


-- Системная функция вызываемая для перерасчета элемента
Element.__recalculate = function( self )
    wgui.__renderSpace.hud.__data.sizeGlobal = { w = wgui.__renderSpace.hud.__data.sizeLocal.w, h = wgui.__renderSpace.hud.__data.sizeLocal.h } 
    wgui.__renderSpace.hud.__data.overflowBox = { left = 0, top = 0, right = wgui.__renderSpace.hud.__data.sizeLocal.w, bottom = wgui.__renderSpace.hud.__data.sizeLocal.h }
    wgui.__renderSpace.hud.__data.hitbox = { left = 0, top = 0, right = wgui.__renderSpace.hud.__data.sizeLocal.w, bottom = wgui.__renderSpace.hud.__data.sizeLocal.h }

    self:__recalculation()
end


-- cursor funcitons
Element.setCursorEnabled = function( self, enabled )
    self:__validate()

    self.__cursor.enabled = enabled

    if self.__data.hud then
        input.enableCursor( enabled )

        -- тут какая та хуйня наддо продумать нормально

        hook.add( "InputPressed", "wgui:hook:InputPressed", function( key )
            if not self.__cursor.enabled then return end
            if not self.__data.hoverElement then return end

            if key == 107 then
                self.__data.hoverElement.__events.click( self.__data.hoverElement )
            end
            
            -- print( key )
            -- 107 108 109 -- m1 m2 m3
        end )

        hook.add( "MouseWheeled", "wgui:hook:MouseWheeled", function( delta )
            -- print( delta )
            -- 1 vverh -- -1 vniz ) 
        end )
    end
end


-- cursor pos
Element.getCursorPos = function( self )
    self:__validate()
    
    return self.__cursor.position.x, self.__cursor.position.y
end


-- process
local cursorProcessDone = false
local function cursorProcess( rs, self, x, y )
    for _, child in pairs( table.reverse( self.__data.children ) ) do
        if cursorProcessDone then break end
        cursorProcess( rs, child, x, y )
    end
    
    if cursorProcessDone then return end
    if x >= self.__data.hitbox.left and x <= self.__data.hitbox.right and y >= self.__data.hitbox.top and y <= self.__data.hitbox.bottom then
        cursorProcessDone = true

        if rs.__data.hoverElement ~= self then
            if rs.__data.hoverElement ~= nil then
                rs.__data.hoverElement.__data.hover = false
                rs.__data.hoverElement.__events.hoverOff( rs.__data.hoverElement )
            end

            if self == rs then
                rs.__data.hoverElement = nil
            else
                rs.__data.hoverElement = self
                rs.__data.hoverElement.__data.hover = true
                rs.__data.hoverElement.__events.hoverOn( rs.__data.hoverElement )
            end
        end
    end
end

Element.process = function( self )
    if self.__cursor.enabled then
        if self.__data.hud then
            local x, y = input.getCursorPos()

            if x ~= self.__cursor.position.x or y ~= self.__cursor.position.y then
                self.__cursor.position.x, self.__cursor.position.y = x, y
                self.__events.cursorMoved( x, y )
            end
        else
            -- starfall screen
        end

        cursorProcessDone = false
        cursorProcess( self, self, self.__cursor.position.x, self.__cursor.position.y )
    end

    self:render()

    -- debug
    wgui.__renderSpace.hud:debugrender()
    render.drawCircle( self.__cursor.position.x, self.__cursor.position.y, 4 )
    render.drawSimpleText( self.__cursor.position.x + 6, self.__cursor.position.y, self.__data.hoverElement and self.__data.hoverElement.__uid or "", TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER )
end


-- Возвращаем класс элемента
return Element
