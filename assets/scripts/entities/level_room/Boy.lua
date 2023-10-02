
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/cubeman.glb", false)
loadRiggedModels("assets/models/boy.glb", false)
loadModels("assets/models/arrow.glb", false)
loadColliderMeshes("assets/models/test_convex_colliders.obj", true)
loadColliderMeshes("assets/models/test_concave_colliders.obj", false)

_G.eggThrowMaxDistance = 52

function create(player)

    setName(player, "player")
    -- for enemies:
    _G.playerGravity = vec3(0)
    _G.playerWalkSpeed = 0
    _G.playerJumpForce = 0

    _G.player = player
    _G.timeSincePlayerHit = 0
    _G.holdingEgg = false
    _G.canThrowEgg = false
    _G.holdingEggEntity = nil
    _G.mealsToThrow = 0
    _G.featherScore = 0
    _G.timesHitByDino = 0
    _G.dodosKilled = 0
    _G.diedByLava = false
    _G.died = false
    _G.killPlayer = function()
        _G.died = true
        _G.timesDied = _G.timesDied + 1
        local sound = "sounds/voicelines/boy_drowning_"..math.random(1,4)
        if _G.diedByLava then
            sound = "sounds/voicelines/boy_hurt_1"
        end
        setComponents(createEntity(), {
            DespawnAfter {
                time = 5
            },
            SoundSpeaker {
                sound = sound,
                volume = .5,
                pitch = 1.2
            },
        })

        setTimeout(player, 1.9, function()
            local cam = getByName("3rd_person_camera")
            local prof = getByName("prof")
            if valid(cam) and valid(prof) then
                component.ThirdPersonFollowing.getFor(cam).target = prof
                component.ThirdPersonFollowing.getFor(cam).backwardsDistance = -10

                component.Rigged.getFor(prof).playingAnimations = {
                    PlayAnimation {
                        name = "GameOver",
                        influence = 1,
                        loop = true
                    }
                }
            end
            setComponents(createEntity(), {
                DespawnAfter {
                    time = 10
                },
                SoundSpeaker {
                    sound = "sounds/voicelines/professor_game_over_2",
                    volume = .8
                },
            })
            _G.showGameOverPopup()
        end)
        setUpdateFunction(player, 0, nil)
        component.RigidBody.remove(player)
        component.CharacterMovement.remove(player)
    end

    local prof = createEntity()
    applyTemplate(prof, "Professor")

    listenToKey(player, gameSettings.keyInput.flyCamera, "fly_cam_key")
    onEntityEvent(player, "fly_cam_key_pressed", function()
        local cam = getByName("3rd_person_camera")
        if valid(cam) then
            component.ThirdPersonFollowing.remove(cam)
        end
    end)

    setComponents(player, {
        Transform {
            position = vec3(-70, 20, 60)
        },
        RenderModel {
            modelName = "Boy",
            visibilityMask = masks.PLAYER
        },
        --[[
        CustomShader {
            vertexShaderPath = "shaders/default.vert",
            fragmentShaderPath = "shaders/default.frag",
            defines = {TEST = "1"}
        },]]--
        Rigged {
            playingAnimations = {

            }
        },
        ShadowCaster(),
        RigidBody {
            allowSleep = false,
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
            radius = 1
        },
        --[[
        GravityFieldAffected {
            gravityScale = 30,
            defaultGravity = vec3(0, -30, 0)
        },]]--
        CharacterMovement {
            inputInCameraSpace = true,
            walkSpeed = 16
        }
        --Inspecting()
    })
    component.RigidBody.getFor(player):dirty().allowSleep = false

    --component.Transform.getFor(player).position = vec3(40, 111, -56)

    local arrow = createChild(player, "arrow")
    setComponents(arrow, {
        Transform(),
        TransformChild {
            parentEntity = player,
            offset = Transform {
                position = vec3(0, 3.5, 0)
            },
            rotation = false,
            offsetInWorldSpace = true
        },
        LookAt {
            entity = prof
        }
    })

    local dropShadowSun = createChild(player, "drop shadow sun")
    setComponents(dropShadowSun, {
        Transform(),
		TransformChild {
			parentEntity = player,
            offset = Transform {
                position = vec3(0, 2.5, 0)
            }
		},
        DirectionalLight {
            color = vec3(-1.0)
        },
        ShadowRenderer {
            visibilityMask = masks.PLAYER,
            resolution = ivec2(32),
            frustrumSize = vec2(2),
            farClipPlane = 16
        }
    })

    -- TODO: enable to play music
    -- setComponents(createEntity(), {
    --     SoundSpeaker {
    --         sound = "sounds/background_music",
    --         volume = 0.8,
    --         looping = true,
    --     },
    -- })

    local cam = getByName("3rd_person_camera")
    if valid(cam) then
        setComponents(cam, {
            ThirdPersonFollowing {
                target = player,
                visibilityRayMask = masks.STATIC_TERRAIN
            }
        })
    end

    local sun = getByName("sun")
    if valid(sun) then
        local sunRot = quat:new()
        sunRot.x = 40
        sunRot.y = -21
        sunRot.z = 0

        setComponents(sun, {
            TransformChild {
                parentEntity = player,
                offsetInWorldSpace = true,
                position = true,
                rotation = false,
                scale = false,
                offset = Transform {
                    position = vec3(-97, 345, 282),
                    rotation = sunRot
                }
            }
        })
    end

    local timeSinceLanding = 0

    onEntityEvent(player, "Collision", function (col)

        if col.otherCategoryBits & masks.STATIC_TERRAIN ~= 0 and col.impact > 10 then
            -- hit floor

            if getTime() - timeSinceLanding > .1 then

                setComponents(createEntity(), {

                    DespawnAfter {
                        time = 3
                    },
                    SoundSpeaker {
                        sound = "sounds/landing",
                        volume = .2,
                        pitch = 1.2
                    },

                })

                timeSinceLanding = getTime()

            end
        end
    end)

    _G.eggCounter = 0
    local eggOffsets = {
        vec3(3, 1, 0),
        vec3(3.9, 0.8, 0),
        vec3(2.1, 0.9, 0),

        vec3(3, 1, 1),
        vec3(3.9, 0.8, 1),
        --vec3(2.1, 0.9, 1),

        vec3(3, 1, -1),
        --vec3(3.9, 0.8, -1),
        vec3(2.1, 0.9, -1),

        vec3(2.5, 1.8, -0.5),
        --vec3(3.5, 1.8, -0.5),

        --vec3(2.5, 1.8, 0.5),
        vec3(3.5, 1.8, 0.5),

        vec3(3, 2.6, 0),
    }

    listenToKey(player, gameSettings.keyInput.meal, "meal_key")
    onEntityEvent(player, "meal_key_pressed", function()

        --[[
        local spawner = createEntity()
        applyTemplate(spawner, "DodoSpawner", true)
        component.Transform.getFor(spawner).position = component.Transform.getFor(player).position + vec3(0, 2, 0)
]]--
        if _G.holdingEgg then
            local ship = getByName("ship")
            if ship ~= nil and valid(ship) and valid(_G.holdingEggEntity) then
                local shipTransform = component.Transform.getFor(ship)
                local playerTransform = component.Transform.getFor(player)

                local posDiff = playerTransform.position - shipTransform.position
                local posDiff2d = vec3(posDiff.x, 0, posDiff.z)
                local distance = posDiff:length()
                local distance2d = posDiff2d:length()

                if distance2d < _G.eggThrowMaxDistance then
                    -- throw egg
                    local egg = _G.holdingEggEntity
                    local halfWayPoint = (playerTransform.position + shipTransform.position) * vec3(0.5) + vec3(0, 12, 0)
                    local shipEndPoint = vec3(shipTransform.position.x, shipTransform.position.y, shipTransform.position.z)
                    -- set speed of boat to 0.
                    _G.holdingEgg = false
                    _G.holdingEggEntity = nil
                    component.RenderModel.remove(arrow)
                    local rigged = component.Rigged.getFor(player)
                    if rigged.playingAnimations[#rigged.playingAnimations].name == "HandsUp" then
                        rigged.playingAnimations[#rigged.playingAnimations].influence = 0
                    end
                    setComponents(createEntity(), {
                        DespawnAfter {
                            time = 10
                        },
                        SoundSpeaker {
                            sound = "sounds/voicelines/professor_reaction_egg_"..math.random(1,3),
                            volume = .5
                        },
                    })
                    component.TransformChild.remove(egg)
                    component.Transform.animate(egg, "position", halfWayPoint, 0.8, "pow2In", function()
                        component.Transform.animate(egg, "position", shipEndPoint, 0.8, "pow2Out", function()
                            _G.eggCounter = _G.eggCounter + 1
                            if _G.eggCounter > #eggOffsets then
                                component.DespawnAfter.getFor(egg).time = 0
                            else
                                component.TransformChild.getFor(egg).parentEntity = ship
                                component.TransformChild.getFor(egg).offset.position = eggOffsets[_G.eggCounter]
                            end
                            if egg == _G.lastEgg then
                                setTimeout(player, 1.2, _G.onLastEgg)
                            end
                        end)
                    end)
                end
            end

            return
        end
        if _G.mealsToThrow <= 0 then
            return
        end
        local meal = createEntity()
        applyTemplate(meal, "Meal")
        component.Transform.getFor(meal).position = component.Transform.getFor(player).position
        component.Transform.getFor(meal).rotation = component.Transform.getFor(player).rotation
        _G.mealsToThrow = _G.mealsToThrow - 1
    end)

    local timeSinceLastJump = 0
    local prevAlpha = 0
    local prevOnGround = false
    setUpdateFunction(player, 0, function(deltaTime)
        _G.timeSincePlayerHit = _G.timeSincePlayerHit + deltaTime
        timeSinceLastJump = timeSinceLastJump + deltaTime


        local rigged = component.Rigged.getFor(player)
        local movement = component.CharacterMovement.getFor(player)
        local transform = component.Transform.getFor(player)

        if transform.position.y < _G.seaHeight - 1 then
            _G.killPlayer()
            return
        end

        if movement.onGround then
            if prevOnGround ~= movement.onGround then
                rigged.playingAnimations = {
                    PlayAnimation {
                        name = "Idle2",
                        influence = 1,
                        loop = true
                    },
                    PlayAnimation {
                        name = "Walking",
                        influence = 0,
                        loop = true
                    }
                }
            end
            local newAlpha = math.min(1.0, math.abs(movement.walkDirInput.y) + math.abs(movement.walkDirInput.x) * 0.5)
            local blendedAlpha = newAlpha

            if newAlpha < prevAlpha then
                local timeAlpha = math.min(1.0, deltaTime * 8.0)
                blendedAlpha = newAlpha * timeAlpha + prevAlpha * (1.0 - timeAlpha)
            end

            rigged.playingAnimations[1].influence = 1.0 - blendedAlpha
            rigged.playingAnimations[2].influence = blendedAlpha

            prevAlpha = blendedAlpha
        else
            -- in air
            if prevOnGround ~= movement.onGround then
                rigged.playingAnimations = {
                    PlayAnimation {
                        name = "Jump",
                        influence = 1,
                        loop = false
                    }
                }
            end

        end
        if _G.holdingEgg then
            if rigged.playingAnimations[#rigged.playingAnimations].name ~= "HandsUp" then
                rigged.playingAnimations[#rigged.playingAnimations + 1] = PlayAnimation {
                    name = "HandsUp",
                    influence = 1,
                    loop = true
                }
            end
            local eggRigged = component.Rigged.getFor(_G.holdingEggEntity)
            eggRigged.playingAnimations[2].influence = math.abs(movement.walkDirInput.y)
            component.RenderModel.getFor(arrow).modelName = "Arrow"
        end
        prevOnGround = movement.onGround
        
    end)


    listenToKey(player, gameSettings.keyInput.jump, "jump_key")
    onEntityEvent(player, "jump_key_pressed", function()
        if timeSinceLastJump > 3.0 then
            timeSinceLastJump = 0
            setComponents(createEntity(), {
                DespawnAfter {
                    time = 3
                },
                SoundSpeaker {
                    sound = "sounds/voicelines/boy_happy_"..math.random(1,6),
                    volume = .5,
                    pitch = 1.2
                },
            })
        end
    end)
end

