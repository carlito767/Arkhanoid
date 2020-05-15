package scenes;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

using AnimationExtension;
using Collisions;
import components.Bounds;
import components.BrickColor;
import rounds.Round;
import states.DemoStartState;
import states.RoundState;
import states.RoundStartState;
import world.Entity;
using world.EntityExtension;
import world.World;

class RoundScene extends Scene {
  // The number of pixels from the top of the screen before the top edge starts.
  static inline var TOP_OFFSET = 150.0;

  public var lives:Int;
  public var round:Round;
  public var state:RoundState;

  public var edgeLeft(default,null):Entity;
  public var edgeRight(default,null):Entity;
  public var edgeTop(default,null):Entity;

  public var paddle(default,null):Entity;

  public var world(default,never):World = new World();
  public var worldBounds(default,never):Bounds = {left:0.0, top:TOP_OFFSET, right:Game.WIDTH, bottom:Game.HEIGHT};

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
    var bricks:Array<Entity> = [];
    for (y in 0...round.bricks.length) {
      var row = round.bricks[y];
      for (x in 0...row.length) {
        var value = row.charAt(x);
        var color:Null<BrickColor> = switch value {
          case 'B': Blue;
          case 'C': Cyan;
          case '*': Gold;
          case 'G': Green;
          case 'O': Orange;
          case 'P': Pink;
          case 'R': Red;
          case 'S': Silver;
          case 'W': White;
          case 'Y': Yellow;
          case _: null;
        };
        if (color != null) {
          var name = color.getName().toLowerCase();
          var animation = 'brick_${name}'.loadAnimation(2, -1);
          var image = animation.tick();
          animation.paused = true;

          var brick = world.add(Brick);
          brick.animation = animation;
          brick.image = image;
          brick.x = x * image.width + edgeLeft.image.width;
          brick.y = y * image.height + worldBounds.top;
          brick.health = brickHealth(round.id, color);
          brick.value = brickValue(round.id, color);
    
          bricks.push(brick);
        }
      }
    }

    // Add powerups
    round.powerupBuilder(bricks);

    // Create paddle
    paddle = world.add(Paddle);

    // Initialize state
    state = (round.id == 0) ? new DemoStartState(this) : new RoundStartState(this);

    // Input bindings
    if (round.id > 0) {
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
    }
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
  }

  override function update():Void {
    // Animate entities
    for (e in world.all()) {
      if ((e.animation == null || e.animation.over()) && e.pendingAnimations != null && !e.pendingAnimations.isEmpty()) {
        e.animation = e.pendingAnimations.shift();
      }
    }

    for (e in world.animatables()) {
      var image = e.image;
      e.image = e.animation.tick();
      // Center image
      if (image != null && e.hasPosition()) {
        e.x += (image.width - e.image.width) * 0.5;
        e.y += (image.height - e.image.height) * 0.5;
      }
    }

    // Move entities
    for (e in world.movables()) {
      e.x += e.speed * Math.cos(e.angle);
      e.y += e.speed * Math.sin(e.angle);
    }

    // Update state
    state.update();

    // Remove out of bounds
    for (e in world.drawables()) {
      var bounds:Bounds = e.bounds();
      if (!bounds.isIntersecting(worldBounds)) {
        world.remove(e);
      }
    }
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
    if (round.id > 0) {
      var paddleLife = Assets.images.paddle_life;
      var x = edgeLeft.x + edgeLeft.image.width;
      var y = worldBounds.bottom - paddleLife.height - 5;
      for (_ in 1...lives) {
        g2.drawImage(paddleLife, x, y);
        x += paddleLife.width + 5;
      }
    }

    // Render state
    state.render(g2);
  }

  //
  // Bricks
  //

  function brickHealth(id:Int, color:BrickColor):Int {
    return switch color {
      case Gold: 0; // indestructable
      case Silver: Math.ceil(id / 8) + 1;
      case _: 1;
    }
  }

  function brickValue(id:Int, color:BrickColor):Int {
    return switch color {
      case Blue: 100;
      case Cyan: 70;
      case Gold: 0;
      case Green: 80;
      case Orange: 60;
      case Pink: 110;
      case Red: 90;
      case Silver: 50 * id;
      case White: 50;
      case Yellow: 120;
    }
  }
}
