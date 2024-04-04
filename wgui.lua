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
    
        
    позже: render, cursor, hover, drag & drop, callback'и, анимации
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
            wgui.__data.rsHud = elementClass:new()

            wgui.__data.rsScreen = elementClass:new()
            wgui.__data.rsScreen.__data.sizeLocal = { w = 1024, h = 1024 }
            wgui.__data.rsScreen.__data.sizeGlobal = { w = 1024, h = 1024 }
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

        if table.count( self.__data.children ) == 0 then return end

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

            -- наверн надо добавить ограничение,
            -- чтоб значения в минус не улетали
            -- надо будет затестить 

            if dockType == DOCK.NODOCK then
                -- ~skip
            elseif dockType == DOCK.FILL then
                table.insert( fill, child )
                continue
            elseif dockType == DOCK.LEFT then
                child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = child.__data.sizeLocal.w
                child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMarginTop - child.__data.dockMarginBottom
                space.left = space.left + child.__data.sizeLocal.w + child.__data.dockMarginLeft + child.__data.dockMarginRight
            elseif dockType == DOCK.TOP then
                child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMarginLeft - child.__data.dockMarginRight
                child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                space.top = space.top + child.__data.sizeLocal.h + child.__data.dockMarginTop + child.__data.dockMarginBottom
            elseif dockType == DOCK.RIGHT then
                child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.right - child.__data.sizeLocal.w - child.__data.dockMarginRight
                child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMarginTop
                child.__data.sizeGlobal.w = child.__data.sizeLocal.w
                child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMarginTop - child.__data.dockMarginBottom
                space.right = space.right - child.__data.sizeLocal.w - child.__data.dockMarginLeft - child.__data.dockMarginRight
            elseif dockType == DOCK.BOTTOM then
                child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMarginLeft
                child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.bottom - child.__data.sizeLocal.h - child.__data.dockMarginBottom
                child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMarginLeft - child.__data.dockMarginRight
                child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                space.bottom = space.bottom - child.__data.sizeLocal.h - child.__data.dockMarginTop - child.__data.dockMarginBottom
            end
        end

        for _, child in pairs( fill ) do
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMarginLeft
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMarginRight
            child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMarginLeft - child.__data.dockMarginRight
            child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMarginTop - child.__data.dockMarginBottom
        end
    end
    
    for _, child in pairs( self.__data.children ) do
        elementRecalculation( child )
    end
end


-- Рендер элементов
local function elementRender( self )
    self:render()

    for _, child in pairs( self.__data.children ) do
        elementRender( child )
    end
end

-- Экран
local focusScreen = false

local function elementLogicScreen( self )
    for _, child in pairs( table.reverse( self.__data.children ) ) do
        elementLogicScreen( child )
    end

    if not focusScreen then
        local cx = wgui.__data.rsScreen.__data.cursor.x
        local cy = wgui.__data.rsScreen.__data.cursor.y

        local x = self.__data.positionGlobal.x
        local y = self.__data.positionGlobal.y
        local w = self.__data.sizeGlobal.w
        local h = self.__data.sizeGlobal.h

        if cx ~= nil and cy ~= nil and cx >= x and cx <= x + w and cy >= y and cy <= y + h then
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

    for _, child in pairs( wgui.__data.rsScreen.__data.children ) do
        elementRender( child )
    end

    render.selectRenderTarget()
end )

hook.add( "render", "wgui:hook:render", function()
    local scrw, scrh = render.getResolution()
    local crsx, crsy = render.cursorPos()

    elementRecalculation( wgui.__data.rsScreen )

    wgui.__data.rsScreen.__data.cursor.x = crsx ~= nil and 1024 / scrw * crsx or nil
    wgui.__data.rsScreen.__data.cursor.y = crsy ~= nil and 1024 / scrh * crsy or nil

    render.setRenderTargetTexture( wgui.__data.rsScreenRT )
    render.setRGBA( 255, 255, 255, 255 )
    render.drawTexturedRect( 0, 0, scrw, scrh )
end )


return wgui
