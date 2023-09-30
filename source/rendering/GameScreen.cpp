
#include <game/dibidab.h>
#include "GameScreen.h"
#include "../game/Game.h"

GameScreen::GameScreen()
{
    onSessionChange = dibidab::onSessionChange += [&] {
        delete lvlScreen;
        lvlScreen = NULL;

        Session *session = dibidab::tryGetCurrentSession();
        if (session)
            onNewLevel = session->onNewLevel += [&] (Level *lvl) {
                delete lvlScreen;
                if (lvl)
                    lvlScreen = new LevelScreen(lvl);
                else lvlScreen = NULL;
            };
    };
}

void GameScreen::render(double deltaTime)
{
    if (lvlScreen) {
        lvlScreen->render(deltaTime);
    } else {
        glClearColor(0/255.0, 0/255.0, 0/255.0, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    if (!Game::uiScreenManager->noScreens())
        Game::uiScreenManager->getActiveScreen().render(deltaTime);

    if (!dibidab::settings.showDeveloperOptions)
        return;
}

void GameScreen::onResize()
{
    if (lvlScreen)
        lvlScreen->onResize();
}
