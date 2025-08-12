--@name wgui/e/base

-- Включение утилит
requiredir( "../utils/" ) --@includedir ../utils/


-- Создание класса
local Element = class( "wgui/e/base" )
Element.static.elementName = "base"


-- Инитиализация
Element.initialize = function( self, elementName )
    checkType( elementName, "string" )

    self.__wgui = true 
    self.__valid = true 

    -- Данные элемента
    self.__data = {}
    
    self.__data.elementName = elementName

    self.__data.parent = nil
    self.__data.renderSpace = nil
    self.__data.children = {}

    self.__data.positionLocal = { x = 0, y = 0 }
    self.__data.positionGlobal = { x = 0, y = 0 }

    self.__data.sizeLocal = { w = 0, h = 0 }
    self.__data.sizeGlobal = { w = 0, h = 0 }

    self.__data.dock = DOCK.NODOCK
    self.__data.dockMargin = { left = 0, top = 0, right = 0, bottom = 0 }
    self.__data.dockPadding = { left = 0, top = 0, right = 0, bottom = 0 }

    self.__data.overflow = OVERFLOW.VISIBLE
    self.__data.overflowBox = { left = 0, top = 0, right = 0, bottom = 0 }

    self.__data.shouldUseStencil = false

    self.__data.hitbox = { left = 0, top = 0, right = 0, bottom = 0 }

    -- Ивенты
    self.__events = {}
end


-- Системныя функция проверки действительности элемента
-- Если элемент не действителен, то вызывается ошибка
Element.__validate = function( self )
    if self.__valid then
        return
    end

    throw( "Element is not valid" )
end


-- Системная функция перерасчета элемента
Element.__recalculation = function( self )
    local fill = {}
    local space = {
        left = self.__data.dockPadding.left,
        top = self.__data.dockPadding.top,
        right = self.__data.sizeGlobal.w - self.__data.dockPadding.right,
        bottom = self.__data.sizeGlobal.h - self.__data.dockPadding.bottom
    }

    for _, child in pairs( self.__data.children ) do
        if child.__data.dock == DOCK.NODOCK then
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + child.__data.positionLocal.x
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + child.__data.positionLocal.y

            child.__data.sizeGlobal.w = child.__data.sizeLocal.w
            child.__data.sizeGlobal.h = child.__data.sizeLocal.h
        elseif child.__data.dock == DOCK.FILL then
            table.insert( fill, child )
        elseif child.__data.dock == DOCK.LEFT then
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMargin.left
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMargin.top

            child.__data.sizeGlobal.w = child.__data.sizeLocal.w
            child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMargin.top - child.__data.dockMargin.bottom

            space.left = space.left + child.__data.sizeGlobal.w + child.__data.dockMargin.left + child.__data.dockMargin.right
        elseif child.__data.dock == DOCK.TOP then
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMargin.left
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMargin.top

            child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMargin.left - child.__data.dockMargin.right
            child.__data.sizeGlobal.h = child.__data.sizeLocal.h

            space.top = space.top + child.__data.sizeGlobal.h + child.__data.dockMargin.top + child.__data.dockMargin.bottom
        elseif child.__data.dock == DOCK.RIGHT then
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.right - child.__data.sizeLocal.w - child.__data.dockMargin.right
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMargin.top
                
            child.__data.sizeGlobal.w = child.__data.sizeLocal.w
            child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMargin.top - child.__data.dockMargin.bottom
                
            space.right = space.right - child.__data.sizeGlobal.w - child.__data.dockMargin.left - child.__data.dockMargin.right
        elseif child.__data.dock == DOCK.BOTTOM then
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMargin.left
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.bottom - child.__data.sizeLocal.h - child.__data.dockMargin.bottom
                
            child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMargin.left - child.__data.dockMargin.right
            child.__data.sizeGlobal.h = child.__data.sizeLocal.h
                
            space.bottom = space.bottom - child.__data.sizeGlobal.h - child.__data.dockMargin.top - child.__data.dockMargin.bottom
        end
    end

    for _, child in pairs( self.__data.children )
        if table.hasValue( fill, child ) then
            child.__data.positionGlobal.x = self.__data.positionGlobal.x + space.left + child.__data.dockMargin.left
            child.__data.positionGlobal.y = self.__data.positionGlobal.y + space.top + child.__data.dockMargin.top
            
            child.__data.sizeGlobal.w = space.right - space.left - child.__data.dockMargin.left - child.__data.dockMargin.right
            child.__data.sizeGlobal.h = space.bottom - space.top - child.__data.dockMargin.top - child.__data.dockMargin.bottom
        end

        local x = child.__data.positionGlobal.x
        local y = child.__data.positionGlobal.y
        local w = child.__data.sizeGlobal.w
        local h = child.__data.sizeGlobal.h

        if child.__data.overflow == OVERFLOW.VISIBLE then
            child.__data.overflowBox.left = self.__data.overflowBox.left
            child.__data.overflowBox.top = self.__data.overflowBox.top
            child.__data.overflowBox.right = self.__data.overflowBox.right
            child.__data.overflowBox.bottom = self.__data.overflowBox.bottom
        else
            child.__data.overflowBox.left = math.max( x, self.__data.overflowBox.left )
            child.__data.overflowBox.top = math.max( y, self.__data.overflowBox.top )
            child.__data.overflowBox.right = math.min( x + w, self.__data.overflowBox.right )
            child.__data.overflowBox.bottom = math.min( y + h, self.__data.overflowBox.bottom )
        end

        child.__data.hitbox.left = math.clamp( math.max( x, child.__data.overflowBox.left ), child.__data.overflowBox.left, child.__data.overflowBox.right )
        child.__data.hitbox.top = math.clamp( math.max( y, child.__data.overflowBox.top ), child.__data.overflowBox.top, child.__data.overflowBox.bottom )
        child.__data.hitbox.right = math.clamp( math.min( x + w, child.__data.overflowBox.right ), child.__data.overflowBox.left, child.__data.overflowBox.right )
        child.__data.hitbox.bottom = math.clamp( math.min( y + h, child.__data.overflowBox.bottom ), child.__data.overflowBox.top, child.__data.overflowBox.bottom )

        child:__recalculation()
    end
