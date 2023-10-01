
persistenceMode(TEMPLATE | ARGS, {"Transform"})

masks = include("scripts/entities/level_room/_masks")

defaultArgs({
    i = 1
})

_G.shipCheckpoints = {}

function create(checkpoint, args)
    setName(checkpoint, "checkpoint"..args.i)
    _G.shipCheckpoints[args.i] = checkpoint
    component.Transform.getFor(checkpoint)
    setComponents(checkpoint, {
        GhostBody {
            collider = Collider {
                collisionCategoryBits = masks.SENSOR,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.DYNAMIC_PROPS,
            }
        },
        SphereColliderShape {
            radius = 0.5
        }
    })

end


