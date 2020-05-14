package states;

import kha.Assets;
import kha.System;

using AnimationExtension;
using MathExtension;
import components.PowerupType;
import scenes.RoundScene;
using world.EntityExtension;

class DemoStartState extends RoundState {
  static inline var POWERUP_SPEED = 3.0;

  public function new(scene:RoundScene) {
    super(scene);

    // Create paddle
    paddle.reset();
    paddle.animation = 'paddle_pulsate'.pulsateAnimation(4, 80);
    paddle.image = paddle.animation.tick();
    paddle.x = (System.windowWidth() - paddle.image.width) * 0.5;
    paddle.y = (System.windowHeight() - paddle.image.height + worldBounds.top) * 0.5;

    // Input bindings
    game.input.bind(Key(Delete), (_)->{
      world.removeAll(Ball);
      world.removeAll(Enemy);
    });
    game.input.bind(Key(B), (_)->{ newBalls(); });
    game.input.bind(Key(C), (_)->{ newPowerup(Catch); });
    game.input.bind(Key(D), (_)->{ newPowerup(Duplicate); });
    game.input.bind(Key(E), (_)->{ newPowerup(Expand); });
    game.input.bind(Key(L), (_)->{ newPowerup(Laser); });
    game.input.bind(Key(P), (_)->{ newPowerup(Life); });
    game.input.bind(Key(S), (_)->{ newPowerup(Slow); });
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

  function newPowerup(powerupType:PowerupType):Void {
    var e = world.add(Powerup);
    var name = powerupType.getName().toLowerCase();
    e.animation = 'powerup_$name'.loadAnimation(4);
    e.x = System.windowWidth() * 0.5;
    e.y = worldBounds.top;
    e.powerupType = powerupType;
    e.speed = POWERUP_SPEED;
    e.angle = 90.toRadians();
    e.value = 0;
  }
}
