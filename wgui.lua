--@name wgui
--@author cortez


--[[
    todo list:


    renderSpaceWorld
        придумать реализацию

        система должна:
            поддерживать несколько плоскостей для рендера
            правильно рассчитывать положения курсора на элементе
            выбирать приоритетную панель ( т.е. если несколько плоскостей находятся рядом )
                скорее всего надо будет брать глобал позицию курсора на каждой плоскости
                и выбирать ту плоскость, где курсор ближе к пользователю

        по возможности:
            добавить возможность рендера на изогнутых поверхностях
            выбор хука где рендерить

    
    hook'и
        -- ?
    
        
    позже: render, drag & drop, анимации
]]


-- Инклюдинг утилит
requiredir( "./utils/" ) --@includedir ../utils/


-- Создание основной таблицы
wgui = {}

-- Создание таблицы для данных
wgui.__data = {}

wgui.__data.registred = {}

wgui.__data.rsHud = nil

wgui.__data.rsScreen = nil
wgui.__data.rsScreenRT = "wguirsscreenrt"
if render.renderTargetExists( wgui.__data.rsScreenRT ) then render.destroyRenderTarget( wgui.__data.rsScreenRT ) end
render.createRenderTarget( wgui.__data.rsScreenRT )
-- wgui.__data.rsScreenMat = material.create( "gmodscreenspace" )
-- wgui.__data.rsScreenMat = material.create( "UnlitGeneric" )
-- wgui.__data.rsScreenMat:setTextureRenderTarget( "$basetexture", wgui.__data.rsScreenRT )
-- wgui.__data.rsScreenMat:setInt("$flags", 0)

wgui.__data.rsWorld = {}


-- Функция проверяет зарегестрирован ли элемент с указанным именем
wgui.isRegistred = function( elementName )
    checkType( elementName, "string" )

    return not not wgui.__data.registred[ elementName ]
end


-- Функция регестрации элемента
wgui.register = function( elementName, elementClass )
    checkType( elementName, "string" )
    checkType( elementClass, "table" )

    if wgui.isRegistred( elementName ) then
        error( "Element with the specified name is already registered" )
    end

    wgui.__data.registred[ elementName ] = elementClass
end


-- Функция создания элемента
wgui.create = function( elementName, parent )
    checkType( elementName, "string" )
    local _, parentT = checkType( parent, { "wgui", "number" } )

    if not wgui.isRegistred( elementName ) then
        error( "Specified element is not registered" )
    end

    local element = wgui.__data.registred[ elementName ]:new()

    if parentT == "number" then
        checkEnum( parent, "RENDERSPACE" )

        if parent == RENDERSPACE.HUD then
            element.__data.renderSpace = wgui.__data.rsHud
            table.insert( wgui.__data.rsHud.__data.children, element )
        elseif parent == RENDERSPACE.SCREEN then
            element.__data.renderSpace = wgui.__data.rsScreen
            table.insert( wgui.__data.rsScreen.__data.children, element )
        elseif parent == RENDERSPACE.WORLD then
            -- idk now
        end
    else
        element:setParent( parent )
    end

    return element
end


-- Инклюдинг элементов и дальнейшая их регистрация
--@includedir ./elements/
local function registerIncludedElements()9
    local custom = {
        [ "baseElement" ] = function( elementClass ) end,
        [ "renderSpace" ] = function( elementClass )
            local scrw, scrh = render.getGameResolution()
            
            wgui.__data.rsHud = elementClass:new()
            wgui.__data.rsHud.__data.sizeLocal = { w = scrw, h = scrh }
            wgui.__data.rsHud.__data.overflowSpace = { x = 0, y = 0, w = scrw, h = scrh }

            wgui.__data.rsScreen = elementClass:new()
            wgui.__data.rsScreen.__data.sizeLocal = { w = 1024, h = 1024 }
            wgui.__data.rsScreen.__data.overflowSpace = { x = 0, y = 0, w = 1024, h = 1024 }
        end,
    }

    for _, elementClass in pairs( requiredir( "./elements/" ) ) do
        local elementName = elementClass.static.elementName

        if custom[ elementName ] then
            custom[ elementName ]( elementClass )
        end

        wgui.register( elementName, elementClass )
    end
