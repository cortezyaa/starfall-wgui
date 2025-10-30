--@name wgui/e/renderSpace


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpace", BaseElement )
Element.static.elementName = "renderSpace"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.__data.rs = true

    -- cursor
    self.__cursor = {}
    self.__cursor.enabled = false
    self.__cursor.position = { x = 0, y = 0 }
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
    input.enableCursor( enabled )
end


-- Возвращаем класс элемента
return Element
