
persistenceMode(TEMPLATE | ARGS, {"Transform"})

loadModels("assets/models/feather.glb", false)

masks = include("scripts/entities/level_room/_masks")

local instancer = nil
local i = 0

function create(feather)

    i = i + 1
    setName(feather, "feather"..i)

    if instancer == nil then

        instancer = createEntity()
        setName(instancer, "feather instancer")

        setComponents(instancer, {
		    InstancedRendering {
		    },
		    RenderModel {
                modelName = "feather"
            },
            CustomShader {
                vertexShaderPath = "shaders/default.vert",
                fragmentShaderPath = "shaders/default.frag",
                defines = {SHINY = "1", INSTANCED = "1"}
            },
            ShadowCaster(),
            Transform()
        })

    end

    setComponents(feather, {
        --RigidBody { mass = 0,
		GhostBody {
            collider = Collider {
                bounciness = 1,
                frictionCoefficent = 1,
                collisionCategoryBits = masks.SENSOR,
                collideWithMaskBits = masks.DYNAMIC_CHARACTER,
                registerCollisions = true
            }
        },
        SphereColliderShape {
            radius = 2
        },
        
	})
    component.Transform.getFor(feather)
    component.InstancedRendering.getFor(instancer):dirty().transformEntities:add(feather)


    local hit = false
    local hidden = false

    function hide(feather)
        hidden = true

        component.InstancedRendering.getFor(instancer):dirty().transformEntities:erase(feather)
        component.GhostBody.remove(feather) -- dont destroy, because that will be saved in the level
    end

    onEntityEvent(feather, "Collision", function (col)

		if col.otherEntity == _G.player and not hit and #col.contactPoints > 0 then
            hit = true
            _G.featherScore = _G.featherScore + 1

            setComponents(createEntity(), {
                DespawnAfter {
                    time = 5
                },
                SoundSpeaker {
                    sound = "sounds/feather",
                    volume = 4.0
                },
            })
            if _G.featherScore == 13 or _G.featherScore == 35 then
                setComponents(createEntity(), {
                    DespawnAfter {
                        time = 10
                    },
                    SoundSpeaker {
                        sound = "sounds/voicelines/professor_reaction_feather",
                        volume = .5
                    },
                })
            end

            local trans = component.Transform.getFor(feather)
            local originalPos = vec3(trans.position.x, trans.position.y, trans.position.z) -- TODO: jam hack, to prevent saving changed position
            local playerTrans = component.Transform.getFor(player)
            local dir = playerTrans.position - trans.position

            ----[[
            component.Transform.animate(feather, "scale", vec3(1.5), .2, "pow2In")
            -- component.Transform.animate(feather, "position", trans.position + dir * vec3(.5), .1, "pow2Out")

            setTimeout(feather, .1, function()
                component.Transform.animate(feather, "position", trans.position + dir, .3, "pow2")

                setTimeout(feather, .21, function()

                    component.Transform.animate(feather, "scale", vec3(0), .1, "pow2Out", function()
                        component.Transform.getFor(feather).position = originalPos
                        component.Transform.getFor(feather).scale = vec3(1)

                        hide(feather)
                    end)

                end)
            end)
            --]]--
            --hide(feather)

        end
	end)

end