--@name wgui/u/utils


-- Перезапись некоторых функции
local old_type = type
function type( object )
    local resoult = old_type( object )

    if resoult == "table" and object.__wgui then
        return "wgui"
    end

    return resoult
end

local old_isValid = isValid
function isValid( object )
    if object.__wgui then
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