end

registerIncludedElements()


-- Функция выполняющая перерасчет элементов
local function elementRecalculation( self )
    -- пока так. потом посмотрим
    
    if self.__shouldRecalculate then
        self.__shouldRecalculate = false

        if self.__data.dockType == DOCK.NODOCK then
            self.__data.positionGlobal.x = self.__data.positionLocal.x + ( self.__data.parent and self.__data.parent.__data.positionGlobal.x or 0 )
            self.__data.positionGlobal.y = self.__data.positionLocal.y + ( self.__data.parent and self.__data.parent.__data.positionGlobal.y or 0 )
            self.__data.sizeGlobal.w = self.__data.sizeLocal.w
            self.__data.sizeGlobal.h = self.__data.sizeLocal.h
        end

        if self.__data.parent or self.__data.renderSpace then
            self.__data.overflowSpace.x = self.__data.parent and self.__data.parent.__data.overflowSpace.x or self.__data.renderSpace.__data.overflowSpace.x
            self.__data.overflowSpace.y = self.__data.parent and self.__data.parent.__data.overflowSpace.y or self.__data.renderSpace.__data.overflowSpace.y
            self.__data.overflowSpace.w = self.__data.parent and self.__data.parent.__data.overflowSpace.w or self.__data.renderSpace.__data.overflowSpace.w
            self.__data.overflowSpace.h = self.__data.parent and self.__data.parent.__data.overflowSpace.h or self.__data.renderSpace.__data.overflowSpace.h
        end

        local x = self.__data.positionGlobal.x
        local y = self.__data.positionGlobal.y
        local w = self.__data.sizeGlobal.w
        local h = self.__data.sizeGlobal.h

        local ox = self.__data.overflowSpace.x
        local oy = self.__data.overflowSpace.y
        local ow = self.__data.overflowSpace.w
        local oh = self.__data.overflowSpace.h

        if self.__data.parent and ( self.__data.parent.__data.overflow == OVERFLOW.HIDDEN or self.__data.parent.__data.overflow == OVERFLOW.SCROLL ) then
            self.__data.overflowSpace.x = math.max( x, ox )
            self.__data.overflowSpace.y = math.max( y, oy )
            self.__data.overflowSpace.w = math.min( x + w, ow )
            self.__data.overflowSpace.h = math.min( y + h, oh )
        end

        self.__data.shouldDraw = x >= ox or y >= oy or x + w <= ox + ow or y + h <= oy + oh

        if table.count( self.__data.children ) == 0 then return end

        local fill = {}
        local space = {
            x = 0,
            y = 0,
            w = self.__data.sizeGlobal.w,
            h = self.__data.sizeGlobal.h
        }

        space.x = space.x + self.__data.dockPaddingLeft
        space.y = space.y + self.__data.dockPaddingTop
        space.w = space.w - self.__data.dockPaddingRight
        space.h = space.h - self.__data.dockPaddingBottom

        for _, child in pairs( self.__data.children ) do
            local dockType = child.__data.dockType

            if dockType == DOCK.NODOCK then
                -- ~skip
            elseif dockType == DOCK.FILL then
                table.insert( fill, child )
                continue
            elseif dockType == DOCK.LEFT then
                child.__data.positionGlobal.x = x + space.x + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = y + space.y + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = child.__data.sizeLocal.w
                child.__data.sizeGlobal.h = space.h - space.y - child.__data.dockMarginTop - child.__data.dockMarginBottom
                space.x = space.x + child.__data.sizeLocal.w + child.__data.dockMarginLeft + child.__data.dockMarginRight
            elseif dockType == DOCK.TOP then
                child.__data.positionGlobal.x = x + space.x + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = y + space.y + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = space.w - space.x - child.__data.dockMarginLeft - child.__data.dockMarginRight
                child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                space.y = space.y + child.__data.sizeLocal.h + child.__data.dockMarginTop + child.__data.dockMarginBottom
            elseif dockType == DOCK.RIGHT then
                child.__data.positionGlobal.x = x + space.w - child.__data.sizeLocal.w - child.__data.dockMarginRight
                child.__data.positionGlobal.y = y + space.y + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = child.__data.sizeLocal.w
                child.__data.sizeGlobal.h = space.h - space.y - child.__data.dockMarginTop - child.__data.dockMarginBottom
                space.w = space.w - child.__data.sizeLocal.w - child.__data.dockMarginLeft - child.__data.dockMarginRight
            elseif dockType == DOCK.BOTTOM then
                child.__data.positionGlobal.x = x + space.x + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = y + space.h - child.__data.sizeLocal.h - child.__data.dockMarginBottom
                child.__data.sizeGlobal.w = space.w - space.x - child.__data.dockMarginLeft - child.__data.dockMarginRight
                child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                space.h = space.h - child.__data.sizeLocal.h - child.__data.dockMarginTop - child.__data.dockMarginBottom
            end
        end

        for _, child in pairs( fill ) do
            child.__data.positionGlobal.x = x + space.x + child.__data.dockMarginLeft
            child.__data.positionGlobal.y = y + space.y + child.__data.dockMarginRight
            child.__data.sizeGlobal.w = space.w - space.x - child.__data.dockMarginLeft - child.__data.dockMarginRight
            child.__data.sizeGlobal.h = space.h - space.y - child.__data.dockMarginTop - child.__data.dockMarginBottom
        end
    end
    
    for _, child in pairs( self.__data.children ) do
        elementRecalculation( child )
    end
