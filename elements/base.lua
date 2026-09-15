--@name wgui/e/base

-- Включение утилит
requiredir( "../utils/" ) --@includedir ../utils/


-- Создание класса
local Element = class( "wgui/base" )
Element.static.elementName = "base"


-- Инитиализация
Element.initialize = function( self, elementName )
    checkType( elementName, "string" )

    self.uid = uidlib.generate()

    self.wgui = true
    self.valid = true

    -- Данные элемента
    self.data = {}
    
    self.data.elementName = elementName

    self.data.parent = nil
    self.data.renderSpace = nil
    self.data.children = {}
    self.data.parentsTree = {}

    self.data.positionLocal = { x = 0, y = 0 }
    self.data.positionGlobal = { x = 0, y = 0 }

    self.data.sizeLocal = { w = 0, h = 0 }
    self.data.sizeGlobal = { w = 0, h = 0 }

    self.data.dock = DOCK.NODOCK
    self.data.dockMargin = { left = 0, top = 0, right = 0, bottom = 0 }
    self.data.dockPadding = { left = 0, top = 0, right = 0, bottom = 0 }

    self.data.overflow = OVERFLOW.VISIBLE
    self.data.overflowBox = { left = 0, top = 0, right = 0, bottom = 0 }

    self.data.hitbox = { left = 0, top = 0, right = 0, bottom = 0 }

    self.data.noDraw = false
    self.data.hitIgnore = false

    self.data.shouldDraw = true
    self.data.shouldUseStencil = false

    self.data.value = false

    self.data.hover = false
    self.data.focus = false

    self.data.realtime = timer.realtime()

    self.data.transition = 0
    self.data.transitionTime = 0.25

    self.data.palette = table.copy( wgui.palette )
    self.data.colors = {}

    -- Ивенты
    self.events = { system = {} }

    -- Анимации [ musthave ]
    self.animations = {}
end


-- Оптимизация?
local math_lerp = math.lerp
local math_clamp = math.clamp
local math_abs = math.abs
local math_sin = math.sin
local math_min = math.min
local math_max = math.max
local render_setRGBA = render.setRGBA
local render_drawRectFast = render.drawRectFast
local render_drawRectOutline = render.drawRectOutline
local render_drawCircle = render.drawCircle
local render_setFont = render.setFont
local render_getTextSize = render.getTextSize
local render_drawSimpleText = render.drawSimpleText
local render_setStencilEnable = render.setStencilEnable
local render_clearStencil = render.clearStencil
local render_setStencilTestMask = render.setStencilTestMask
local render_setStencilWriteMask = render.setStencilWriteMask
local render_setStencilPassOperation = render.setStencilPassOperation
local render_setStencilZFailOperation = render.setStencilZFailOperation
local render_setStencilCompareFunction = render.setStencilCompareFunction
local render_setStencilReferenceValue = render.setStencilReferenceValue
local render_setStencilFailOperation = render.setStencilFailOperation


-- Системныя функция проверки действительности элемента
-- Если элемент не действителен, то вызывается ошибка
Element.sysValidate = function( self )
    if self.valid then
        return
    end

    throw( "Element is not valid" )
end


-- Системная функция перерасчета элемента ( а точнее его дочерних элементов )
local self_data, self_pgx, self_pgy
local children, child_data, child_margin, cx, cy, cw, ch, coLeft, coTop, coRight, coBottom
local spaceLeft, spaceTop, spaceRight, spaceBottom

