package states;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

using AnimationExtension;
using Collisions;
import scenes.RoundScene;
using world.EntityExtension;

class DemoState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);

    // Create paddle
    paddle.reset();
    paddle.animation = 'paddle_pulsate'.pulsateAnimation(4, 80);
    paddle.image = paddle.animation.tick();
    paddle.x = (System.windowWidth() - paddle.image.width) * 0.5;
    paddle.y = (System.windowHeight() - paddle.image.height + worldBounds.top) * 0.5;

    // Input bindings
    game.input.bind(Key(Delete), (_)->{ world.removeAll(Ball); });
    game.input.bind(Key(B), (_)->{ newBalls(); });
  }

  override function update():Void {
    // Detect collisions
    for (ball in world.collidables(Ball)) {
      for (e in world.collidables()) {
        if (e.kind == Ball) continue;

        if (ball.collide(e)) {
          ball.angle = BounceStrategies.bounceStrategy(ball, [e.bounds()]);
        }
      }
    }
  }

  override function render(g2:Graphics):Void {
    // Draw debug informations
    g2.color = Color.Yellow;
    g2.font = Assets.fonts.optimus;
    g2.fontSize = 30;
    var n = world.drawables(Ball).length;
    g2.drawString('Balls:$n', 10, 10);
  }

  function newBalls():Void {
    for (_ in 0...10) {
      var e = world.add(Ball);
      e.image = Assets.images.ball;
      e.x = System.windowWidth() * 0.5;
      e.y = System.windowHeight() * 0.5;
      e.speed = 2.0 + Math.random() * 10;
      e.angle = Math.random() * 360;
    }
  }
}