end


-- Экран
local focusScreen = false

local function elementLogicScreen( self )
    for _, child in pairs( table.reverse( self.__data.children ) ) do
        elementLogicScreen( child )
    end

    if not focusScreen and wgui.__data.rsScreen.__data.active then
        local cx = wgui.__data.rsScreen.__data.cursor.x
        local cy = wgui.__data.rsScreen.__data.cursor.y

        local x = self.__data.positionGlobal.x
        local y = self.__data.positionGlobal.y
        local w = self.__data.sizeGlobal.w
        local h = self.__data.sizeGlobal.h

        if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
            focusScreen = true

            if wgui.__data.rsScreen.__data.focus ~= self then
                if wgui.__data.rsScreen.__data.focus then
                    wgui.__data.rsScreen.__data.focus:eventCall( "hoverOff" )
                end

                wgui.__data.rsScreen.__data.focus = self
                wgui.__data.rsScreen.__data.focus:eventCall( "hoverOn" )
            end

            wgui.__data.rsScreen.__data.focus:eventCall( "hover" )
        end
    end
end

hook.add( "renderoffscreen", "wgui:hook:renderoffscreen", function()
    render.selectRenderTarget( wgui.__data.rsScreenRT )
    render.clear()

    focusScreen = false

    for _, child in pairs( table.reverse( wgui.__data.rsScreen.__data.children ) ) do
        elementLogicScreen( child )
    end

    if not focusScreen and wgui.__data.rsScreen.__data.focus then
        wgui.__data.rsScreen.__data.focus:eventCall( "hoverOff" )
        wgui.__data.rsScreen.__data.focus = nil
    end

    wgui.__data.rsScreen:render()

    render.selectRenderTarget()
end )

hook.add( "render", "wgui:hook:render", function()
    local scrw, scrh = render.getResolution()
    local crsx, crsy = render.cursorPos()

    elementRecalculation( wgui.__data.rsScreen )

    wgui.__data.rsScreen.__data.cursor.x = crsx ~= nil and 1024 / scrw * crsx or nil
    wgui.__data.rsScreen.__data.cursor.y = crsy ~= nil and 1024 / scrh * crsy or nil
    wgui.__data.rsScreen.__data.active = crsx ~= nil and crsy ~= nil

    render.setRenderTargetTexture( wgui.__data.rsScreenRT )
    render.setRGBA( 255, 255, 255, 255 )
    render.drawTexturedRect( 0, 0, scrw, scrh )
end )


--[[ сделаю позже
Логика курсора
hook.add( "keypress", "wgui:hook:keypress", function( ply, key )
    if not isFirstTimePredicted() then return end
    if ply ~= player() then return end
    
    --if key ~= IN_KEY.ATTACK and key ~= IN_KEY.USE then return end
end )

hook.add( "keyrelease", "wgui:hook:keyrelease", function( ply, key )
    if not isFirstTimePredicted() then return end
    if ply ~= player() then return end
end )
]]--


return wgui
