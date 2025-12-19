--@name wgui/e/renderSpaceWorld


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceWorld", BaseElement )
Element.static.elementName = "renderSpaceWorld"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.isRenderSpace = true
    self.data.type = RENDERSPACE.WORLD

    self.data.worldPosition = Vector( 0, 0, 0 )
    self.data.worldAngle = Angle( 0, 0, 0 )
    self.data.scale = 1

    self.data.matrix = Matrix()
    
    self.data.hoverElement = nil
    self.data.recalculation = {}

    -- Курсор
    self.cursor = {}
    self.cursor.enabled = false
    self.cursor.position = { x = 0, y = 0 }

    self.cursor.clickTime = 0
    self.cursor.clickElement = nil

    self.cursor.dblclickTime = 0
    self.cursor.dblclickElement = nil

    self.cursor.keyLeft = false
    self.cursor.keyRight = false
end


-- Системная функция вызываемая для перерасчета элемента
Element.sysRecalculate = function( self )
    self.data.sizeGlobal.w = self.data.sizeLocal.w
    self.data.sizeGlobal.h = self.data.sizeLocal.h

    self.data.overflowBox.left = 0
    self.data.overflowBox.top = 0
    self.data.overflowBox.right = self.data.sizeLocal.w
    self.data.overflowBox.bottom = self.data.sizeLocal.h

    self.data.hitbox.left = 0
    self.data.hitbox.top = 0
    self.data.hitbox.right = self.data.sizeLocal.w
    self.data.hitbox.bottom = self.data.sizeLocal.h

    self:sysRecalculation()
end


-- Функция получения позиции курсора
Element.getCursorPos = function( self )
    self:sysValidate()
    return self.cursor.position.x, self.cursor.position.y
end


-- Функции связанные с позиционированием элемента в пространстве
-- Установка позиции
Element.setWPos = function( self, pos )
    self:sysValidate()
    checkType( pos, "Vector" )

    self.data.worldPosition = pos
    self.data.matrix:setTranslation( self.data.worldPosition )
end

-- Получение позиции
Element.getWPos = function( self )
    self:sysValidate()
    return self.data.worldPosition
end


-- Функции связанные с управлением углом элемента
-- Установка угла
Element.setWAng = function( self, ang )
    self:sysValidate()
    checkType( ang, "Angle" )

    self.data.worldAngle = ang
    self.data.matrix:setAngles( self.data.worldAngle )
end

-- Получение угла
Element.getWAng = function( self )
    self:sysValidate()
    return self.data.worldAngle
end


-- Функции связанные с управлением масштабом элемента
-- Установка масштаба
Element.setScale = function( self, scale )
    self:sysValidate()
    checkType( scale, "number" )

    self.data.scale = scale
    self.data.matrix:setScale( Vector( self.data.scale ) )
end

-- Получение масштаба
Element.getScale = function( self )
    self:sysValidate()
    return self.data.scale
end


-- Функция для добавления элемента в список перерасчета
Element.pushRecalculation = function( self, recalc )
    self:sysValidate()

    if table.hasValue( self.data.recalculation, recalc ) then
        table.removeByValue( self.data.recalculation, recalc )
    end

    local should = true

    for _, el in pairs( self.data.recalculation ) do
        if table.hasValue( recalc.data.parentsTree, el ) then
            should = false
            break
        end
    end

    if should then
        table.insert( self.data.recalculation, recalc )
    end
end


-- Процесс
local cursorProcessDone = false
local function cursorProcess( rs, self, x, y )
    if self.data.noDraw then return end

    for _, child in pairs( table.reverse( self.data.children ) ) do
        if cursorProcessDone then break end
        cursorProcess( rs, child, x, y )
    end
    
    if cursorProcessDone then return end
    if self.data.hitIgnore then return end

    cursorProcessDone = self:hitscan( x, y )

    if cursorProcessDone then
        if rs.data.hoverElement ~= self then
            if rs.data.hoverElement ~= nil then
                local oldhover = rs.data.hoverElement
                rs.data.hoverElement.data.hover = false
                rs.data.hoverElement = nil
                oldhover:callEvent( "hoveroff" )
            end

            if self ~= rs then
                rs.data.hoverElement = self
                rs.data.hoverElement.data.hover = true
                rs.data.hoverElement:callEvent( "hoveron" )
            end
        end
    end
end

Element.process = function( self )
    local plane = -( eyePos() - self.data.worldPosition ):dot( -self.data.worldAngle:getUp() ) / eyeVector():dot( -self.data.worldAngle:getUp() )
    local onPlane = eyePos() + eyeVector() * plane
    local x = -( self.data.worldPosition - onPlane ):dot( self.data.worldAngle:getForward() ) / self.data.scale
    local y = ( self.data.worldPosition - onPlane ):dot( self.data.worldAngle:getRight() ) / self.data.scale

    self.cursor.enabled = not ( x < 0 or x > self.data.sizeLocal.w or y < 0 or y > self.data.sizeLocal.h )

    if self.cursor.enabled then
        if x ~= self.cursor.position.x or y ~= self.cursor.position.y then
            self.cursor.position.x, self.cursor.position.y = x, y
            self:callEvent( "cursormoved", x, y )
        end

        cursorProcessDone = false
        cursorProcess( self, self, self.cursor.position.x, self.cursor.position.y )

        local hover = self.data.hoverElement

        if hover then
            hover:callEvent( "hover" )
        end

        local click = self.cursor.clickElement

        if ( timer.curtime() - self.cursor.clickTime >= 0.25 ) and self.cursor.keyLeft and click then
            click:callEvent( "clickhover" )
        end
    end

    for _, el in pairs( self.data.recalculation ) do
        el:sysRecalculation()
    end
    self.data.recalculation = {}
    
    render.setFilterMag( TEXFILTER.POINT )
    render.setFilterMin( TEXFILTER.POINT )

    render.pushMatrix( self.data.matrix )

    self:render()
    if wgui.debug then self:debugrender() end

    render.popMatrix()
end


-- Возвращаем класс элемента
return Element
