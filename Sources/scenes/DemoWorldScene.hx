package scenes;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

import Collisions.isIntersecting;
import components.Bounds;
import world.World;
using AnimationExtension;
using MathExtension;

class DemoWorldScene extends Scene {
  var world:World = new World();
  var worldBounds:Bounds = {left:0.0, top:0.0, right:System.windowWidth(), bottom:System.windowHeight()};

  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(B), (_)->{ newBalls(); });
    game.input.bind(Key(N), (_)->{ newPaddle(); });
    game.input.bind(Key(S), (_)->{ switchPaddlesVelocity(); });
  }

  override function update():Void {
    // Animate entities
    for (e in world.animatables()) {
      e.image = e.animation.tick();
    }

    // Move entities
    for (e in world.movables()) {
      e.x += e.speed * Math.cos(e.angle);
      e.y += e.speed * Math.sin(e.angle);

      var bounds:Bounds = {left:e.x, top:e.y, right:e.x, bottom:e.y};
      if (e.image != null) {
        bounds.left -= e.image.width * 0.5;
        bounds.top -= e.image.height * 0.5;
        bounds.right += e.image.width;
        bounds.bottom += e.image.height;
      }
      if (!isIntersecting(worldBounds, bounds)) {
        e.remove();
      }
    }
  }

  override function render(g2:Graphics):Void {
    g2.color = Color.White;
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.x - e.image.width * 0.5, e.y - e.image.height * 0.5);
    }
  }

  function newBalls():Void {
    for (_ in 0...10) {
      var e = world.add();
      e.image = Assets.images.ball;
      e.x = System.windowWidth() * 0.5;
      e.y = System.windowHeight() * 0.5;
      e.speed = 2.0 + Math.random() * 10;
      e.angle = Math.random() * 360;
    }
  }

  function newPaddle():Void {
    var paddle = world.add(Paddle);
    paddle.animation = 'paddle_wide'.pulsateAnimation(4);
    paddle.x = Math.random() * System.windowWidth();
    paddle.y = Math.random() * System.windowHeight();
    paddle.speed = Math.random() * 2;
    paddle.angle = Math.random() * 360;
  }

  function switchPaddlesVelocity():Void {
    for (e in world.movables(Paddle)) {
      e.angle = 2 * Math.PI - e.angle;
    }
  }
}
