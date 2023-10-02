

function create(title)

    setName(title, "title")

    setComponents(title, {
        Transform(),
        RenderModel {
            modelName = "Title"
        },
        CustomShader {
            vertexShaderPath = "shaders/default.vert",
            fragmentShaderPath = "shaders/default.frag",
            defines = {TITLE = "1"}
        },
        SoundSpeaker {
            sound = "sounds/background_music",
            volume = 0.8,
            looping = true,
        },
    })

end