end


-- Системная функция вызываемая для перерасчета элемента
Element.__recalculate = function( self )
    -- Вызывается перерасчет родительского (рендер спейса) элемента
end


-- Cистемная функция удаления элемента
Element.__remove = function( self )
    self:__validate()

    for _, element in pairs( self.__data.children ) do
        element:__remove()
    end

    self.__valid = false
    self.__data = {}
    self.__events = {}
end


-- Функция проверки действительности элемента
Element.isValid = function( self )
    return self.__valid
end


-- Функция удаления элемента
Element.remove = function( self )
    self:__validate()

    local parent = self.__data.parent or self.__data.renderSpace

    table.removeByValue( parent.__data.children, self )
    self:__remove()
    parent:__recalculate()
end


-- Функции связанные с управление родительскими элементами
-- Установка родительского элемента
Element.setParent = function( self, parent )
    self:__validate()
    local _, parentType = checkType( parent, { "wgui", "nil" } )

    if parent.__data.rs and self.__data.renderSpace == parent then return end
    if self.__data.parent == parent then return end

    -- unparent section
    local oldparent = self.__data.parent or self.__data.renderSpace

    table.removeByValue( oldparent.__data.children, self )
    oldparent:__recalculate()
    self.__data.parent = nil
    
    if parentType ~= "nil" then
        if parent.__data.rs then
            self.__data.renderSpace = parent
        else
            self.__data.parent = parent
            self.__data.renderSpace = parent.__data.renderSpace
        end
        
        table.insert( parent.__data.children, self )
    end

    self:__recalculate()
end

-- Получение родительского элемента
Element.getParent = function( self )
    self:__validate()
    return self.__data.parent
