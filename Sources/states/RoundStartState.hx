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
    if (displayCount >= DISPLAY_ROUND_FRAME && displayCount < NO_DISPLAY_FRAME) {
      g2.centerString('Round ${round.id}', 600);
    }
    // Display 'Ready'
    if (displayCount >= DISPLAY_READY_FRAME && displayCount < NO_DISPLAY_FRAME) {
      g2.centerString('Ready', 650);
    }
    if (displayCount == PADDLE_FRAME) {
      // Create paddle
      var paddle = round.createPaddle();

      // Create ball
      var ball = round.createBall();
      ball.position.x = paddle.x + paddle.image.width * 0.5;
      ball.position.y = paddle.y - ball.image.height;
      ball.anchored = true;

      // Animate the paddle materializing onto the screen
      paddle.animation = 'paddle_materialize'.loadAnimation(2, -1);

      // Animate the bricks
      round.animateBricks();
    }
    if (displayCount > PADDLE_FRAME && round.paddle.animation.over()) {
      round.paddle.animation = 'paddle_pulsate'.pulsateAnimation(4, 80);
    }
    if (displayCount == START_FRAME) {
      // Release the anchor
      round.releaseBalls();
      // Normal gameplay begins
      game.state = new RoundPlayState(game, round);
    }

    // Update display count
    displayCount++;
  }
}
