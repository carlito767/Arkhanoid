package screens;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

import rounds.IRound;

import states.IState;
import states.GameStartState;

class GameScreen implements IScreen {
  public var displayCount(default, null):Int;

  public var round(default, null):IRound;

  var state:IState;

  public function new(round:IRound) {
    displayCount = 0;

    this.round = round;
    state = new GameStartState();
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Space)) {
      game.switchToRound(0);
    }

    // Update state
    state.update(this, game);
  }

  public function render(game:Game, g2:Graphics):Void {
    // Display background
    g2.color = round.backgroundColor;
    g2.fillRect(0, 150, WIDTH, HEIGHT - 150);
  
    // Display state
    state.render(this, game, g2);

    // Update display count
    displayCount++;
  }
}
