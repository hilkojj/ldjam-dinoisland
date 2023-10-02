
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
        rot4.x = 5.1
        rot4.y = -43.8
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
                position = vec3(-171, 5, 453),
                rotation = rot4,
                duration = 8,
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
    end

end