Element.sysRecalculation = function( self )
    self_data = self.data
    self_pgx = self_data.positionGlobal.x
    self_pgy = self_data.positionGlobal.y

    children = self_data.children

    spaceLeft = self_data.dockPadding.left
    spaceTop = self_data.dockPadding.top
    spaceRight = self_data.sizeGlobal.w - self_data.dockPadding.right
    spaceBottom = self_data.sizeGlobal.h - self_data.dockPadding.bottom

    for _, child in pairs( children ) do
        child_data = child.data
        child_margin = child_data.dockMargin

        if child_data.dock == DOCK.NODOCK then
            child_data.sizeGlobal.w = child_data.sizeLocal.w
            child_data.sizeGlobal.h = child_data.sizeLocal.h

            child_data.positionGlobal.x = self_pgx + child_data.positionLocal.x
            child_data.positionGlobal.y = self_pgy + child_data.positionLocal.y
        else
            -- DOCK.FILL в следующем цикле
            if child_data.dock == DOCK.LEFT then
                child_data.sizeGlobal.w = math_max( 0, math_min( child_data.sizeLocal.w, spaceRight - spaceLeft ) )
                child_data.sizeGlobal.h = math_max( 0, spaceBottom - spaceTop - child_margin.top - child_margin.bottom )

                child_data.positionGlobal.x = self_pgx + spaceLeft + child_margin.left
                child_data.positionGlobal.y = self_pgy + spaceTop + child_margin.top

                spaceLeft = spaceLeft + child_data.sizeGlobal.w + child_margin.left + child_margin.right
            elseif child_data.dock == DOCK.TOP then
                child_data.sizeGlobal.w = math_max( 0, spaceRight - spaceLeft - child_margin.left - child_margin.right )
                child_data.sizeGlobal.h = math_max( 0, math_min( child_data.sizeLocal.h, spaceBottom - spaceTop ) )

                child_data.positionGlobal.x = self_pgx + spaceLeft + child_margin.left
                child_data.positionGlobal.y = self_pgy + spaceTop + child_margin.top

                spaceTop = spaceTop + child_data.sizeGlobal.h + child_margin.top + child_margin.bottom
            elseif child_data.dock == DOCK.RIGHT then
                child_data.sizeGlobal.w = math_max( 0, math_min( child_data.sizeLocal.w, spaceRight - spaceLeft ) )
                child_data.sizeGlobal.h = math_max( 0, spaceBottom - spaceTop - child_margin.top - child_margin.bottom )

                child_data.positionGlobal.x = self_pgx + spaceRight - child_data.sizeGlobal.w - child_margin.right
                child_data.positionGlobal.y = self_pgy + spaceTop + child_margin.top

                spaceRight = spaceRight - child_data.sizeGlobal.w - child_margin.left - child_margin.right
            elseif child_data.dock == DOCK.BOTTOM then
                child_data.sizeGlobal.w = math_max( 0, spaceRight - spaceLeft - child_margin.left - child_margin.right )
                child_data.sizeGlobal.h = math_max( 0, math_min( child_data.sizeLocal.h, spaceBottom - spaceTop ) )

                child_data.positionGlobal.x = self_pgx + spaceLeft + child_margin.left
                child_data.positionGlobal.y = self_pgy + spaceBottom - child_data.sizeGlobal.h - child_margin.bottom

                spaceBottom = spaceBottom - child_data.sizeGlobal.h - child_margin.top - child_margin.bottom
            end
        end
    end

    for _, child in pairs( children ) do
        child_data = child.data
        child_margin = child_data.dockMargin

        if child_data.dock == DOCK.FILL then
            child_data.sizeGlobal.w = math_max( 0, spaceRight - spaceLeft - child_margin.left - child_margin.right )
            child_data.sizeGlobal.h = math_max( 0, spaceBottom - spaceTop - child_margin.top - child_margin.bottom )

            child_data.positionGlobal.x = self_pgx + spaceLeft + child_margin.left
            child_data.positionGlobal.y = self_pgy + spaceTop + child_margin.top
        end

        cx = child_data.positionGlobal.x
        cy = child_data.positionGlobal.y
        cw = child_data.sizeGlobal.w
        ch = child_data.sizeGlobal.h

        if child_data.overflow == OVERFLOW.VISIBLE then
            child_data.overflowBox.left = self_data.overflowBox.left
            child_data.overflowBox.top = self_data.overflowBox.top
            child_data.overflowBox.right = self_data.overflowBox.right
            child_data.overflowBox.bottom = self_data.overflowBox.bottom
        else
            child_data.overflowBox.left = math_clamp( cx, self_data.overflowBox.left, self_data.overflowBox.right )
            child_data.overflowBox.top = math_clamp( cy, self_data.overflowBox.top, self_data.overflowBox.bottom )
            child_data.overflowBox.right = math_clamp( cx + cw, self_data.overflowBox.left, self_data.overflowBox.right )
            child_data.overflowBox.bottom = math_clamp( cy + ch, self_data.overflowBox.top, self_data.overflowBox.bottom )
        end

        coLeft = child_data.overflowBox.left
        coTop = child_data.overflowBox.top
        coRight = child_data.overflowBox.right
        coBottom = child_data.overflowBox.bottom

        child_data.hitbox.left = math_clamp( math_max( cx, coLeft ), coLeft, coRight )
        child_data.hitbox.top = math_clamp( math_max( cy, coTop ), coTop, coBottom )
        child_data.hitbox.right = math_clamp( math_min( cx + cw, coRight ), coLeft, coRight )
        child_data.hitbox.bottom = math_clamp( math_min( cy + ch, coBottom ), coTop, coBottom )

        child_data.shouldUseStencil = 
            ( cx < coLeft ) or 
            ( cy < coTop ) or 
            ( ( cx + cw ) > coRight ) or 
            ( ( cy + ch ) > coBottom )

        child_data.shouldDraw = 
            ( cw >= 0 and ch >= 0 ) and
            ( cx <= coRight ) and
            ( cy <= coBottom ) and
            ( ( cx + cw ) >= coLeft ) and
            ( ( cy + ch ) >= coTop )

        child:sysRecalculation()
    end
