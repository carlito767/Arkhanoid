package states;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

import Collisions.isIntersecting;
import components.Bounds;
import world.World;
using AnimationExtension;
using MathExtension;

class DemoWorldState implements State {
  var game:Game;

  static inline var KIND_PADDLE = 'paddle';

  var world:World = new World();
  var worldBounds:Bounds = {left:0.0, top:0.0, right:System.windowWidth(), bottom:System.windowHeight()};

  public function new(game:Game) {
    this.game = game;

    // Input bindings
    game.input.clearBindings();
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(B), (_)->{ newBalls(); });
    game.input.bind(Key(P), (_)->{ newPaddle(); });
    game.input.bind(Key(S), (_)->{ switchPaddlesVelocity(); });
  }

  public function update():Void {
    // Animate entities
    for (e in world.animatables()) {
      e.image = e.animation.tick();
    }

    // Update anchored entities
    for (e in world.anchoredTo()) {
      var anchor = e.anchor.e;
      if (anchor.position != null && anchor.image != null && e.image != null) {
        var offset = e.anchor.offset;
        var x = anchor.position.x;
        var y = anchor.position.y - (anchor.image.height + e.image.height) * 0.5;
        var dx = Math.min(Math.abs(offset.x), anchor.image.width * 0.5);
        x += (offset.x > 0) ? dx : -dx;
        y += offset.y;
        e.position = {x:x, y:y};
      }
    }

    // Move entities
    for (e in world.movables()) {
      e.position.x += e.velocity.speed * Math.cos(e.velocity.angle);
      e.position.y += e.velocity.speed * Math.sin(e.velocity.angle);

      var bounds:Bounds = {left:e.position.x, top:e.position.y, right:e.position.x, bottom:e.position.y};
      if (e.image != null) {
        bounds.left -= e.image.width * 0.5;
        bounds.top -= e.image.height * 0.5;
        bounds.right += e.image.width;
        bounds.bottom += e.image.height;
      }
      if (!isIntersecting(worldBounds, bounds)) {
        world.remove(e);
        for (anchored in world.anchoredTo(e)) {
          world.remove(anchored);
        }
      }
    }
  }

  public function render(g2:Graphics):Void {
    g2.color = Color.White;
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.position.x - e.image.width * 0.5, e.position.y - e.image.height * 0.5);
    }
  }

  function newBalls():Void {
    for (_ in 0...10) {
      var e = world.add();
      e.image = Assets.images.ball;
      e.position = {x:System.windowWidth() * 0.5, y:System.windowHeight() * 0.5};
      var speed = 2.0 + Math.random() * 10;
      var angle = Math.random() * 360;
      e.velocity = {speed:speed, angle:angle.toRadians()};
    }
  }

  function newPaddle():Void {
    var paddle = world.add(KIND_PADDLE);
    paddle.animation = 'paddle_wide'.pulsateAnimation(4);
    var x = Math.random() * System.windowWidth();
    var y = Math.random() * System.windowHeight();
    paddle.position = {x:x, y:y};
    var speed = Math.random() * 2;
    var angle = Math.random() * 360;
    paddle.velocity = {speed:speed, angle:angle.toRadians()};

    var ball = world.add();
    ball.image = Assets.images.ball;
    var range = Assets.images.paddle.width * 0.5;
    var offset = {x:Math.random() * range - range * 0.5, y:0.0};
    ball.anchorTo(paddle, offset);
  }

  function switchPaddlesVelocity():Void {
    for (e in world.movables(KIND_PADDLE)) {
      e.velocity.angle = 2 * Math.PI - e.velocity.angle;
    }
  }
}