end

-- Получение дочерних элементов
Element.getChildren = function( self )
    self:__validate()
    return self.__data.children
end


-- Функции связанные с позиционированием элемента
-- Установка позиции
Element.setPos = function( self, x, y )
    self:__validate()
    checkType( x, "number" )
    checkType( y, "number" )

    self.__data.positionLocal.x = x
    self.__data.positionLocal.y = y

    self:__recalculate()
end

-- Получение локальной позиции
Element.getPos = function( self )
    self:__validate()
    return self.__data.positionLocal.x, self.__data.positionLocal.y
end

-- Получение глобальной позиции
Element.getPosGlobal = function( self )
    self:__validate()
    return self.__data.positionGlobal.x, self.__data.positionGlobal.y
end


-- Функции связанные с размером элемента
-- Установка размера
Element.setSize = function( self, w, h )
    self:__validate()
    checkType( w, "number" )
    checkType( h, "number" )

    self.__data.sizeLocal.w = w
    self.__data.sizeLocal.h = h

    self:__recalculate()
end

-- Получение локального размера
Element.getSize = function( self )
    self:__validate()
    return self.__data.sizeLocal.w, self.__data.sizeLocal.h
end

-- Получение глобального размера
Element.getSizeGlobal = function( self )
    self:__validate()
    return self.__data.sizeGlobal.w, self.__data.sizeGlobal.h
end


-- Функции связанные с докингом элемента
-- Установка типа дока для элемента
Element.dock = function( self, dockType )
    self:__validate()
    checkType( dockType, "number" )

    self.__data.dock = dockType

    self:__recalculate()
end

-- Установка внешнего отступа элемента
Element.dockMargin = function( self, left, top, right, bottom )
    self:__validate()
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )

    self.__data.dockMargin.left = left
    self.__data.dockMargin.top = top
    self.__data.dockMargin.right = right
    self.__data.dockMargin.bottom = bottom

    self:__recalculate()
end

-- Установка внутреннего отступа элемента
Element.dockPadding = function( self, left, top, right, bottom )
    self:__validate()
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )

    self.__data.dockPadding.left = left
    self.__data.dockPadding.top = top
    self.__data.dockPadding.right = right
    self.__data.dockPadding.bottom = bottom

    self:__recalculate()
end

-- Получение дока жлемента
Element.getDock = function( self )
    self:__validate()
    return self.__data.dock
end

-- Получение внешнего отступа элемента
Element.getDockMargin = function( self )
    self:__validate()
    return self.__data.dockMargin.left, self.__data.dockMargin.top, self.__data.dockMargin.right, self.__data.dockMargin.bottom
end

-- Получение внутреннего отступа элемента
Element.getDockPadding = function( self )
    self:__validate()
    return self.__data.dockPadding.left, self.__data.dockPadding.top, self.__data.dockPadding.right, self.__data.dockPadding.bottom
end


-- Функции управления параметром overflow
-- Установка параметра
Element.setOverflow = function( self, overflow )
    self:__validate()
    checkType( validate, "number" )

    self.__data.overflow = overflow

    self:__recalculate()
end

-- Получение параметра
Element.getOverflow = function( self )
    self:__validate()
    return self.__data.overflow
end


-- Функции рендера элемента
Element.render = function( self )
    if not self.__valid then return end

    -- Добавить проверку должен ли рендерится элемент
    -- Или использовать стенцилы
    
    self:paint()

    for _, child in pairs( self.__data.children ) do
        child:render()
    end
end


-- Функция рисования элемента
Element.paint = function( self )
    -- Тут ничего не будет 🍷🗿
end


-- Возврат класса элемента
return Element




--[[

СПРАВКА

positionLocal, sizeLocal - данные задаются пользователем
positionGlobal, sizeGlobal - данные вычисляются и используется элементом для рендера и взаимодействий

overflow - значение оверфлова
overflowBox - коробка по которой производится обрезка, world координаты

--]]