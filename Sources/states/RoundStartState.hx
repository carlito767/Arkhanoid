package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import scenes.RoundScene;
using AnimationExtension;
using Graphics2Extension;

class RoundStartState extends RoundState {
  static inline var DISPLAY_ROUND_FRAME = 60;
  static inline var DISPLAY_READY_FRAME = DISPLAY_ROUND_FRAME + 60;
  static inline var NO_DISPLAY_FRAME = DISPLAY_READY_FRAME + 50;
  static inline var PADDLE_FRAME = NO_DISPLAY_FRAME + 10;
  static inline var START_FRAME = PADDLE_FRAME + 60;

  var displayCount:Int = 0;

  public function new(scene:RoundScene) {
    super(scene);
  }

  override function render(g2:Graphics):Void {
    g2.color = Color.White;
    g2.font = scene.MAIN_FONT;
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
      var paddle = scene.paddle;
      paddle.reset();
      paddle.animation = 'paddle_materialize'.loadAnimation(2, -1);
      paddle.image = paddle.animation.tick();
      paddle.x = (worldBounds.right + worldBounds.left - paddle.image.width) * 0.5;
      paddle.y = worldBounds.bottom - paddle.image.height - 30;
      paddle.bounceStrategy = BounceStrategies.bounceStrategyPaddle;

      // Move your body!
      scene.freezePaddle = false;
      scene.moveLeft = false;
      scene.moveRight = false;

      // Create ball
      var ball = world.add(Ball);
      ball.image = Assets.images.ball;
      ball.anchorTo(paddle);

      // Animate the bricks
      for (brick in world.all(Brick)) {
        brick.animation.reset();
      }
    }
    if (displayCount > PADDLE_FRAME && scene.paddle.animation.over()) {
      scene.paddle.animation = 'paddle_pulsate'.pulsateAnimation(4, 80);
    }
    if (displayCount == START_FRAME) {
      // Release the anchor
      scene.releaseBalls();
      // Normal gameplay begins
      scene.state = new RoundPlayState(scene);
    }

    // Update display count
    if (!game.pause) displayCount++;
  }
}
