
persistenceMode(TEMPLATE | ARGS, {"Transform"})

loadModels("assets/models/palmtree.glb", false)

masks = include("scripts/entities/level_room/_masks")

local instancer = nil
local i = 0

function create(palmtree)i = i + 1
    setName(palmtree, "palmtree"..i)

    if instancer == nil then

        instancer = createEntity()
        setName(instancer, "tree instancer")

        setComponents(instancer, {
            InstancedRendering {
            },
            RenderModel {
                modelName = "palmtree"
            },
            ShadowCaster(),
            Transform()
        })

    end

    component.Transform.getFor(palmtree)
    component.InstancedRendering.getFor(instancer):dirty().transformEntities:add(palmtree)

    setComponents(palmtree, {
        RigidBody {
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
        }
    })
end

