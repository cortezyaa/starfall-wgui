--@name wgui/e/baseElement
--@author cortez


-- Инклюдинг утилит
requiredir( "../utils/" ) --@includedir ../utils/


-- Создание класса элемента
local Element = class( "wgui/e/baseElement" )
Element.static.elementName = "baseElement"

-- Функция генерирующая уникальный id элемента
-- Пока не знаю зачем он нужен, но пусть будет xdd
Element.static.chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
Element.static.charsLength = string.len( Element.static.chars )
Element.static.uid = function()
    local uid = ""

    for _ = 1, 10 do
        uid = uid .. Element.static.chars[ math.random( 1, Element.static.charsLength ) ]
    end

    return uid
end


-- Инитиализация
Element.initialize = function( self, elementName )
    checkType( elementName, "string" )

    self.__wgui = true
    self.__valid = true
    self.__shouldRecalculate = false
    
    -- Данные элемента
    self.__data = {}

    self.__data.uid = Element.static.uid()
    self.__data.elementName = elementName or Element.static.elementName

    self.__data.renderSpace = nil
    self.__data.parent = nil
    self.__data.children = {}

    self.__data.positionGlobal = { x = 0, y = 0 }
    self.__data.positionLocal = { x = 0, y = 0 }
    self.__data.sizeGlobal = { w = 0, h = 0 }
    self.__data.sizeLocal = { w = 0, h = 0 }

    self.__data.dockType = DOCK.NODOCK

    self.__data.dockMarginLeft = 0
    self.__data.dockMarginTop = 0
    self.__data.dockMarginRight = 0
    self.__data.dockMarginBottom = 0
    
    self.__data.dockPaddingLeft = 0
    self.__data.dockPaddingTop = 0
    self.__data.dockPaddingRight = 0
    self.__data.dockPaddingBottom = 0

    -- Ивенты
    self.__events = {}
end

-- Функция проверяет валидность элемента и при отсутствии вызывает ошибку
Element.fValidate = function( self )
    if self.__valid then return end
    error( "Element is not valid" )
end

-- Функция добавляет элементу, его дочерним элементам и родительскому ( при необходимости )
-- Параметр __shouldRecalculate, который в дальнейшем используется для выполнения перерасчета
Element.fRecalculate = function( self )
    self.__shouldRecalculate = true

    if self.__data.dockType ~= DOCK.NODOCK then
        if self.__data.parent then
            self.__data.parent.__shouldRecalculate = true
        else
            self.__data.renderSpace.__shouldRecalculate = true
        end
    end

    for _, child in pairs( self.__data.children ) do
        child:fRecalculate()
    end
end

-- Валидность
Element.isValid = function( self )
    return self.__valid
end

-- Удаление
Element.remove = function( self )
    self:fValidate()

    for _, child in pairs( self.__data.children ) do
        child:remove()
    end

    if self.__data.parent then
        table.removeByValue( self.__data.parent.children, self )
        self.__data.parent:fRecalculate()
    else
        table.removeByValue( self.__data.renderSpace.__data.children, self )
    end

    self.__valid = false
    self.__shouldRecalculate = false
    
    self.__data = {}
    self.__events = {}
end

-- Паренты 
Element.setParent = function( self, parent )
    self:fValidate()
    local _, parentT = checkType( parent, { "wgui", "nil" } )
    
    if parentType == "nil" then
        if self.__data.parent then
            table.removeByValue( self.__data.parent, self )
            self.__data.parent = nil

            table.insert( self.__data.renderSpace.__data.children, self )
        end

        return
    end

    if parent == self.__data.parent then return end

    if table.hasValue( self.__data.children, parent ) then
        error( "Element cannot be parented to its child element" )
    end

    table.insert( parent.__data.children, self )
    self.__data.renderSpace = parent.__data.renderSpace
    self.__data.parent = parent

    self:fRecalculate()
end

Element.getParent = function( self )
    self:fValidate()

    return self.__data.parent
end

Element.getChildren = function( self )
    self:fValidate()

    return self.__data.children
end

-- Позиция
Element.setPosition = function( self, x, y )
    self:fValidate()
    checkType( x, "number" )
    checkType( y, "number" )

    self.__data.positionLocal.x = x
    self.__data.positionLocal.y = y

    self:fRecalculate()
end

Element.getPosition = function( self )
    self:fValidate()

    return self.__data.positionLocal.x, self.__data.positionLocal.y
end

Element.getPositionGlobal = function( self )
    self:fValidate()

    return self.__data.positionGlobal.x, self.__data.positionGlobal.y
end

-- Размер
Element.setSize = function( self, w, h )
    self:fValidate()
    checkType( w, "number" )
    checkType( h, "number" )

    self.__data.sizeLocal.w = w
    self.__data.sizeLocal.h = h

    self:fRecalculate()
end

Element.getSize = function( self )
    self:fValidate()

    return self.__data.sizeLocal.w, self.__data.sizeLocal.h
end

Element.getSizeGlobal = function( self )
    self:fValidate()

    return self.__data.sizeGlobal.w, self.__data.sizeGlobal.h
end

-- Докинг
Element.setDock = function( self, dockType )
    self:fValidate()
    checkType( dockType, "number" )

    self.__data.dockType = dockType

    self:fRecalculate()
end

Element.setDockMargin = function( self, left, top, right, bottom )
    self:fValidate()
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )

    self.__data.dockMarginLeft = left
    self.__data.dockMarginTop = top
    self.__data.dockMarginRight = right
    self.__data.dockMarginBottom = bottom

    self:fRecalculate()
end

Element.setDockPadding = function( self, left, top, right, bottom )
    self:fValidate()
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )
    
    self.__data.dockPaddingLeft = left
    self.__data.dockPaddingTop = top
    self.__data.dockPaddingRight = right
    self.__data.dockPaddingBottom = bottom

    self:fRecalculate()
end

Element.getDock = function( self )
    self:fValidate()

    return self.__data.dockType
end

Element.getDockMargin = function( self )
    self:fValidate()

    return self.__data.dockMarginLeft, self.__data.dockMarginTop, self.__data.dockMarginRight, self.__data.dockMarginBottom
end

Element.getDockPadding = function( self )
    self:fValidate()

    return self.__data.dockPaddingLeft, self.__data.dockPaddingTop, self.__data.dockPaddingRight, self.__data.dockPaddingBottom
end

-- Ивенты
Element.eventAdd = function( self, name, func )
    self:fValidate()
    checkType( name, "string" )
    checkType( func, "function" )

    self.__events[ name ] = func
end

Element.eventRemove = function( self, name )
    self:fValidate()
    checkType( name, "string" )

    self.__events[ name ] = nil
end

Element.eventCall = function( self, name, ... )
    self:fValidate()
    checkType( name, "string" )
    
    if self.__events[ name ] then
        self.__events[ name ]( self, ... )
    end
end

-- Функция рисования элемента
Element.paint = function( self )
    return
end

-- Рендер
Element.render = function( self )
    if not self.__valid then return end

    self:paint()
end


-- Возвращаем класс элемента
return Element
