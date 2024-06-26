--@name wgui/u/utils
--@author cortez

-- Перезапись некоторых дефолных функций
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

-- Функция сравнивает тип объекта с ожидаемым(и)
-- Стандартно вызывает ошибку при их несоответствии
-- Возвращает результат и тип объекта
function checkType( object, expected, shouldError )
    shouldError = shouldError == nil and true or shouldError
 
    local objectType = type( object )
    local expectedType = type( expected )
    local shouldErrorType = type( shouldError )

    if expectedType ~= "string" and expectedType ~= "table" then
        error( "Expected string or table got " .. expectedType )
    end

    if shouldErrorType ~= "boolean" then
        error( "Expected boolean got " .. shouldErrorType )
    end

    local resoult = false
    local estring = ""

    if expectedType == "string" then
        resoult = objectType == expected
        estring = expected
    else
        local lexpected = table.count( expected )
        for index, exp in pairs( expected ) do
            estring = estring .. ( index == 1 and "" or ( index == lexpected and " or " or ", " ) ) .. exp

            if exp == objectType then
                resoult = true
            end
        end
    end

    if shouldError and not resoult then
        error( "Expected " .. estring .. " got " .. objectType )
    end

    return resoult, objectType
end


-- Функция проверяет наличие значения (object) в ENUM'е
-- Стандартно вызывает ошибку при его отсутствии
function checkEnum( object, enum, shouldError )
    shouldError = shouldError == nil and true or shouldError

    local objectType = type( object )
    local enumType = type( enum )
    local shouldErrorType = type( shouldError )

    if objectType ~= "number" then
        error( "Expected number got " .. objectType )
    end

    if enumType ~= "string" then
        error( "Expected string got " .. enumType )
    end
    
    if shouldErrorType ~= "boolean" then
        error( "Expected boolean got " .. shouldErrorType )
    end

    local resoult = false
    local estring = ""

    local enumTable = _G[ enum ]

    if not enumTable then
        estring = "Enum with the specified name (" .. enum .. ") was not found"
    else
        estring = "The specified value (" .. object .. ") was not found in the enum table"

        for key, value in pairs( enumTable ) do
            if value ~= object then
                continue
            end

            resoult = true
            break
        end
    end

    if shouldError and not resoult then
        error( estring )
    end

    return resoult
end
