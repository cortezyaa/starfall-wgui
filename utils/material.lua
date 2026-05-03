--@name wgui/u/material


-- Небольшое расширение material библиотеки
material.bank = convar.getInt( "sf_render_usermaterials_max_cl" )
material.cache = { temp = {}, const = {} }

material.old_create = material.create
material.create = function( shader, const )
    if ( #material.cache.temp + #material.cache.const ) >= material.bank then
        if material.cache.temp[ 1 ] then
            material.cache.temp[ 1 ]:destroy()
        else
            return nil
        end
    end

    local mat = material.old_create( shader )
    mat.const = const

    mat.old_destroy = mat.destroy
    mat.destroy = function( self )
        table.removeByValue( material.cache[ ( self.const and "const" or "temp" ) ], self )
        return mat:old_destroy()
    end

    table.insert( material.cache[ ( mat.const and "const" or "temp" ) ], mat )

    return mat
end
