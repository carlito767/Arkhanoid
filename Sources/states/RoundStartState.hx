package states;

import kha.Color;
import kha.graphics2.Graphics;

import rounds.Round;
using AnimationExtension;
using Graphics2Extension;

class RoundStartState extends RoundState {
  var displayCount:Int = 0;

  public function new(game:Game, round:Round) {
    super(game, round);
  }

  override function postRender(g2:Graphics):Void {
    round.render(g2);

    g2.color = Color.White;
    g2.font = game.MAIN_FONT;
    g2.fontSize = 18;
    // Display round name
    if (displayCount > 100 && displayCount < 311) {
      g2.centerString('Round ${round.id}', 600);
    }
    // Display 'ready'
    if (displayCount > 200 && displayCount < 311) {
      g2.centerString('ready', 650);
    }
    if (displayCount == 201) {
      // Create paddle
      var paddle = round.createPaddle();

      // Create ball
      var ball = round.createBall();
      ball.x = paddle.x + paddle.image.width * 0.5;
      ball.y = paddle.y - ball.image.height;
      ball.anchored = true;

      // Animate the paddle materializing onto the screen
      paddle.animation = 'paddle_materialize'.loadAnimation(2, -1);

      // Animate the bricks
      for (brick in round.bricks) {
        brick.animation = 'brick_${brick.color}'.loadAnimation(4, -1);
      }
    }
    if (displayCount > 201 && round.paddle.animation == null) {
      var animation1 = 'paddle_pulsate'.loadAnimation(4, 80);
      var animation2 = animation1.reverse();
      round.paddle.animation = animation1.chain(animation2);
    }
    if (displayCount == 340) {
      // Release the anchor
      round.releaseBalls();
      // Normal gameplay begins
      game.state = new RoundPlayState(game, round);
    }

    // Update display count
    displayCount++;
  }
}
