package states;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

class GameStartState implements IState {
  var displayCount:Int;

  public function new() {
    displayCount = 0;
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Space)) {
      game.switchToRound(0);
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    g2.color = game.round.backgroundColor;
    g2.fillRect(0, 150, WIDTH, HEIGHT - 150);
  
    if (displayCount > 100) {
      g2.color = Color.White;
      g2.font = game.MAIN_FONT;
      g2.fontSize = 18;
      g2.centerString(game.round.name, 600);
    }

    // Update display count
    displayCount++;
  }
}
