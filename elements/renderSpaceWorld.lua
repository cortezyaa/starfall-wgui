--@name wgui/e/renderSpaceWorld
--@author cortez


-- Создание класса элемента
local BaseElement = require( "./baseElement.lua" ) --@include ./baseElement.lua
local Element = class( "wgui/e/renderSpaceWorld", BaseElement )
Element.static.elementName = "renderSpaceWorld"

-- Функция вызывающая ошибку при попытке взаимодействия с элементом
Element.static.interactionFailure = function( self )
    error( "You cannot interact with 'renderSpaceWorld' element" )
    return nil
end


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    -- self.cursor2d = { x = nil, y = nil }
    
    -- должна быть матрица, к которой будет всё привязано
end

-- Перезапись методов суперкласса
local function overwriteMethods()
    local whitelist = {
        [ "initialize" ] = true,
        [ "__tostring" ] = true,
    }

    for methodName, methodFunction in pairs( BaseElement.__declaredMethods ) do
        if whitelist[ methodName ] then continue end
        Element[ methodName ] = Element.static.interactionFailure
    end
end

overwriteMethods()

-- Позиция
Element.setPosition = function( self, position )
    -- устанавливает позицию элемента в мире
end


-- Возвращаем класс элемента
return Element
