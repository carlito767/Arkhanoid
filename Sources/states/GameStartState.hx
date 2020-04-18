package states;

import kha.Color;
import kha.graphics2.Graphics;

import screens.GameScreen;

class GameStartState implements IState {
  public function new() {
  }

  public function update(screen:GameScreen, game:Game):Void {
  }

  public function render(screen:GameScreen, game:Game, g2:Graphics):Void {
    if (screen.displayCount > 100) {
      g2.color = Color.White;
      g2.font = game.MAIN_FONT;
      g2.fontSize = 18;
      g2.centerString(screen.round.name, 600);
    }
  }
}
