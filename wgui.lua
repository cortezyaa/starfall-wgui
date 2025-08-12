--@name wgui
--@author cortez

--@includedir ./utils/
--@includedir ./elements/


-- Включение утилит
requiredir( "./utils/" ) 



-- Создание таблиц библиотеки
wgui = {}
wgui.__data = {}
wgui.__data.registred = {}


-- Функция создания элемента
wgui.create = function( elementName, parent )
    checkType( elementName, "string" )
    local _, parentType = checkType( parent, { "wgui", "number" } )

    if not wgui.isRegister( elementName ) then
        throw( "Specified element is not registred" )
    end

    local element = wgui.__data.registred[ elementName ]:new()

    if parentType == "number" then
        if parent == RENDERSPACE.HUD then
            -- hud
        elseif parent == RENDERSPACE.SCREEN then
            -- screen
        end
    else
        if parent.__data.rs then
            -- parent to render space
        else
            -- parent to element
        end
    end

    return element
end


-- Функция проверки зарегестрирован элемент или нет
wgui.isRegister = function( elementName )
    checkType( elementName, "string" )
    return not not wgui.__data.registred[ elementName ]
end


-- Функиця регистрации элемента
wgui.register = function( elementName, elementClass )
    checkType( elementName, "string" )
    checkType( elementClass, "table" )

    wgui.__data.registred[ elementName ] = elementClass
end







-- Регистрация элементов
local function registerIncludedElements()
    for _, elementClass in pairs( requiredir( "./elements/" ) ) do
        local elementName = elementClass.static.elementName
        wgui.register( elementName, elementClass )
    end
end

registerInludedElements()






return wgui
