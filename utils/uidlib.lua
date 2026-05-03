--@name wgui/u/uidlib


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
