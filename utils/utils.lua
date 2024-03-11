--@name wgui/u/utils
--@author cortez

-- Overwrite functions
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

-- Function for checking the type of an object returning a boolean value or error
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
