--@name wgui/e/renderSpaceHUD


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpaceHUD", BaseElement )
Element.static.elementName = "renderSpaceHUD"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.isRenderSpace = true
    self.data.type = RENDERSPACE.HUD
    
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


-- Функция включения/отключения курсора
Element.setCursorEnabled = function( self, enabled )
    self:sysValidate()

    self.cursor.enabled = enabled
    input.enableCursor( enabled )
end


-- Функция получения позиции курсора
Element.getCursorPos = function( self )
    self:sysValidate()
    return self.cursor.position.x, self.cursor.position.y
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
    if self.cursor.enabled then
        local x, y = input.getCursorPos()

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

    self:render()

    if wgui.debug then self:debugrender() end
end


-- Возвращаем класс элемента
return Element
