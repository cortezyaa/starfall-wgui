--@name wgui/e/renderSpace


-- Создание класса элемента
local BaseElement = require( "./base.lua" ) --@include ./base.lua
local Element = class( "wgui/e/renderSpace", BaseElement )
Element.static.elementName = "renderSpace"


-- Инитиализация
Element.initialize = function( self )
    BaseElement.initialize( self, Element.static.elementName )

    self.data.rs = true
    self.data.type = RENDERSPACE.HUD -- По стандарту созданный рендер спейс на худ ( пока что )

    self.data.hoverElement = nil

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


-- Защита элемента от взаимодействий
-- local function overwriteDeclaredMethods()
--     local whitelist = {
--         [ "initialize" ] = true,
--         [ "render" ] = true,
--     }

--     for methodName, methodFunciton in pairs( BaseElement.declaredMethods ) do
--         if string.left( methodName, 2 ) == "" then continue end
--         if whitelist[ methodName ] then continue end
--         Element[ methodName ] = function() throw( "You cannot interact with 'renderSpace' element" ) end
--     end
-- end

-- overwriteDeclaredMethods()


-- Системная функция вызываемая для перерасчета элемента
Element.sysRecalculate = function( self )
    wgui.renderSpace.hud.data.sizeGlobal = { w = wgui.renderSpace.hud.data.sizeLocal.w, h = wgui.renderSpace.hud.data.sizeLocal.h } 
    wgui.renderSpace.hud.data.overflowBox = { left = 0, top = 0, right = wgui.renderSpace.hud.data.sizeLocal.w, bottom = wgui.renderSpace.hud.data.sizeLocal.h }
    wgui.renderSpace.hud.data.hitbox = { left = 0, top = 0, right = wgui.renderSpace.hud.data.sizeLocal.w, bottom = wgui.renderSpace.hud.data.sizeLocal.h }

    self:sysRecalculation()
end


-- cursor funcitons
Element.setCursorEnabled = function( self, enabled )
    self:sysValidate()

    self.cursor.enabled = enabled

    if self.data.hud and input.getCursorVisible() ~= enabled then
        input.enableCursor( enabled )
    end
end


-- cursor pos
Element.getCursorPos = function( self )
    self:sysValidate()
    
    return self.cursor.position.x, self.cursor.position.y
end


-- process
local cursorProcessDone = false
local function cursorProcess( rs, self, x, y )
    if self.data.noDraw then return end

    for _, child in pairs( table.reverse( self.data.children ) ) do
        if cursorProcessDone then break end
        cursorProcess( rs, child, x, y )
    end
    
    if cursorProcessDone then return end
    if self.data.hitIgnore then return end

    if self.hitscan then
        cursorProcessDone = self:hitscan( x, y )
    else
        cursorProcessDone = ( x >= self.data.hitbox.left and x <= self.data.hitbox.right and y >= self.data.hitbox.top and y <= self.data.hitbox.bottom )
    end

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
        local x, y = 0, 0

        if self.data.hud then
            x, y = input.getCursorPos()
        else
            x, y = render.cursorPos()
            x, y = math.round( ( x * 2 ) or 0 ), math.round( ( y * 2 ) or 0 )
        end

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

    self:render()

    -- debug
    if not wgui.debug then return end
    wgui.renderSpace.hud:debugrender()
    render.setRGBA( 255, 255, 255, 255 )
    render.drawCircle( self.cursor.position.x, self.cursor.position.y, 4 )
    render.drawSimpleText( self.cursor.position.x + 12, self.cursor.position.y, "hover: " .. ( self.data.hoverElement and self.data.hoverElement.uid or "" ), TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER )
    render.drawSimpleText( self.cursor.position.x + 12, self.cursor.position.y + 12, "click: " .. ( self.cursor.clickElement and self.cursor.clickElement.uid or "" ), TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER )
    render.drawSimpleText( self.cursor.position.x + 12, self.cursor.position.y + 24, "L=" .. tostring( self.cursor.keyLeft ) .. " / R=" .. tostring( self.cursor.keyRight ), TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER )
end


-- Возвращаем класс элемента
return Element
