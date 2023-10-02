
defaultArgs({
    force = 1,
    hitDistance = 1
})

function create(enemy, args)

    local enemyUpdate = nil
    enemyUpdate = function(deltaTime)
        if _G.player == nil or not valid(_G.player) or not component.CharacterMovement.has(_G.player) then
            return
        end
        local enemyTransform = component.Transform.getFor(enemy)
        local playerTransform = component.Transform.getFor(_G.player)

        local posDiff = playerTransform.position - enemyTransform.position
        local posDiff2d = vec3(posDiff.x, 0, posDiff.z)
        local distance = posDiff:length()
        local distance2d = posDiff2d:length()
        if _G.timeSincePlayerHit > 2 then

            local playerMovement = component.CharacterMovement.getFor(player)
            local playerBody = component.RigidBody.getFor(player):dirty()
            local playerOnGround = playerMovement.onGround

            if distance2d < args.hitDistance and distance > 0.01 and playerOnGround then

                _G.timeSincePlayerHit = 0
                _G.playerGravity = vec3(playerBody.gravity.x, playerBody.gravity.y, playerBody.gravity.z)
                playerBody.gravity = vec3(posDiff.x / distance,
                        posDiff.y / distance,
                        posDiff.z / distance) * vec3(30) + vec3(0, 50, 0)

                setComponents(createEntity(), {
                    DespawnAfter {
                        time = 3
                    },
                    SoundSpeaker {
                        sound = "sounds/voicelines/boy_hurt_"..math.random(1,2),
                        volume = .7,
                        pitch = 1.2
                    },
                })

                if playerMovement.walkSpeed > 0 then
                    _G.playerWalkSpeed = playerMovement.walkSpeed
                    _G.playerJumpForce = playerMovement.jumpForce
                    playerMovement.walkSpeed = 0
                    playerMovement.jumpForce = 0
                    component.RigidBody.animate(_G.player, "gravity", _G.playerGravity, 0.7 * args.force, "pow2Out", function()
                        if _G.player == nil or not valid(_G.player) or not component.CharacterMovement.has(_G.player) then
                            return
                        end
                        component.CharacterMovement.getFor(player).walkSpeed = _G.playerWalkSpeed
                        component.CharacterMovement.getFor(player).jumpForce = _G.playerJumpForce
                    end)
                end

                local cam = getByName("3rd_person_camera")
                if valid(cam) and component.ThirdPersonFollowing.has(cam) then
                    component.Transform.animate(cam, "position", component.Transform.getFor(cam).position + posDiff * vec3(10 / args.hitDistance), 1.0, "pow2Out")
                end
            end
        end
        setTimeout(enemy, 0.05, enemyUpdate)
    end

    setTimeout(enemy, 0.05, enemyUpdate)

end
