package screens;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

import rounds.IRound;

class GameScreen implements IScreen {
  var displayCount:Int;

  var round:IRound;

  public function new(round:IRound) {
    displayCount = 0;

    this.round = round;
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Space)) {
      game.switchToRound(0);
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    g2.color = round.backgroundColor;
    g2.fillRect(0, 150, WIDTH, HEIGHT - 150);
  
    if (displayCount > 100) {
      g2.color = Color.White;
      g2.font = game.MAIN_FONT;
      g2.fontSize = 18;
      g2.centerString(round.name, 600);
    }

    // Update display count
    displayCount++;
  }
}
