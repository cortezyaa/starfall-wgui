--@name wgui/e/image


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/image", BaseElement )
Element.static.elementName = "image"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )
    
    self.data.colors.fill = table.rgba( self.data.palette.button )
    self.data.colors.wait = table.rgba( self.data.palette.button_selected )
    self.data.colors.image = table.rgba()

    self.data.value = nil
    self.data.loaded = false
    self.data.material = material.create( "UnlitGeneric", true )

    self.events.system.removed = function( self )
        self.data.material:destroy()
    end
end


-- Функции управления значением (текстурой) элемента
-- Установка значением
Element.setValue = function( self, value )
    self:sysValidate()
    checkType( value, { "nil", "string" } )

    if value == self.data.value then return end

    local valueOld = self.data.value
    self.data.value = value

    self.data.loaded = false

    local prefix = string.match( value, "^(%w-):" )
	if prefix == "http" or prefix == "https" or prefix == "data" then
        self.data.material:setTextureURL( "$basetexture", value, 
            function( material, url, width, height, layout )
                if not layout then return end
                layout( 0, 0, 1024, 1024 )
            end, 
            function( material, url )
                self.data.loaded = true
            end
        )
    else
        self.data.material:setTexture( "$basetexture", value )
        self.data.loaded = true
    end

    self:callEvent( WGUIEVENTS.VALUECHANGED, value, valueOld )
end

-- Получение значением
Element.getValue = function( self )
    self:sysValidate()
    return self.data.value
end


-- Функция отрисовки элемента
local duration, count, size, radius = 4, 6, 8, 28
Element.paint = function( self )
    if not self.data.loaded then
        render.setRGBA( self.data.colors.fill.r, self.data.colors.fill.g, self.data.colors.fill.b, self.data.colors.fill.a )
        render.drawRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )

        for sq = 1, count do
            local progress = ( ( duration / count * sq ) + timer.realtime() ) % duration / duration
            local rotsq = math.sin( math.rad( progress * 360 + timer.realtime() * 16 ) )

            render.setRGBA( self.data.colors.wait.r, self.data.colors.wait.g, self.data.colors.wait.b, 255 + ( rotsq - 1 ) * 120 )
            render.drawRectRotated( 
                self.data.positionGlobal.x + self.data.sizeGlobal.w / 2 + math.sin( math.rad( progress * 360 ) ) * radius, 
                self.data.positionGlobal.y + self.data.sizeGlobal.h / 2 + math.cos( math.rad( progress * 360 ) ) * radius, 
                size + rotsq * 3, 
                size + rotsq * 3,
                progress * 360
            )
        end

        return
    end

    render.setRGBA( self.data.colors.image.r, self.data.colors.image.g, self.data.colors.image.b, self.data.colors.image.a )
    render.setMaterial( self.data.material )
    render.drawTexturedRectFast( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
end


-- Возвращаем класс элемента
return Element
