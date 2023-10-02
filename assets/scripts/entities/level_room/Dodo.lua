
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/dodo.glb", false)

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

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
    local enemyArgs = { force = 1.75, hitDistance = 1 }

    local prevAlarmed = false
    local timeSinceAlarmed = 0.0
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

        if not dodoHit and prevYDiff > posDiff.y and posDiff.y > 1 and posDiff.y < 2 and distance2d < 2 then
            dodoHit = true
            _G.dodosKilled = _G.dodosKilled + 1
            if _G.dodosKilled == 1 then
                setComponents(createEntity(), {
                    DespawnAfter {
                        time = 10
                    },
                    SoundSpeaker {
                        sound = "sounds/voicelines/professor_reaction_bird",
                        volume = .7
                    },
                })
            end
            setComponents(createEntity(), {
                DespawnAfter {
                    time = 5
                },
                SoundSpeaker {
                    sound = "sounds/blood/long",
                    pitch = randomFloat(0.7, 1.3),
                    volume = 1.5
                },
            })
            component.Rigged.getFor(dodo).playingAnimations[1].timeMultiplier = 0
            component.Transform.animate(dodo, "scale", vec3(1, 0.1, 1), 0.1, "pow2Out", function()
                component.DespawnAfter.getFor(dodo).time = 1.0
            end)
            component.SphereColliderShape.getFor(dodo):dirty().radius = 0.1
            enemyArgs.hitDistance = 0
            _G.mealsToThrow = _G.mealsToThrow + 1
        end

        local alarmed = distance < 12 and not dodoHit

        if alarmed and _G.timeSincePlayerHit > 2 then
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
            local playerOnGround = playerMovement.onGround

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

    applyTemplate(dodo, "Enemy", enemyArgs)
end

