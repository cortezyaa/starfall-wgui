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

wgui.__data.cursor = {}
wgui.__data.cursor.click = false
wgui.__data.cursor.clickTime = 0
wgui.__data.cursor.space = 0


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
local function registerIncludedElements()
    local custom = {
        [ "baseElement" ] = function( elementClass ) end,
        [ "renderSpace" ] = function( elementClass )
            local scrw, scrh = render.getGameResolution()
            
            wgui.__data.rsHud = elementClass:new()
            wgui.__data.rsHud.__data.sizeLocal = { w = scrw, h = scrh }
            wgui.__data.rsHud.__data.overflowSpace = { left = 0, top = 0, right = scrw, bottom = scrh }

            wgui.__data.rsScreen = elementClass:new()
            wgui.__data.rsScreen.__data.sizeLocal = { w = 1024, h = 1024 }
            wgui.__data.rsScreen.__data.overflowSpace = { left = 0, top = 0, right = 1024, bottom = 1024 }
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


-- Функция выполняющая перерасчет элементов ( самая проклятая функция )
local function elementRecalculation( self )
    if self.__shouldRecalculate then
        self.__shouldRecalculate = false

        if self.__data.dockType == DOCK.NODOCK then
            self.__data.positionGlobal.x = self.__data.positionLocal.x + ( self.__data.parent and self.__data.parent.__data.positionGlobal.x or 0 )
            self.__data.positionGlobal.y = self.__data.positionLocal.y + ( self.__data.parent and self.__data.parent.__data.positionGlobal.y or 0 )
            self.__data.sizeGlobal.w = self.__data.sizeLocal.w
            self.__data.sizeGlobal.h = self.__data.sizeLocal.h
        end

        if self.__data.parent or self.__data.renderSpace then
            self.__data.overflowSpace.left = self.__data.parent and self.__data.parent.__data.overflowSpace.left or self.__data.renderSpace.__data.overflowSpace.left
            self.__data.overflowSpace.top = self.__data.parent and self.__data.parent.__data.overflowSpace.top or self.__data.renderSpace.__data.overflowSpace.top
            self.__data.overflowSpace.right = self.__data.parent and self.__data.parent.__data.overflowSpace.right or self.__data.renderSpace.__data.overflowSpace.right
            self.__data.overflowSpace.bottom = self.__data.parent and self.__data.parent.__data.overflowSpace.bottom or self.__data.renderSpace.__data.overflowSpace.bottom
        end

        if self.__data.parent and self.__data.parent.__data.overflow == OVERFLOW.HIDDEN then
            local px = self.__data.parent.__data.positionGlobal.x
            local py = self.__data.parent.__data.positionGlobal.y
            local pw = self.__data.parent.__data.sizeGlobal.w
            local ph = self.__data.parent.__data.sizeGlobal.h

            self.__data.overflowSpace.left = math.max( px, self.__data.overflowSpace.left )
            self.__data.overflowSpace.top = math.max( py, self.__data.overflowSpace.top )
            self.__data.overflowSpace.right = math.min( px + pw, self.__data.overflowSpace.right )
            self.__data.overflowSpace.bottom = math.min( py + ph, self.__data.overflowSpace.bottom )
        end

        local x = self.__data.positionGlobal.x
        local y = self.__data.positionGlobal.y
        local w = self.__data.sizeGlobal.w
        local h = self.__data.sizeGlobal.h

        self.__data.shouldDraw = 
            ( x > self.__data.overflowSpace.left and x < self.__data.overflowSpace.right and y > self.__data.overflowSpace.top and y < self.__data.overflowSpace.bottom ) or
            ( x + w > self.__data.overflowSpace.left and x + w < self.__data.overflowSpace.right and y > self.__data.overflowSpace.top and y < self.__data.overflowSpace.bottom ) or
            ( x > self.__data.overflowSpace.left and x < self.__data.overflowSpace.right and y + h > self.__data.overflowSpace.top and y + h < self.__data.overflowSpace.bottom ) or
            ( x + w > self.__data.overflowSpace.left and x + w < self.__data.overflowSpace.right and y + h > self.__data.overflowSpace.top and y + h < self.__data.overflowSpace.bottom )
        
        self.__data.shouldDrawWithStencil = not ( x > self.__data.overflowSpace.left and x + w < self.__data.overflowSpace.right and y > self.__data.overflowSpace.top and y + h < self.__data.overflowSpace.bottom )
        
        self.__data.hitbox.left = math.clamp( math.max( x, self.__data.overflowSpace.left ), self.__data.overflowSpace.left, self.__data.overflowSpace.right )
        self.__data.hitbox.top = math.clamp( math.max( y, self.__data.overflowSpace.top ), self.__data.overflowSpace.top, self.__data.overflowSpace.bottom )
        self.__data.hitbox.right = math.clamp( math.min( x + w, self.__data.overflowSpace.right ), self.__data.overflowSpace.left, self.__data.overflowSpace.right )
        self.__data.hitbox.bottom = math.clamp( math.min( y + h, self.__data.overflowSpace.bottom ), self.__data.overflowSpace.top, self.__data.overflowSpace.bottom )

        local fill = {}
        local space = {
            left = 0,
            top = 0,
            right = self.__data.sizeGlobal.w,
            bottom = self.__data.sizeGlobal.h
        }

        space.left = space.left + self.__data.dockPaddingLeft
        space.top = space.top + self.__data.dockPaddingTop
        space.right = space.right - self.__data.dockPaddingRight
        space.bottom = space.bottom - self.__data.dockPaddingBottom

        for _, child in pairs( self.__data.children ) do
            local dockType = child.__data.dockType

            if dockType == DOCK.NODOCK then
                -- ~skip
            elseif dockType == DOCK.FILL then
                table.insert( fill, child )
                continue
            elseif dockType == DOCK.LEFT then
                child.__data.positionGlobal.x = x + space.left + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = y + space.top + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = child.__data.sizeLocal.w
                child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMarginTop - child.__data.dockMarginBottom
                space.left = space.left + child.__data.sizeLocal.w + child.__data.dockMarginLeft + child.__data.dockMarginRight
            elseif dockType == DOCK.TOP then
                child.__data.positionGlobal.x = x + space.left + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = y + space.top + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMarginLeft - child.__data.dockMarginRight
                child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                space.top = space.top + child.__data.sizeLocal.h + child.__data.dockMarginTop + child.__data.dockMarginBottom
            elseif dockType == DOCK.RIGHT then
                child.__data.positionGlobal.x = x + space.right - child.__data.sizeLocal.w - child.__data.dockMarginRight
                child.__data.positionGlobal.y = y + space.top + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = child.__data.sizeLocal.w
                child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMarginTop - child.__data.dockMarginBottom
                space.right = space.right - child.__data.sizeLocal.w - child.__data.dockMarginLeft - child.__data.dockMarginRight
            elseif dockType == DOCK.BOTTOM then
                child.__data.positionGlobal.x = x + space.left + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = y + space.bottom - child.__data.sizeLocal.h - child.__data.dockMarginBottom
                child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMarginLeft - child.__data.dockMarginRight
                child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                space.bottom = space.bottom - child.__data.sizeLocal.h - child.__data.dockMarginTop - child.__data.dockMarginBottom
            end
        end

        for _, child in pairs( fill ) do
            child.__data.positionGlobal.x = x + space.left + child.__data.dockMarginLeft
            child.__data.positionGlobal.y = y + space.top + child.__data.dockMarginRight
            child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMarginLeft - child.__data.dockMarginRight
            child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMarginTop - child.__data.dockMarginBottom
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

    if not focusScreen and wgui.__data.rsScreen.__data.active and self.__data.shouldDraw then
        local cx = wgui.__data.rsScreen.__data.cursor.x
        local cy = wgui.__data.rsScreen.__data.cursor.y

        if cx >= self.__data.hitbox.left and cx <= self.__data.hitbox.right and cy >= self.__data.hitbox.top and cy <= self.__data.hitbox.bottom then
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

    wgui.__data.rsScreen.__data.active = crsx ~= nil and crsy ~= nil
    wgui.__data.rsScreen.__data.cursor.x = crsx ~= nil and 1024 / scrw * crsx or nil
    wgui.__data.rsScreen.__data.cursor.y = crsy ~= nil and 1024 / scrh * crsy or nil

    render.setRenderTargetTexture( wgui.__data.rsScreenRT )
    render.setRGBA( 255, 255, 255, 255 )
    render.setFilterMag( TEXFILTER.POINT )
    render.drawTexturedRect( 0, 0, scrw, scrh )
end )


