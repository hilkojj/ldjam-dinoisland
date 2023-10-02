
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/dino.glb", false)
loadModels("assets/models/nest.glb", false)
loadModels("assets/models/meal_bar.glb", false)

persistenceMode(TEMPLATE | ARGS, {"Transform"})

defaultArgs({
    lastOne = false,
    dinoColorAr = 0.7,
    dinoColorAg = 0.2,
    dinoColorAb = 1,
    dinoColorBr = 0.7,
    dinoColorBg = 0,
    dinoColorBb = 0.3
})

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function create(dino, args)
    setName(dino, "dino")

    component.Transform.getFor(dino)
    if _G.titleScreen or _G.cutScene then
        component.Transform.getFor(dino).scale = vec3(3)
        setTimeout(dino, randomFloat(1, 5), function()
            component.LookAt.getFor(dino).entity = getByName("cine_cam")
        end)
    else
        component.Transform.getFor(dino).scale = vec3(1)
    end
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
            uniformsVec3 = {dinoColorA = vec3(args.dinoColorAr, args.dinoColorAg, args.dinoColorAb), dinoColorB = vec3(args.dinoColorBr, args.dinoColorBg, args.dinoColorBb)}
        },
        ShadowCaster(),
        RigidBody {
            mass = 0,
            collider = Collider {
                bounciness = 0,
                frictionCoefficent = .0,
                collisionCategoryBits = masks.STATIC_TERRAIN,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER | masks.PLAYER,
                registerCollisions = true
            }
        }
    })
    local function addCollider()
        setComponents(dino, {
            CapsuleColliderShape {
                sphereRadius = hitDistance - 1.8,
                sphereDistance = 8
            }
        })
    end
    addCollider()

    local nest = createChild(dino, "nest")
    setComponents(nest, {
        Transform {},
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

    local numEggs = 4
    if args.lastOne then
        numEggs = 1
    end
    for i = 1,numEggs do
        local egg = createChild(dino, "egg"..i)
        applyTemplate(egg, "Egg")
        component.TransformChild.getFor(egg).parentEntity = dino
        component.CustomShader.getFor(egg):dirty().uniformsVec3["dinoColorB"] = vec3(args.dinoColorAr, args.dinoColorAg, args.dinoColorAb)
    end

    local function resetAnims()
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
    end

    local enemyArgs = { force = 2.2, hitDistance = hitDistance }
    local meals = {}

    applyTemplate(dino, "Enemy", enemyArgs);

    local prevAlarmed = false
    local timeSinceAlarmed = 0
    local timeSinceNotAlarmed = 0
    local attacking = false
    local mealTime = 0
    local mealBar = nil
    local timePerMeal = 8
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

        local alarmed = distance < 24 and mealTime <= 0

        if mealTime > 0 then
            mealTime = mealTime - deltaTime
            component.Transform.getFor(mealBar).scale.x = (mealTime + (#meals - 1) * timePerMeal) * 0.1
            if mealTime <= 0 then
                if valid(meals[1]) then
                    component.DespawnAfter.getFor(meals[1]).time = 0
                end
                table.remove(meals, 1)
                if #meals == 0 then
                    resetAnims()
                    addCollider()
                    enemyArgs.hitDistance = hitDistance
                    if valid(mealBar) then
                        component.DespawnAfter.getFor(mealBar).time = 0
                    end
                else
                    component.LookAt.getFor(dino).entity = meals[1]
                    mealTime = timePerMeal
                end
            end
        end

        if alarmed then
            timeSinceAlarmed = timeSinceAlarmed + deltaTime
            if alarmed ~= prevAlarmed then
                timeSinceAlarmed = 0
            end
            if #component.Rigged.getFor(dino).playingAnimations == 2 then
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
                _G.timesHitByDino = _G.timesHitByDino + 1
                setTimeout(dino, 3, function()
                    attacking = false
                    if _G.mealsToThrow > 0 and _G.timesHitByDino % 2 == 1 then
                        setComponents(createEntity(), {
                            DespawnAfter {
                                time = 10
                            },
                            SoundSpeaker {
                                sound = "sounds/voicelines/professor_bird_tip",
                                volume = 0.8
                            },
                        })
                    elseif math.random() > 0.2 then
                        setComponents(createEntity(), {
                            DespawnAfter {
                                time = 10
                            },
                            SoundSpeaker {
                                sound = "sounds/voicelines/professor_reaction_5",
                                volume = 0.8
                            },
                        })
                    end
                end)
                onEntityEvent(dino, "AnimationFinished", function(anim, unsub)
                    resetAnims()
                    unsub()
                end)
                setComponents(createEntity(), {
                    DespawnAfter {
                        time = 3
                    },
                    SoundSpeaker {
                        sound = "sounds/growl",
                        volume = 0.8
                    },

                })
            end

        else
            -- not alarmed
            if alarmed ~= prevAlarmed then
                timeSinceNotAlarmed = 0
            end
            timeSinceNotAlarmed = timeSinceNotAlarmed + deltaTime

            if #component.Rigged.getFor(dino).playingAnimations == 2 then
                component.Rigged.getFor(dino).playingAnimations[1].influence = math.min(1.0, timeSinceNotAlarmed)
                component.Rigged.getFor(dino).playingAnimations[2].influence = math.max(0.0, 1.0 - timeSinceNotAlarmed)
            end
            if component.LookAt.has(dino) and component.LookAt.getFor(dino).entity == _G.player then
                component.LookAt.remove(dino)
            end
        end

        prevAlarmed = alarmed
    end)

    local mealSensor = createChild(dino, "meal_sensor")
    setComponents(mealSensor, {
        Transform {

        },
        TransformChild {
            parentEntity = dino,
            rotation = false
        },
        GhostBody {
            collider = Collider {
                collisionCategoryBits = masks.SENSOR,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = hitDistance + 4
        }
    })

    if currentRoom.dinoMealStarters == nil then
        currentRoom.dinoMealStarters = {}
    end
    currentRoom.dinoMealStarters[dino] = function(meal)
        local prevMealTime = mealTime
        meals[#meals + 1] = meal

        if prevMealTime <= 0 then
            mealTime = timePerMeal
            component.LookAt.getFor(dino).entity = meal

            component.Rigged.getFor(dino).playingAnimations = {
                PlayAnimation {
                    name = "Eating",
                    influence = 1,
                    loop = true
                }
            }
            component.CapsuleColliderShape.remove(dino)
            enemyArgs.hitDistance = 0

            mealBar = createChild(dino, "meal_bar")
            setComponents(mealBar, {
                Transform {
                    position = component.Transform.getFor(meal).position + vec3(0, 3.5, 0),
                    scale = vec3(0, 1, 1)
                },
                LookAt {
                    entity = getByName("3rd_person_camera")
                },
                RenderModel {
                    modelName = "MealBar"
                }
            })
        end
    end
end