end


-- Системная функция вызываемая для перерасчета элемента
Element.sysRecalculate = function( self )
    self.data.renderSpace:pushRecalculation( self.data.parent or self.data.renderSpace )
end


-- Cистемная функция удаления элемента
Element.sysRemove = function( self )
    self:sysValidate()

    for _, child in pairs( self.data.children ) do
        child:sysRemove()
    end

    self:callEvent( WGUIEVENTS.REMOVED ) 

    self.valid = false
    self.data = {}
    self.events = {}
end


-- Функция просчета цвета
Element.sysRecalculateColors = function( self )
    -- Тут ничего не будет 🍷🗿
end


-- Функция проверки возможностьи фокуса на элементе
Element.sysFocus = function( self )
    return true
end


-- Функция проверки действительности элемента
Element.isValid = function( self )
    return self.valid
end


-- Функция удаления элемента
Element.remove = function( self )
    self:sysValidate()

    local parent = self.data.parent or self.data.renderSpace

    table.removeByValue( parent.data.children, self )
    self:sysRemove()
    parent:sysRecalculate()
end


-- Функции связанные с управление родительскими элементами
-- Установка родительского элемента
local function buildTree( self, tree )
    if self.data.parent then
        table.insert( tree, self.data.parent )
        buildTree( self.data.parent, tree )
    end

    return tree
end