-- Худ
hook.add( "drawhud", "wgui:hook:drawhud", function()
    local crsx, crsy = input.getCursorPos()

    elementRecalculation( wgui.__data.rsHud )
    
    wgui.__data.rsHud.__data.active = input.getCursorVisible()
    wgui.__data.rsHud.__data.cursor.x = wgui.__data.rsHud.__data.active and crsx or nil
    wgui.__data.rsHud.__data.cursor.y = wgui.__data.rsHud.__data.active and crsy or nil
    
    for _, child in pairs( table.reverse( wgui.__data.rsHud.__data.children ) ) do
        -- elementLogicHud( child )
    end

    wgui.__data.rsHud:render()
end )


-- Логика курсора
hook.add( "keypress", "wgui:hook:keypress", function( ply, key )
    if not isFirstTimePredicted() then return end
    if ply ~= player() then return end

    local keyUse = key == IN_KEY.USE
    local keyAttack = key == IN_KEY.ATTACK
    local keyAttack2 = key == IN_KEY.ATTACK2

    if wgui.__data.rsHud.__data.active and keyAttack then
        -- hud click logic
    elseif wgui.__data.rsScreen.__data.active and ( keyUse or keyAttack ) then
        local clickTimeOld = wgui.__data.cursor.clickTime

        wgui.__data.cursor.space = RENDERSPACE.SCREEN
        wgui.__data.cursor.click = true
        wgui.__data.cursor.clickTime = timer.systime()

        local double = wgui.__data.cursor.clickTime < clickTimeOld + 0.25

        -- mousedown
        -- click
    end
end )

hook.add( "keyrelease", "wgui:hook:keyrelease", function( ply, key )
    if not isFirstTimePredicted() then return end
    if ply ~= player() then return end

    local keyUse = key == IN_KEY.USE
    local keyAttack = key == IN_KEY.ATTACK
    local keyAttack2 = key == IN_KEY.ATTACK2

    if wgui.__data.rsHud.__data.active and keyAttack then
        -- hud click logic
    elseif wgui.__data.rsScreen.__data.active and ( keyUse or keyAttack ) then
        wgui.__data.cursor.space = 0
        wgui.__data.cursor.click = false

        -- mouseup
    end
end )


return wgui
