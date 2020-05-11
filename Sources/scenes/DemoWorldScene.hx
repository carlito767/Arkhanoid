package scenes;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

using AnimationExtension;
using Collisions;
import components.Bounds;
import world.World;

class DemoWorldScene extends Scene {
  static inline var TOP_OFFSET = 150.0;

  var world:World = new World();
  var worldBounds:Bounds = {left:0.0, top:TOP_OFFSET, right:System.windowWidth(), bottom:System.windowHeight()};

  public function new(game:Game) {
    super(game);

    // Create edges
    var edgeLeft = world.add(Edge);
    edgeLeft.image = Assets.images.edge_left;
    edgeLeft.x = worldBounds.left;
    edgeLeft.y = worldBounds.top;

    var edgeRight = world.add(Edge);
    edgeRight.image = Assets.images.edge_right;
    edgeRight.x = worldBounds.right - edgeRight.image.width;
    edgeRight.y = worldBounds.top;

    var edgeTop = world.add(Edge);
    edgeTop.image = Assets.images.edge_top;
    edgeTop.x = edgeLeft.image.width;
    edgeTop.y = worldBounds.top;

    // Create bottom wall
    var brick = Assets.images.brick_gold;
    var x = edgeLeft.x + edgeLeft.image.width;
    var y = worldBounds.bottom - brick.height;
    for (i in 0...13) {
      var e = world.add();
      e.image = brick;
      e.x = x;
      e.y = y;
      x += brick.width;
    }

    // Create paddle
    var paddle = world.add();
    paddle.animation = 'paddle_pulsate'.pulsateAnimation(4, 80);
    paddle.image = paddle.animation.tick();
    paddle.x = (System.windowWidth() - paddle.image.width) * 0.5;
    paddle.y = (System.windowHeight() - paddle.image.height + TOP_OFFSET) * 0.5;

    // Input bindings
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(Delete), (_)->{ world.removeAll(Ball); });
    game.input.bind(Key(B), (_)->{ newBalls(); });
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

      if (e.image != null) {
        var bounds:Bounds = e.bounds();
        if (!bounds.isIntersecting(worldBounds)) {
          world.remove(e);
        }
      }
    }

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

    // Draw entities
    g2.color = Color.White;
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.x, e.y);
    }
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