Element.setParent = function( self, parent )
    self:sysValidate()
    local _, parentType = checkType( parent, { "wgui", "nil" } )

    -- Снятие парента
    if parentType == "nil" then
        if self.data.parent then
            table.removeByValue( self.data.parent.data.children, self )
            self.data.parent:sysRecalculate()
            self.data.parent:callEvent( WGUIEVENTS.CHILDRENREMOVED, self )
            self.data.parent = nil

            table.insert( self.data.renderSpace.data.children, self )
            self:sysRecalculate()
            self.data.renderSpace:callEvent( WGUIEVENTS.CHILDRENADDED, self )
        end

        return
    end

    -- К renderSpace'у
    if parent.isRenderSpace then
        if self.data.renderSpace == parent then return end

        local oldparent = self.data.parent or self.data.renderSpace

        if oldparent then
            table.removeByValue( oldparent.data.children, self )
            oldparent:sysRecalculate()
            oldparent:callEvent( WGUIEVENTS.CHILDRENREMOVED, self )
            self.data.parent = nil
        end

        self.data.renderSpace = parent
        table.insert( parent.data.children, self )
        self:sysRecalculate()
        parent:callEvent( WGUIEVENTS.CHILDRENADDED, self )

        return
    end

    -- К элементу
    if self.data.parent == parent then return end

    local oldparent = self.data.parent or self.data.renderSpace

    if oldparent then
        table.removeByValue( oldparent.data.children, self )
        oldparent:sysRecalculate()
        oldparent:callEvent( WGUIEVENTS.CHILDRENREMOVED, self )
        self.data.parent = nil
    end
    
    self.data.renderSpace = parent.data.renderSpace
    self.data.parent = parent
    table.insert( parent.data.children, self )

    self.data.parentsTree = buildTree( self, { self.data.renderSpace } )

    self:sysRecalculate()
    parent:callEvent( WGUIEVENTS.CHILDRENADDED, self )
end

-- Получение родительского элемента
Element.getParent = function( self )
    self:sysValidate()
    return self.data.parent
end

-- Получение дочерних элементов
Element.getChildren = function( self )
    self:sysValidate()
    return self.data.children
end

-- Получение renderSpace'а элемента
Element.getRenderSpace = function( self )
    self:sysValidate()
    return self.data.renderSpace
end


-- Хитскан функция
Element.hitscan = function( self, x, y )
    if self.data.hitbox.left >= self.data.hitbox.right or self.data.hitbox.top >= self.data.hitbox.bottom then return false end
    return x >= self.data.hitbox.left and x <= self.data.hitbox.right and y >= self.data.hitbox.top and y <= self.data.hitbox.bottom
end


-- Функции связанные с позиционированием элемента
-- Установка локальной позиции
Element.setPos = function( self, x, y )
    self:sysValidate()
    checkType( x, "number" )
    checkType( y, "number" )

    self.data.positionLocal.x = x
    self.data.positionLocal.y = y

    self:sysRecalculate()
end

-- Получение локальной позиции
Element.getPos = function( self )
    self:sysValidate()
    return self.data.positionLocal.x, self.data.positionLocal.y
end

-- Получение глобальной позиции
Element.getPosGlobal = function( self )
    self:sysValidate()
    return self.data.positionGlobal.x, self.data.positionGlobal.y
end


-- Функции связанные с размером элемента
-- Установка размера
Element.setSize = function( self, w, h )
    self:sysValidate()
    checkType( w, "number" )
    checkType( h, "number" )

    self.data.sizeLocal.w = w
    self.data.sizeLocal.h = h

    self:sysRecalculate()
end

-- Получение локального размера
Element.getSize = function( self )
    self:sysValidate()
    return self.data.sizeLocal.w, self.data.sizeLocal.h
end

-- Получение глобального размера
Element.getSizeGlobal = function( self )
    self:sysValidate()
    return self.data.sizeGlobal.w, self.data.sizeGlobal.h
end


-- Функции связанные с докингом элемента
-- Установка типа дока для элемента
Element.dock = function( self, dockType )
    self:sysValidate()
    checkType( dockType, "number" )
    checkEnum( dockType, "DOCK" )

    self.data.dock = dockType

    self:sysRecalculate()
end

-- Установка внешнего отступа элемента
Element.dockMargin = function( self, left, top, right, bottom )
    self:sysValidate()
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )

    self.data.dockMargin.left = left
    self.data.dockMargin.top = top
    self.data.dockMargin.right = right
    self.data.dockMargin.bottom = bottom

    self:sysRecalculate()
end

