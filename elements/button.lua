--@name wgui/e/button


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/button", BaseElement )
Element.static.elementName = "button"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
end

-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( 
        math.lerp( self.__style.transitionLevel, self.__style.palette.button.r, self.__style.palette.button_hover.r ), 
        math.lerp( self.__style.transitionLevel, self.__style.palette.button.g, self.__style.palette.button_hover.g ), 
        math.lerp( self.__style.transitionLevel, self.__style.palette.button.b, self.__style.palette.button_hover.b ), 
        math.lerp( self.__style.transitionLevel, self.__style.palette.button.a, self.__style.palette.button_hover.a )
    )

    render.drawRect( self.__data.positionGlobal.x, self.__data.positionGlobal.y, self.__data.sizeGlobal.w, self.__data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
