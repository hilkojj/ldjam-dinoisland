
loadRiggedModels("assets/models/professor.glb", false)

masks = include("scripts/entities/level_room/_masks")

function create(prof)
    setName(prof, "prof")

    setComponents(prof, {
        Transform {

        },
        RenderModel {
            modelName = "Professor",
            visibilityMask = masks.NON_PLAYER
        },
        Rigged {
            playingAnimations = {
                PlayAnimation {
                    name = "Idle",
                    influence = 1,
                    loop = true
                },
                PlayAnimation {
                    name = "Jumping",
                    influence = 0,
                    loop = true
                }
            }
        },
        ShadowCaster(),
        LookAt {
            entity = _G.player
        },
        --[[
        RigidBody {
            gravity = vec3(0, -30, 0),
            allowSleep = false,
            mass = 1,
            angularAxisFactor = vec3(0),
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .1,
                collisionCategoryBits = masks.DYNAMIC_CHARACTER,
                collideWithMaskBits = masks.STATIC_TERRAIN | masks.SENSOR | masks.WATER,
                registerCollisions = true
            }
        },
        CapsuleColliderShape {
            sphereRadius = 1,
            sphereDistance = 2
        }]]--
    })

    local ship = createChild(prof, "ship")
    applyTemplate(ship, "Ship")
    component.TransformChild.getFor(ship).parentEntity = prof
    component.TransformChild.getFor(ship).offset.position = vec3(0, -2, 0)

    setUpdateFunction(prof, 0.05, function(deltaTime)
        local profTransform = component.Transform.getFor(prof)

        for i = 2, #_G.shipCheckpoints do
            local aTransform = component.Transform.getFor(_G.shipCheckpoints[i - 1])
            local bTransform = component.Transform.getFor(_G.shipCheckpoints[i])

            if bTransform.position.y > _G.seaHeight then

                local abYDiff = bTransform.position.y - aTransform.position.y

                local aSeaDiff = _G.seaHeight - aTransform.position.y

                local alpha = math.max(0, math.min(1, aSeaDiff / abYDiff))

                local abDiff = bTransform.position - aTransform.position


                profTransform.position = aTransform.position + abDiff * vec3(alpha) + vec3(0, 2.3, 0)

                break
            end
        end

        if _G.player == nil or not valid(_G.player) or not component.CharacterMovement.has(_G.player) then
            return
        end
        local playerTransform = component.Transform.getFor(_G.player)

        local posDiff = playerTransform.position - profTransform.position
        local posDiff2d = vec3(posDiff.x, 0, posDiff.z)
        local distance = posDiff:length()
        local distance2d = posDiff2d:length()

        local rigged = component.Rigged.getFor(prof)
        local alpha = rigged.playingAnimations[2].influence

        local mul = -1

        if distance2d < _G.eggThrowMaxDistance and _G.holdingEgg then
            mul = 1
        end

        alpha = math.max(0, math.min(1, alpha + deltaTime * mul * 5))

        rigged.playingAnimations[1].influence = 1 - alpha
        rigged.playingAnimations[2].influence = alpha
    end)
end

