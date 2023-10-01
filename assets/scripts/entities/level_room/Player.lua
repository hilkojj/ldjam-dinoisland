
masks = include("scripts/entities/level_room/_masks")

loadRiggedModels("assets/models/cubeman.glb", false)
loadRiggedModels("assets/models/boy.glb", false)
loadColliderMeshes("assets/models/test_convex_colliders.obj", true)
loadColliderMeshes("assets/models/test_concave_colliders.obj", false)

function create(player)
    setName(player, "player")
    _G.player = player
    _G.timeSincePlayerHit = 0

    listenToKey(player, gameSettings.keyInput.flyCamera, "fly_cam_key")
    onEntityEvent(player, "fly_cam_key_pressed", function()
        local cam = getByName("3rd_person_camera")
        if valid(cam) then
            component.ThirdPersonFollowing.remove(cam)
        end
    end)

    setComponents(player, {
        Transform {
            position = vec3(0, 100, 0)
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

    --[[
    onEntityEvent(player, "AnimationFinished", function(anim, unsub)
        print(anim.name.." has finished playing! Play it one more time but with less influence..")
        local anim = component.Rigged.getFor(player).playingAnimations[1]
        anim.loop = false
        anim.influence = .5
        unsub()

        component.Rigged.getFor(player).playingAnimations:add(PlayAnimation {
            name = "headanim",
            influence = 1.
        })
        component.RigidBody.getFor(player):dirty().gravity = vec3(0, -10, 0)
    end)]]--

    listenToGamepadButton(player, 0, gameSettings.gamepadInput.test, "test")
    onEntityEvent(player, "test_pressed", function()
        print("epic")
    end)

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
                        volume = .1,
                        pitch = 1.2
                    },

                })

                timeSinceLanding = getTime()

            end


        end
    end)

    listenToKey(player, gameSettings.keyInput.meal, "meal_key")
    onEntityEvent(player, "meal_key_pressed", function()
        local meal = createEntity()
        applyTemplate(meal, "Meal")
        component.Transform.getFor(meal).position = component.Transform.getFor(player).position
        component.Transform.getFor(meal).rotation = component.Transform.getFor(player).rotation
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

        if transform.position.y < 0 then
            _G.queueRestartLevel = true
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

