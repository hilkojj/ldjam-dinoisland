
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
        }
    })

    local function spawnDodo()
        local dodo = createChild(spawner, "spawned_dodo")
        applyTemplate(dodo, "Dodo")
        local spawnerTransform = component.Transform.getFor(spawner)
        component.Transform.getFor(dodo).position = spawnerTransform.position
        local dodoMovement = component.CharacterMovement.getFor(dodo)
        dodoMovement.walkSpeed = dodoMovement.walkSpeed * (0.8 + 0.7 * math.max(0, math.min(1, spawnerTransform.position.y / 100.0)))
    end

    if not _G.outroScreen then
        spawnDodo()
    end

    setUpdateFunction(spawner, 3, function(deltaTime)
        if _G.player == nil or not valid(_G.player) then
            return
        end
        local spawnerTransform = component.Transform.getFor(spawner)
        if _G.seaHeight > spawnerTransform.position.y then
            return
        end
        local playerTransform = component.Transform.getFor(_G.player)

        local posDiff = playerTransform.position - spawnerTransform.position
        local distance = posDiff:length()
        local spawnedDodo = getChild(spawner, "spawned_dodo")
        if spawnedDodo == nil and distance > 40 then
            spawnDodo()
        end
    end)
end