-- Установка внутреннего отступа элемента
Element.dockPadding = function( self, left, top, right, bottom )
    self:sysValidate()
    checkType( left, "number" )
    checkType( top, "number" )
    checkType( right, "number" )
    checkType( bottom, "number" )

    self.data.dockPadding.left = left
    self.data.dockPadding.top = top
    self.data.dockPadding.right = right
    self.data.dockPadding.bottom = bottom

    self:sysRecalculate()
end

-- Получение дока жлемента
Element.getDock = function( self )
    self:sysValidate()
    return self.data.dock
end

-- Получение внешнего отступа элемента
Element.getDockMargin = function( self )
    self:sysValidate()
    return self.data.dockMargin.left, self.data.dockMargin.top, self.data.dockMargin.right, self.data.dockMargin.bottom
end

-- Получение внутреннего отступа элемента
Element.getDockPadding = function( self )
    self:sysValidate()
    return self.data.dockPadding.left, self.data.dockPadding.top, self.data.dockPadding.right, self.data.dockPadding.bottom
end


-- Функции управления значением элемента
-- Установка значением
Element.setValue = function( self, value )
    self:sysValidate()

    local valueOld = self.data.value
    self.data.value = value

    self:sysRecalculateColors()
    self:callEvent( WGUIEVENTS.VALUECHANGED, value, valueOld )
end

-- Получение значением
Element.getValue = function( self )
    self:sysValidate()
    return self.data.value
end


-- Функции управления параметром overflow
-- Установка параметра
Element.setOverflow = function( self, overflow )
    self:sysValidate()
    checkType( overflow, "number" )
    checkEnum( overflow, "OVERFLOW" )

    self.data.overflow = overflow

    self:sysRecalculate()
end

-- Получение параметра
Element.getOverflow = function( self )
    self:sysValidate()
    return self.data.overflow
end


-- Устанавливает, следует ли рисовать элемент (и его дочерние) или нет
-- Установка параметра
Element.setNoDraw = function( self, noDraw )
    self:sysValidate()
    checkType( noDraw, "boolean" )

    self.data.noDraw = noDraw
end

-- Получение параметра
Element.getNoDraw = function( self )
    self:sysValidate()
    return self.data.noDraw
end


-- Устанавливает, следует ли игнорировать элемент при наведении на него курсора
-- Установка параметра
Element.setHitIgnore = function( self, hitIgnore )
    self:sysValidate()
    checkType( hitIgnore, "boolean" )

    self.data.hitIgnore = hitIgnore
end

-- Получение параметра
Element.getHitIgnore = function( self )
    self:sysValidate()
    return self.data.hitIgnore
end


-- Ивенты
Element.addEvent = function( self, event, callback )
    self:sysValidate()
    checkType( event, "string" )
    checkEnum( event, "WGUIEVENTS" )
    checkType( callback, "function" )

    self.events[ event ] = callback
end

Element.callEvent = function( self, event, ... )
    if not isValid( self ) then return end
    checkType( event, "string" )

    if self.events.system[ event ] then
        self.events.system[ event ]( self, ... )
    end

    if self.events[ event ] then
        self.events[ event ]( self, ... )
    end
end


-- Функции рендера элемента
Element.render = function( self )
    if not self.valid then return end
    
    if self.data.noDraw then return end

    oldtransition = self.data.transition
    self.data.transition = math_lerp( self.data.transition + ( self.data.hover and 1 or -1 ) * ( ( timer.realtime() - self.data.realtime ) / self.data.transitionTime ), 0, 1 )

    if self.data.transition ~= oldtransition then
        self:sysRecalculateColors()
    end

    self.data.realtime = timer.realtime()

    if self.data.shouldDraw then
        if self.data.shouldUseStencil then
            render_setStencilEnable( true )
            render_clearStencil()
            render_setStencilTestMask( 255 )
            render_setStencilWriteMask( 255 )
            render_setStencilPassOperation( STENCIL.KEEP )
            render_setStencilZFailOperation( STENCIL.KEEP )
            render_setStencilCompareFunction( STENCIL.NEVER )
            render_setStencilReferenceValue( 1 )
            render_setStencilFailOperation( STENCIL.REPLACE )

            render_drawRectFast( 
                self.data.overflowBox.left, 
                self.data.overflowBox.top, 
                self.data.overflowBox.right - self.data.overflowBox.left,
                self.data.overflowBox.bottom - self.data.overflowBox.top
            )

            render_setStencilFailOperation( STENCIL.KEEP )
            render_setStencilCompareFunction( STENCIL.EQUAL )

            self:paint()

            render_setStencilEnable( false )
        else
            self:paint()
        end
    end

    for _, child in pairs( self.data.children ) do
        child:render()
    end
