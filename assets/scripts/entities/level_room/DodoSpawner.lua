
persistenceMode(TEMPLATE | ARGS, {"Transform"})

masks = include("scripts/entities/level_room/_masks")

function create(spawner)
    setName(spawner, "spawner")
    component.Transform.getFor(spawner)
    setComponents(spawner, {
        GhostBody {
            collider = Collider {
                collisionCategoryBits = masks.SENSOR,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.DYNAMIC_PROPS,
            }
        },
        SphereColliderShape {
            radius = 0.5
        },
    })

    local dodo = createEntity()
    applyTemplate(dodo, "Dodo")
    component.Transform.getFor(dodo).position = component.Transform.getFor(spawner).position
end

