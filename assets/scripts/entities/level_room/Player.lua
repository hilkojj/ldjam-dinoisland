
function create(player)

    if not _G.titleScreen and not _G.cutScene then
        applyTemplate(player, "Boy")
    elseif _G.titleScreen then
        setMainCamera(getByName("cine_cam"))
        applyTemplate(player, "Title")
    elseif _G.introScreen then
        local cam = getByName("intro_cam")
        setMainCamera(cam)
        setComponents(cam, {
            SoundSpeaker {
                sound = "sounds/background_music",
                volume = 1.0,
                looping = true,
            }
        })

        local rot1 = quat:new():setIdentity()
        rot1.x = 123
        rot1.y = -34
        rot1.z = 141

        local rot2 = quat:new():setIdentity()
        rot2.x = 177
        rot2.y = 78
        rot2.z = -137

        local rot3 = quat:new():setIdentity()
        rot3.x = 14
        rot3.y = 9
        rot3.z = 12.5

        local rot4 = quat:new():setIdentity()
        rot4.x = -1.06
        rot4.y = -40.812
        rot4.z = 0

        local camCheckPoints = {
            {
                position = vec3(191, 471, -183),
                rotation = rot1,
                duration = 0,
                fov = 120
            },
            {
                position = vec3(222, 169, -65),
                rotation = rot2,
                duration = 4,
                fov = 70
            },
            {
                position = vec3(92, 44, 110),
                rotation = rot3,
                duration = 3,
                fov = 75
            },
            {
                position = vec3(-171, 3.874, 453),
                rotation = rot4,
                duration = 13,
                fov = 46
            },
        }

        local i = 0
        local nextCheckpoint = nil

        nextCheckpoint = function()
            if i == #camCheckPoints then
                _G.startScript()
                return
            end
            i = i + 1

            local cp = camCheckPoints[i]
            local method = "linear"
            if i == 1 then
                method = "pow2In"
            end
            if i == #camCheckPoints then

                setTimeout(cam, 8, function()
                    local profIntro = createEntity()
                    applyTemplate(profIntro, "ProfessorIntro")
                end)

                method = "pow2Out"
                component.SoundSpeaker.animate(cam, "volume", 0, cp.duration)
            end
            component.Transform.animate(cam, "position", cp.position, cp.duration, method, nextCheckpoint)
            component.Transform.animate(cam, "rotation", cp.rotation, cp.duration, method)
            component.CameraPerspective.animate(cam, "fieldOfView", cp.fov, cp.duration, method)
        end

        local camTrans = component.Transform.getFor(cam)
        camTrans.position = camCheckPoints[1].position
        camTrans.rotation = camCheckPoints[1].rotation
        local camPers = component.CameraPerspective.getFor(cam)
        camPers.fieldOfView = camCheckPoints[1].fov
        nextCheckpoint()
        component.Inspecting.getFor(cam)

    elseif _G.outroScreen then

        applyTemplate(createEntity(), "BoyOutro")
        applyTemplate(createEntity(), "ProfessorOutro")

        local cam = getByName("outro_cam")
        setMainCamera(cam)
        setComponents(cam, {
            SoundSpeaker {
                sound = "sounds/background_music",
                volume = 0.5,
                looping = true,
            }
        })

        local rot1 = quat:new():setIdentity()
        rot1.x = -167
        rot1.y = -17.9
        rot1.z = 180

        local rot2 = quat:new():setIdentity()
        rot2.x = 159
        rot2.y = -45
        rot2.z = -180

        local rot3 = quat:new():setIdentity()
        rot3.x = -179
        rot3.y = -69
        rot3.z = -179

        local rot4 = quat:new():setIdentity()
        rot4.x = -179
        rot4.y = -69
        rot4.z = -179

        local camCheckPoints = {
            {
                position = vec3(18, 121.5, -93),
                rotation = rot1,
                duration = 0,
                fov = 36
            },
            {
                position = vec3(-19.5, 150, -110),
                rotation = rot2,
                duration = 4,
                fov = 45
            },
            {
                position = vec3(-181, 119, -106),
                rotation = rot3,
                duration = 6,
                fov = 18
            },
            {
                position = vec3(-181, 105, -106),
                rotation = rot4,
                duration = 1,
                fov = 18
            },
        }

        local i = 0
        local nextCheckpoint = nil
        local exitOnFinish = false

        nextCheckpoint = function()
            if i == #camCheckPoints then
                if exitOnFinish then
                    -- todo
                else
                    _G.startScript()
                end
                return
            end
            i = i + 1
            if i == 3 and exitOnFinish then
                _G.byeProf()
            end

            local cp = camCheckPoints[i]
            local method = "linear"
            if i == 1 then
                method = "pow2In"
            end
            component.Transform.animate(cam, "position", cp.position, cp.duration, method, nextCheckpoint)
            component.Transform.animate(cam, "rotation", cp.rotation, cp.duration, method)
            component.CameraPerspective.animate(cam, "fieldOfView", cp.fov, cp.duration, method)
        end

        local camTrans = component.Transform.getFor(cam)
        camTrans.position = camCheckPoints[1].position
        camTrans.rotation = camCheckPoints[1].rotation
        local camPers = component.CameraPerspective.getFor(cam)
        camPers.fieldOfView = camCheckPoints[1].fov
        nextCheckpoint()
        component.Inspecting.getFor(cam)

        _G.secondOutroCamPath = function()
            local rot5 = quat:new():setIdentity()
            rot5.x = 160
            rot5.y = -21
            rot5.z = -179

            local rot6 = quat:new():setIdentity()
            rot6.x = 160.7
            rot6.y = -44.528
            rot6.z = -178.69

            exitOnFinish = true
            camCheckPoints = {
                {
                    position = vec3(-181, 105, -106),
                    rotation = rot4,
                    duration = 0,
                    fov = 18
                },
                {
                    position = vec3(-60, 172, -174),
                    rotation = rot5,
                    duration = 6.5,
                    fov = 45
                },
                {
                    position = vec3(-60, 172, -174),
                    rotation = rot5,
                    duration = 3.5,
                    fov = 45
                },
                {
                    position = vec3(-60, 172, -174),
                    rotation = rot6,
                    duration = 4.0,
                    fov = 5
                }
            }
            i = 0
            nextCheckpoint()
        end
    end

end
