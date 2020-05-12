package scenes;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

using AnimationExtension;
import components.Bounds;
import rounds.Round;
import states.RoundState;
import states.RoundStartState;
import world.Entity;
using world.EntityExtension;
import world.World;

class RoundScene extends Scene {
  // The number of pixels from the top of the screen before the top edge starts.
  static inline var TOP_OFFSET = 150.0;

  public var lives:Int;
  public var round(default,null):Round;
  public var state:RoundState;

  public var edgeLeft(default,null):Entity;
  public var edgeRight(default,null):Entity;
  public var edgeTop(default,null):Entity;

  public var paddle(default,null):Entity;

  public var world(default,never):World = new World();
  public var worldBounds(default,never):Bounds = {left:0.0, top:TOP_OFFSET, right:System.windowWidth(), bottom:System.windowHeight()};

  public function new(game:Game, round:Round, lives:Int) {
    super(game);

    this.lives = lives;
    this.round = round;

    // Create edges
    edgeLeft = world.add(Edge);
    edgeLeft.image = Assets.images.edge_left;
    edgeLeft.x = worldBounds.left;
    edgeLeft.y = worldBounds.top;

    edgeRight = world.add(Edge);
    edgeRight.image = Assets.images.edge_right;
    edgeRight.x = worldBounds.right - edgeRight.image.width;
    edgeRight.y = worldBounds.top;

    edgeTop = world.add(Edge);
    edgeTop.image = Assets.images.edge_top;
    edgeTop.x = edgeLeft.image.width;
    edgeTop.y = worldBounds.top;

    // Create bricks
    for (brick in round.bricks) {
      var e = world.add(Brick);
      e.animation = brick.animation;
      e.image = brick.image;
      e.x = brick.x + edgeLeft.image.width;
      e.y = brick.y + worldBounds.top;
      e.health = brick.health;
      e.value = brick.value;
      e.powerupType = brick.powerupType;
    }

    // Create paddle
    paddle = world.add(Paddle);

    // Initialize state
    state = new RoundStartState(this);

    // Input bindings
    #if debug
    game.input.bind(Key(Subtract), (_)->{
      if (round.id > 1) {
        game.switchToRound(round.id - 1, this.lives);
      }
    });
    game.input.bind(Key(Add), (_)->{
      if (round.id < game.rounds.length) {
        game.switchToRound(round.id + 1, this.lives);
      }
    });
    game.input.bind(Key(R), (_)->{
      game.switchToRound(round.id, this.lives);
    });
    #end
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
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
    }

    // Update state
    state.update();
  }

  override function render(g2:Graphics):Void {
    // Draw background
    g2.color = round.backgroundColor;
    g2.fillRect(worldBounds.left, worldBounds.top, worldBounds.right - worldBounds.left, worldBounds.bottom - worldBounds.top);

    // Draw entities
    g2.color = Color.White;
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.x, e.y);
      if (game.debugMode && e.kind == Brick && e.powerupType != null) {
        var name = e.powerupType.getName().toLowerCase();
        var image = Assets.images.get('powerup_${name}_1');
        g2.drawImage(image, e.x, e.y);
      }
      for (anchored in world.anchoredTo(e)) {
        var position = anchored.anchorPosition();
        if (position != null) {
          g2.drawImage(anchored.image, position.x, position.y);
        }
      }
    }

    // Draw lives
    var paddleLife = Assets.images.paddle_life;
    var x = edgeLeft.x + edgeLeft.image.width;
    var y = worldBounds.bottom - paddleLife.height - 5;
    for (i in 1...lives) {
      g2.drawImage(paddleLife, x, y);
      x += paddleLife.width + 5;
    }

    // Render state
    state.render(g2);
  }
}
