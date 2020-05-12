package states;

import kha.Assets;
import kha.System;

using AnimationExtension;
import scenes.RoundScene;
using world.EntityExtension;

class DemoStartState extends RoundState {
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
    scene.state = new RoundPlayState(scene);
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
