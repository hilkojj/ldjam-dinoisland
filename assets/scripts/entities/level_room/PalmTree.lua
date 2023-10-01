
persistenceMode(TEMPLATE | ARGS, {"Transform"})

loadModels("assets/models/palmtree.glb", false)

masks = include("scripts/entities/level_room/_masks")

function create(palmtree)
    setName(palmtree, "palmtree")

    component.Transform.getFor(palmtree)

    setComponents(palmtree, {
        RenderModel {
            modelName = "palmtree",
            visibilityMask = masks.NON_PLAYER
        },
        ShadowCaster(),
        RigidBody {

        },
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

