package states;

import kha.graphics2.Graphics;
import kha.input.KeyCode;

class RoundPlayState implements State {
  public function new() {
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Escape)) {
      game.switchToRound(0);
      return;
    }

    game.round.update();
  }

  public function render(game:Game, g2:Graphics):Void {
    game.round.render(g2);
  }
}
