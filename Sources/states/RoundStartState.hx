package states;

import kha.Color;
import kha.graphics2.Graphics;

import rounds.Round;
using AnimationExtension;
using Graphics2Extension;

class RoundStartState extends RoundState {
  static inline var DISPLAY_ROUND_FRAME = 60;
  static inline var DISPLAY_READY_FRAME = DISPLAY_ROUND_FRAME + 60;
  static inline var NO_DISPLAY_FRAME = DISPLAY_READY_FRAME + 50;
  static inline var PADDLE_FRAME = NO_DISPLAY_FRAME + 10;
  static inline var START_FRAME = PADDLE_FRAME + 60;

  public function new(game:Game, round:Round) {
    super(game, round);
  }

  override function postRender(g2:Graphics):Void {
    round.render(g2);

    g2.color = Color.White;
    g2.font = game.MAIN_FONT;
    g2.fontSize = 18;
    // Display round name
    if (frame >= DISPLAY_ROUND_FRAME && frame < NO_DISPLAY_FRAME) {
      g2.centerString('Round ${round.id}', 600);
    }
    // Display 'Ready'
    if (frame >= DISPLAY_READY_FRAME && frame < NO_DISPLAY_FRAME) {
      g2.centerString('Ready', 650);
    }
    if (frame == PADDLE_FRAME) {
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
    if (frame > PADDLE_FRAME && round.paddle.animation == null) {
      var animation1 = 'paddle_pulsate'.loadAnimation(4, 80);
      var animation2 = animation1.reverse();
      round.paddle.animation = animation1.chain(animation2);
    }
    if (frame == START_FRAME) {
      // Release the anchor
      round.releaseBalls();
      // Normal gameplay begins
      game.state = new RoundPlayState(game, round);
    }
  }
}
