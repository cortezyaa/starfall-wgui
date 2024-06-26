--@name wgui/e/renderSpace
--@author cortez


-- Создание класса элемента
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/renderSpace", BaseElement )
Element.static.elementName = "renderSpace"

-- Функция вызывающая ошибку при попытке взаимодействия с элементом
Element.static.interactionFailure = function( self )
    error( "You cannot interact with 'renderSpace' element" )
    return nil
end


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.__data.active = false
    self.__data.cursor = { x = nil, y = nil }
    self.__data.focus = nil
end

-- Перезапись методов суперкласса
local function overwriteMethods()
    local whitelist = {
        [ "__tostring" ] = true,
        [ "initialize" ] = true,
        [ "fRecalculate" ] = true,
        [ "render" ] = true,
    }

    for methodName, methodFunction in pairs( BaseElement.__declaredMethods ) do
        if whitelist[ methodName ] then continue end
        Element[ methodName ] = Element.static.interactionFailure
    end
end

overwriteMethods()


Element.paint = function( self )
    return
end

-- Возвращаем класс элемента
return Element
