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

    self.data.loaded = false
    self.data.materialKeep = false
    self.data.material = material.create( "UnlitGeneric", true )

    self.events.system.removed = function( self )
        if self.data.materialKeep then return end
        self.data.material:destroy()
    end
end


-- Установка материала
Element.setMaterial = function( self, mat )
    self:sysValidate()
    checkType( mat, { "material" } )

    -- but why?
    if mat == self.data.material then return end

    if not self.data.materialKeep then
        self.data.material:destroy()
    end

    self.data.materialKeep = true
    self.data.material = self.data.material

    local texture = self.data.material:getTexture( "$basetexture" )

    if texture == nil or texture == "" then
        self.data.loaded = false
    end
end

-- Получение материала
Element.getMaterial = function( self )
    self:sysValidate()
    return self.data.material
end


-- Установка текстуры
Element.setTexture = function( self, texture )
    self:sysValidate()
    checkType( texture, { "nil", "string" } )

    local oldTexture = self.data.material:getTexture( "$basetexture" )

    if oldTexture == texture then return end

    self.data.loaded = false

    if texture == nil or texture == "" then
        self.data.material:setTexture( "$basetexture", "" )
        return
    end

    local prefix = string.match( texture, "^(%w-):" )
	if prefix == "http" or prefix == "https" or prefix == "data" then
        self.data.material:setTextureURL( "$basetexture", texture, 
            function( material, url, width, height, layout )
                if not layout then return end
                layout( 0, 0, 1024, 1024 )
            end, 
            function( material, url )
                self.data.loaded = true
            end
        )
    else
        self.data.material:setTexture( "$basetexture", texture )
        self.data.loaded = true
    end
end

-- Получение текстуры
Element.getTexture = function( self )
    self:sysValidate()
    return self.data.material:getTexture( "$basetexture" )
end

-- Загружена текстура или нет
Element.isTextureLoaded = function( self )
    self:sysValidate()
    return self.data.loaded
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
