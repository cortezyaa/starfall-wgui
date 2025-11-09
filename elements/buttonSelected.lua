--@name wgui/e/buttonSelected


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/buttonSelected", BaseElement )
Element.static.elementName = "buttonSelected"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    -- events
end

-- Функция отрисовки элемента
Element.paint = function( self )
    if self.__data.value then
        render.setRGBA( 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button_selected.r, self.__style.palette.button_selected_hover.r ), 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button_selected.g, self.__style.palette.button_selected_hover.g ), 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button_selected.b, self.__style.palette.button_selected_hover.b ), 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button_selected.a, self.__style.palette.button_selected_hover.a )
        )
    else
        render.setRGBA( 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button.r, self.__style.palette.button_hover.r ), 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button.g, self.__style.palette.button_hover.g ), 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button.b, self.__style.palette.button_hover.b ), 
            math.lerp( self.__style.transitionLevel, self.__style.palette.button.a, self.__style.palette.button_hover.a )
        )
    end

    render.drawRect( self.__data.positionGlobal.x, self.__data.positionGlobal.y, self.__data.sizeGlobal.w, self.__data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
