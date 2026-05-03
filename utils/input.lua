--@name wgui/u/input


-- Небольшое расширение input библиотеки
input.lockCooldown = convar.getFloat( "sf_input_lock_cooldown" )
input.lockedControlCooldown = 0

input.old_lockControls = input.lockControls
input.lockControls = function( enable )
    if not enable then
        input.old_lockControls( false )
        return
    end

    if not input.canLockControls() then return end
    input.old_lockControls( true )

    if not input.isControlLocked() then return end
    input.lockedControlCooldown = timer.realtime()
end

local inputControlLocked = input.isControlLocked()
timer.create( "hook:onControlLockedChanged", 0.1, 0, function()
    if inputControlLocked == input.isControlLocked() then return end
    inputControlLocked = input.isControlLocked()
    hook.run( "onControlLockedChanged", inputControlLocked )
end )
