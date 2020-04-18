package states;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

class GameStartState implements IProcess {
  var displayCount:Int = 0;

  public function new() {
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Space)) {
      game.switchToRound(0);
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    // Display background
    g2.color = game.round.backgroundColor;
    g2.fillRect(0, 150, WIDTH, HEIGHT - 150);

    // Display round name
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
