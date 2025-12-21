--@name wgui/u/utils


-- Перезапись некоторых функции
local old_type = type
function type( object )
    local resoult = old_type( object )

    if resoult == "table" and object.wgui then
        return "wgui"
    end

    return resoult
end

local old_isValid = isValid
function isValid( object )
    if object.wgui then
        return object:isValid()
    end

    return old_isValid( object )
end


-- Функция сравнивания типа объекта с ожидаемым
function checkType( object, expected, shouldError )
    local objectType = type( object )
    local expectedType = type( expected )
    local shouldErrorType = type( shouldError )

    if expectedType ~= "string" and expectedType ~= "table" then throw( "Expected string or table got " .. expectedType ) end
    if shouldErrorType ~= "nil" and shouldErrorType ~= "boolean" then throw( "Expected boolean got " .. shouldErrorType ) end

    shouldError = shouldError == nil and true or shouldError

    local resoult = false
    local expectedString = ""

    if expectedType == "string" then
        resoult = objectType == expected
        expectedString = expected
    else
        for index, rexpected in pairs( expected ) do
            if rexpected == objectType then
                resoult = true
                break
            end

            expectedString = expectedString .. ( index == 1 and rexpected or ( index == #expected and ( " or " .. rexpected ) or ( ", " .. rexpected ) ) )
        end
    end

    if shouldError and not resoult then
        throw( "Expected " .. expectedString .. " got " .. objectType )
    end

    return resoult, objectType
end


-- Функция проверяет существует ли данное значение в указанной enumeration таблице
function checkEnum( object, enum, shouldError )
    checkType( object, "number" )
    checkType( enum, "string" )
    checkType( shouldError, { "boolean", "nil" } )

    shouldError = shouldError == nil and true or shouldError

    local enumTable = _G[ enum ]

    if not enumTable then
        if not shouldError then
            return false
        end

        throw( "Enumerations with the specified name (" .. enum .. ") was not found" )
    end

    for _, value in pairs( enumTable ) do
        if value == object then
            return true
        end
    end

    if not shouldError then
        return false
    end

    throw( "The specified value (" .. object .. ") was not found in the enumeration table" )
end


-- Создает таблицу rgba
table.rgba = function( r, g, b, a )
    checkType( r, { "nil", "number" } )
    checkType( g, { "nil", "number" } )
    checkType( b, { "nil", "number" } )
    checkType( a, { "nil", "number" } )

    return { r = r or 0, g = g or 0, b = b or 0, a = a or 0 }
end


-- Улучшенный мульти-принт
function printm( ... )
    local res = ""

    for _, tx in pairs( { ... } ) do
        res = res .. tx .. " ; "
    end

    print( res )
end


-- Функция возвращает 'true', если данный ввод является wgui
function iswgui( object )
    return type( object ) == "wgui"
end


-- onScreenSizeChanged hook ( https://wiki.facepunch.com/gmod/GM:OnScreenSizeChanged )
local hookscrw, hookscrh = render.getGameResolution()

local z = timer.create( "hook:onScreenSizeChanged", 10, 0, function()
    local w, h = render.getGameResolution()

    if hookscrw ~= w or hookscrh ~= h then
        hookscrw = w
        hookscrh = h

        hook.run( "onScreenSizeChanged", w, h )
    end
end )


-- Мини-библиотека генерирующая uid'шники
uidlib = { list = {}, chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" }

uidlib.generate = function( length )
    checkType( length, { "nil", "number" } )
    length = length or 8

    local uid = ""

    for char = 1, length do
        uid = uid .. uidlib.chars[ math.random( 1, #uidlib.chars ) ]
    end

    if uidlib.list[ uid ] then
        uid = uidlib.generate( length )
    end

    uidlib.list[ uid ] = true

    return uid
end

uidlib.variants = function( length )
    checkType( length, { "nil", "number" } )
    length = length or 8

    return ( #uidlib.chars ) ^ length
end
