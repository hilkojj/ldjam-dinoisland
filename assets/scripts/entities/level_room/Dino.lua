
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/dino.glb", false)
loadModels("assets/models/nest.glb", false)

persistenceMode(TEMPLATE | ARGS, {"Transform"})

function create(dino)
    setName(dino, "dino")

    component.Transform.getFor(dino)
    local hitDistance = 8.2

    setComponents(dino, {
        RenderModel {
            modelName = "Dino",
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
                    name = "Alarmed",
                    influence = 0,
                    loop = true
                }
            }
        },
        CustomShader {
            vertexShaderPath = "shaders/rigged.vert",
            fragmentShaderPath = "shaders/default.frag",
            defines = {DINO = "1"},
            uniformsVec3 = {dinoColorA = vec3(0.7, 0.2, 1), dinoColorB = vec3(0.7, 0, 0.3)}
        },
        ShadowCaster(),
        RigidBody {
            mass = 0,
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .3,
                collisionCategoryBits = masks.STATIC_TERRAIN,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.PLAYER,
                registerCollisions = true
            }
        },
        CapsuleColliderShape {
            sphereRadius = hitDistance - 1.8,
            sphereDistance = 6
        }
    })

    local nest = createChild(dino, "nest")
    setComponents(nest, {
        Transform {

        },
        TransformChild {
            parentEntity = dino,
            rotation = false
        },
        RenderModel {
            modelName = "nest",
            visibilityMask = masks.NON_PLAYER
        },
        ShadowCaster(),
    })

    local prevAlarmed = false
    local timeSinceAlarmed = 0
    local timeSinceNotAlarmed = 0
    local attacking = false
    setUpdateFunction(dino, 0.0, function(deltaTime)
        if _G.player == nil or not valid(_G.player) or not component.CharacterMovement.has(_G.player) then
            return
        end
        local dinoTransform = component.Transform.getFor(dino)
        local playerTransform = component.Transform.getFor(_G.player)

        local posDiff = playerTransform.position - dinoTransform.position
        local posDiff2d = vec3(posDiff.x, 0, posDiff.z)
        local distance = posDiff:length()
        local distance2d = posDiff2d:length()

        local alarmed = distance < 24

        if alarmed then
            timeSinceAlarmed = timeSinceAlarmed + deltaTime
            if alarmed ~= prevAlarmed then
                timeSinceAlarmed = 0
            end
            if not attacking then
                component.Rigged.getFor(dino).playingAnimations[1].influence = math.max(0.0, 1.0 - timeSinceAlarmed)
                component.Rigged.getFor(dino).playingAnimations[2].influence = math.min(1.0, timeSinceAlarmed)
                component.LookAt.getFor(dino).entity = _G.player
            end

            if distance2d < hitDistance and not attacking then
                attacking = true
                component.Rigged.getFor(dino).playingAnimations = {
                    PlayAnimation {
                        name = "Attack",
                        influence = 1,
                        loop = false
                    }
                }
                onEntityEvent(dino, "AnimationFinished", function(anim, unsub)
                    component.Rigged.getFor(dino).playingAnimations = {
                        PlayAnimation {
                            name = "Idle",
                            influence = 1,
                            loop = true
                        },
                        PlayAnimation {
                            name = "Alarmed",
                            influence = 0,
                            loop = true
                        }
                    }
                    attacking = false
                    unsub()
                end)
                setComponents(createEntity(), {
                    DespawnAfter {
                        time = 3
                    },
                    SoundSpeaker {
                        sound = "sounds/growl",
                        volume = 0.5
                    },

                })
            end

        else
            -- not alarmed
            if alarmed ~= prevAlarmed then
                timeSinceNotAlarmed = 0
            end
            timeSinceNotAlarmed = timeSinceNotAlarmed + deltaTime

            if not attacking then
                component.Rigged.getFor(dino).playingAnimations[1].influence = math.min(1.0, timeSinceNotAlarmed)
                component.Rigged.getFor(dino).playingAnimations[2].influence = math.max(0.0, 1.0 - timeSinceNotAlarmed)
            end
            component.LookAt.remove(dino)
        end

        prevAlarmed = alarmed
    end)

    applyTemplate(dino, "Enemy", { force = 2.2, hitDistance = hitDistance })
end

