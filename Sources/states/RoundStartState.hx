package states;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

import paddle_states.MaterializeState;
import paddle_states.PaddleStateManager;

class RoundStartState implements State {
  var displayCount:Int = 0;

  public function new() {
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Space)) {
      game.switchToRound(0);
      return;
    }

    game.round.update();
  }

  public function render(game:Game, g2:Graphics):Void {
    // Display edges
    game.round.drawEdges(g2);

    // Display bricks
    game.round.drawBricks(g2);

    // Display lives
    game.round.drawLives(g2);

    // Display paddle
    game.round.drawPaddle(g2);

    // Display ball
    game.round.drawBall(g2);

    g2.color = Color.White;
    g2.font = game.MAIN_FONT;
    g2.fontSize = 18;
    // Display round name
    if (displayCount > 100 && displayCount < 311) {
      g2.centerString(game.round.name, 600);
    }
    // Display 'ready'
    if (displayCount > 200 && displayCount < 311) {
      g2.centerString('ready', 650);
      game.round.paddle.visible = true;
      game.round.ball.visible = true;
    }
    if (displayCount == 201) {
      // Animate the paddle materializing onto the screen
      PaddleStateManager.transition(game.round.paddle, new MaterializeState());
    }

    // Update display count
    displayCount++;
  }
}
