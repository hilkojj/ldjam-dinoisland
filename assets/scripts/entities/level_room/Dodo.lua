
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/dodo.glb", false)

function create(dodo)
    setName(dodo, "dodo")

    setComponents(dodo, {
        Transform {
            position = vec3(0, 100, 0)
        },
        RenderModel {
            modelName = "Dodo",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Walking",
                    influence = 1,
                    loop = true
                }
            }
        },
        ShadowCaster(),
        RigidBody {
            gravity = vec3(0, -30, 0),
            mass = 1,
            linearDamping = .1,
            angularAxisFactor = vec3(0),
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .3,
                collisionCategoryBits = masks.DYNAMIC_CHARACTER,
                collideWithMaskBits = masks.STATIC_TERRAIN | masks.SENSOR,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 0.8
        },
        CharacterMovement {
            walkSpeed = 18
        }
    })

    local prevAlarmed = false
    local timeSinceAlarmed = 0.0
    local playerGravity = vec3(0)
    local playerWalkSpeed = 0
    local playerJumpForce = 0
    local timeSincePlayerHit = 0
    local dodoHit = false
    local prevYDiff = -9999
    setUpdateFunction(dodo, 0.05, function(deltaTime)
        if _G.player == nil or not valid(_G.player) or not component.CharacterMovement.has(_G.player) then
            return
        end
        local dodoTransform = component.Transform.getFor(dodo)
        local playerTransform = component.Transform.getFor(_G.player)

        local posDiff = playerTransform.position - dodoTransform.position
        local posDiff2d = vec3(posDiff.x, 0, posDiff.z)
        local distance = posDiff:length()
        local distance2d = posDiff2d:length()

        timeSincePlayerHit = timeSincePlayerHit + deltaTime

        if not dodoHit and prevYDiff > posDiff.y and posDiff.y > 1 and posDiff.y < 2 and distance2d < 2 then
            dodoHit = true
            component.Rigged.getFor(dodo).playingAnimations[1].timeMultiplier = 0
            component.Transform.animate(dodo, "scale", vec3(1, 0.1, 1), 0.2, "pow2Out", function()
                component.DespawnAfter.getFor(dodo).time = 1.0
            end)
            component.SphereColliderShape.getFor(dodo):dirty().radius = 0.1
        end

        local alarmed = distance < 10 and not dodoHit

        if alarmed and timeSincePlayerHit > 2 then
            timeSinceAlarmed = timeSinceAlarmed + deltaTime
            if prevAlarmed ~= alarmed then
                timeSinceAlarmed = 0.0
                component.Rigged.getFor(dodo).playingAnimations = {
                    PlayAnimation {
                        name = "Alarmed",
                        influence = 1,
                        loop = false
                    }
                }
            end

            local playerMovement = component.CharacterMovement.getFor(player)
            local playerBody = component.RigidBody.getFor(player):dirty()
            local playerOnGround = playerMovement.onGround

            if distance2d < 1 and distance > 0.01 and playerOnGround then
                timeSincePlayerHit = 0
                playerGravity = vec3(playerBody.gravity.x, playerBody.gravity.y, playerBody.gravity.z)
                playerBody.gravity = vec3(posDiff.x / distance,
                    posDiff.y / distance,
                    posDiff.z / distance) * vec3(30) + vec3(0, 50, 0)

                if playerMovement.walkSpeed > 0 then
                    playerWalkSpeed = playerMovement.walkSpeed
                    playerJumpForce = playerMovement.jumpForce
                    playerMovement.walkSpeed = 0
                    playerMovement.jumpForce = 0
                    component.RigidBody.animate(_G.player, "gravity", playerGravity, 0.7, "pow2Out", function()
                        if _G.player == nil or not valid(_G.player) or not component.CharacterMovement.has(_G.player) then
                            return
                        end
                        component.CharacterMovement.getFor(player).walkSpeed = playerWalkSpeed
                        component.CharacterMovement.getFor(player).jumpForce = playerJumpForce
                    end)
                end

                local cam = getByName("3rd_person_camera")
                if valid(cam) and component.ThirdPersonFollowing.has(cam) then
                    component.Transform.animate(cam, "position", component.Transform.getFor(cam).position + posDiff * vec3(10), 1.0, "pow2Out")
                end
            end

            if timeSinceAlarmed > 0.5 then
                if playerOnGround or distance2d < 2 then
                    component.CharacterMovement.getFor(dodo).walkDirInput.y = 0.5
                else
                    component.CharacterMovement.getFor(dodo).walkDirInput.y = 1
                end
            else
                component.CharacterMovement.getFor(dodo).walkDirInput.y = 0
            end
            component.LookAt.getFor(dodo).entity = _G.player
            component.LookAt.getFor(dodo).speed = 100
        else
            component.CharacterMovement.getFor(dodo).walkDirInput.y = 0
            component.LookAt.remove(dodo)
        end
        prevAlarmed = alarmed
        prevYDiff = posDiff.y
    end)

    onEntityEvent(dodo, "AnimationFinished", function(anim, unsub)
        component.Rigged.getFor(dodo).playingAnimations = {
            PlayAnimation {
                name = "Walking",
                influence = 1,
                loop = true
            }
        }
    end)

    applyTemplate(dodo, "Enemy")
end

