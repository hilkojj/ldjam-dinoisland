
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
                }
            }
        },
        ShadowCaster(),
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

    setUpdateFunction(prof, 0.1, function()
        for i = 2, #_G.shipCheckpoints do
            local aTransform = component.Transform.getFor(_G.shipCheckpoints[i - 1])
            local bTransform = component.Transform.getFor(_G.shipCheckpoints[i])

            print(bTransform.position.y, _G.seaHeight)

            if bTransform.position.y > _G.seaHeight then

                local abYDiff = bTransform.position.y - aTransform.position.y

                local aSeaDiff = _G.seaHeight - aTransform.position.y

                local alpha = math.max(0, math.min(1, aSeaDiff / abYDiff))

                local abDiff = bTransform.position - aTransform.position

                local profTransform = component.Transform.getFor(prof)

                profTransform.position = aTransform.position + abDiff * vec3(alpha) + vec3(0, 2.3, 0)

                break
            end
        end
    end)
end

