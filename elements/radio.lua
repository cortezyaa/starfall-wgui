--@name wgui/e/radio


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/radio", BaseElement )
Element.static.elementName = "radio"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.colors.main.r = self.data.palette.button.r
    self.data.colors.main.g = self.data.palette.button.g
    self.data.colors.main.b = self.data.palette.button.b
    self.data.colors.main.a = self.data.palette.button.a

    self.data.colors.check = { r = 255, g = 255, b = 255, a = 255 }

    self.data.linkuid = ""

    -- Ивенты
    self.events.system.click = function( self )
        self:setValue( true )

        if self.data.linkuid ~= "" and wgui.links[ self.data.linkuid ] then
            for _, el in pairs( wgui.links[ self.data.linkuid ] ) do
                if el == self then continue end
                el:setValue( false )
            end
        end
    end

    self.events.system.removed = function( self )
        if self.data.linkuid == "" then return end
        table.removeByValue( wgui.links[ self.data.linkuid ], self )
    end
end


-- Объединение элементов в одну группу
Element.link = function( self, uid )
    self:sysValidate()
    checkType( uid, "string" )

    if self.data.linkuid ~= uid and self.data.linkuid ~= "" then
        table.removeByValue( wgui.links[ self.data.linkuid ], self )
    end

    self.data.linkuid = uid

    if uid == "" then return end

    if not wgui.links[ self.data.linkuid ] then
        wgui.links[ self.data.linkuid ] = {}
    end
    
    if not table.hasValue( wgui.links[ self.data.linkuid ], self ) then
        table.insert( wgui.links[ self.data.linkuid ], self )
    end
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    if self.data.value then
        self.data.colors.check.r = math.lerp( self.data.transition, self.data.palette.button_selected.r, self.data.palette.button_selected_hover.r )
        self.data.colors.check.g = math.lerp( self.data.transition, self.data.palette.button_selected.g, self.data.palette.button_selected_hover.g )
        self.data.colors.check.b = math.lerp( self.data.transition, self.data.palette.button_selected.b, self.data.palette.button_selected_hover.b )
        self.data.colors.check.a = math.lerp( self.data.transition, self.data.palette.button_selected.a, self.data.palette.button_selected_hover.a )
    else
        self.data.colors.check.r = math.lerp( self.data.transition, self.data.palette.fill.r, self.data.palette.button_hover.r )
        self.data.colors.check.g = math.lerp( self.data.transition, self.data.palette.fill.g, self.data.palette.button_hover.g )
        self.data.colors.check.b = math.lerp( self.data.transition, self.data.palette.fill.b, self.data.palette.button_hover.b )
        self.data.colors.check.a = math.lerp( self.data.transition, self.data.palette.fill.a, self.data.palette.button_hover.a )
    end
end


-- Функция отрисовки элемента
Element.paint = function( self )
    render.setRGBA( self.data.colors.main.r, self.data.colors.main.g, self.data.colors.main.b, self.data.colors.main.a )
    render.drawRect( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

    render.setRGBA( self.data.colors.check.r, self.data.colors.check.g, self.data.colors.check.b, self.data.colors.check.a )
    render.drawRect( self.data.positionGlobal.x + self.data.sizeGlobal.w / 4, self.data.positionGlobal.y + self.data.sizeGlobal.h / 4, self.data.sizeGlobal.w / 2, self.data.sizeGlobal.h / 2 )
end


-- Возвращаем класс элемента
return Element