end


-- Функции рендера элемента (debug)
Element.debugrender = function( self )
    if not self.valid then return end

    for _, child in pairs( self.data.children ) do
        child:debugrender()
    end

    render_setRGBA( self.data.focus and 0 or 255, 255, 255, self.data.focus and math_abs( math_sin( timer.realtime() * 5 ) * 255 ) or 255 )
    render_drawRectOutline( self.data.positionGlobal.x, self.data.positionGlobal.y, self.data.sizeGlobal.w, self.data.sizeGlobal.h )
    
    render_setFont( "DebugFixed" )
    render_setRGBA( 255, 255, 255, 255 )

    local O = 10
    local L = -1
    L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "element : " .. tostring( self.data.elementName ) )
    L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "uid : " .. self.uid )
    L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "value : " .. tostring( self.data.value ) )
    L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "transition : " .. tostring( self.data.transition ) )
    L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "hover : " .. tostring( self.data.hover ) .. " / focus : " .. tostring( self.data.focus ) )
    L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "draw : " .. tostring( self.data.shouldDraw ) .. " / stencil : " .. tostring( self.data.shouldUseStencil ) )

    -- renderSpace
    if self.isRenderSpace then
        L=L+1 render_drawSimpleText( self.data.positionGlobal.x + 4, self.data.positionGlobal.y +O*L, "enabled : " .. tostring( self.cursor.enabled ) )

        local TAL, TAC = TEXT_ALIGN.LEFT, TEXT_ALIGN.CENTER
        
        render_setRGBA( 255, 255, 255, 255 )
        render_drawCircle( self.cursor.position.x, self.cursor.position.y, 4 )
        render_drawSimpleText( self.cursor.position.x + O, self.cursor.position.y, "hover: " .. ( self.data.hoverElement and self.data.hoverElement.uid or "" ), TAL, TAC )
        render_drawSimpleText( self.cursor.position.x + O, self.cursor.position.y + O, "click: " .. ( self.cursor.clickElement and self.cursor.clickElement.uid or "" ), TAL, TAC )
        render_drawSimpleText( self.cursor.position.x + O, self.cursor.position.y + O*2, "L=" .. tostring( self.cursor.keyLeft ) .. " / R=" .. tostring( self.cursor.keyRight ), TAL, TAC )
    end

    render_setRGBA( 255, 0, 0, 255 )
    render_drawRectOutline( 
        self.data.hitbox.left + 1, 
        self.data.hitbox.top + 1, 
        self.data.hitbox.right - self.data.hitbox.left - 2, 
        self.data.hitbox.bottom - self.data.hitbox.top - 2
    )

    render_setRGBA( 0, 0, 255, 255 )
    render_drawRectOutline( 
        self.data.overflowBox.left + 2, 
        self.data.overflowBox.top + 2, 
        self.data.overflowBox.right - self.data.overflowBox.left - 4, 
        self.data.overflowBox.bottom - self.data.overflowBox.top - 4
    )
end


-- Функция отрисовки элемента
Element.paint = function( self )
    -- Тут ничего не будет 🍷🗿
end


-- Возврат класса элемента
return Element
