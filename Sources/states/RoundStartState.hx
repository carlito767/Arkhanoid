package states;

import kha.Color;
import kha.graphics2.Graphics;

import paddle_states.MaterializeState;
import paddle_states.PaddleState;
using Graphics2Extension;

class RoundStartState extends State {
  var displayCount:Int = 0;

  public function new(game:Game) {
    super(game);
  }

  override function update():Void {
    game.round.update();
  }

  override function render(g2:Graphics):Void {
    game.round.render(g2);

    g2.color = Color.White;
    g2.font = game.MAIN_FONT;
    g2.fontSize = 18;
    // Display round name
    if (displayCount > 100 && displayCount < 311) {
      g2.centerString('Round ${game.round.id}', 600);
    }
    // Display 'ready'
    if (displayCount > 200 && displayCount < 311) {
      g2.centerString('ready', 650);
    }
    if (displayCount == 201) {
      // Create paddle
      var paddle = game.round.createPaddle();

      // Create ball
      var ball = game.round.createBall();
      ball.x = paddle.x + paddle.image.width * 0.5;
      ball.y = paddle.y - ball.image.height;
      ball.anchored = true;

      // Animate the paddle materializing onto the screen
      PaddleState.transition(paddle, MaterializeState.new);
    }
    if (displayCount == 340) {
      // Release the anchor
      game.round.releaseBalls();
      // Normal gameplay begins
      game.state = new RoundPlayState(game);
    }

    // Update display count
    displayCount++;
  }
}
