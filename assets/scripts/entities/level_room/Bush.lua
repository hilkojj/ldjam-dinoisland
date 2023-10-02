
persistenceMode(TEMPLATE | ARGS, {"Transform"})

loadModels("assets/models/bush.glb", false)

masks = include("scripts/entities/level_room/_masks")

local instancer = nil
local i = 0

function create(bush)
    i = i + 1
    setName(bush, "bush"..i)

    if instancer == nil then

        instancer = createEntity()
        setName(instancer, "bush instancer")

        setComponents(instancer, {
            InstancedRendering {
            },
            RenderModel {
                modelName = "bush"
            },
            ShadowCaster(),
            Transform()
        })

    end

    component.Transform.getFor(bush)
    component.InstancedRendering.getFor(instancer):dirty().transformEntities:add(bush)

    setComponents(bush, {
        --[[RigidBody {
            mass = 0,
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .0,
                collisionCategoryBits = masks.STATIC_TERRAIN,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.PLAYER,
                registerCollisions = true
            }
        },
        CapsuleColliderShape {
            sphereRadius = 0.8,
            sphereDistance = 14
        }]]--
    })
end

