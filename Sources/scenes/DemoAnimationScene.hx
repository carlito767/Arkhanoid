package scenes;

import kha.Color;
import kha.graphics2.Graphics;

using AnimationExtension;
using Graphics2Extension;
import components.Animation;
import components.BrickColor;

typedef Demo = {
  anim:Animation,
  name:String,
}

class DemoAnimationScene extends Scene {
  var n:Int = 0;

  var paddles:Array<Demo>;
  var enemies:Array<Demo>;
  var bricks:Array<Demo>;

  var id:String;
  var demos:Array<Demo> = [];
  var fontSize:Int;
  var dy1:Int;
  var dy2:Int;

  public function new(game:Game) {
    super(game);

    paddles = [
      {anim:'paddle_materialize'.loadAnimation(4), name:'materialize'},
      {anim:'paddle_pulsate'.pulsateAnimation(4, 80), name:'normal (pulsate)'},
      {anim:'paddle_wide'.pulsateAnimation(4), name:'wide'},
      {anim:'paddle_wide_pulsate'.pulsateAnimation(4, 80), name:'wide (pulsate)'},
      {anim:'paddle_laser'.loadAnimation(4), name:'laser'},
      {anim:'paddle_laser_pulsate'.pulsateAnimation(4, 80), name:'laser (pulsate)'},
      {anim:'paddle_explode'.pulsateAnimation(4), name:'explode'},
    ];

    enemies = [
      {anim:'enemy_cone'.loadAnimation(4), name:'konerd'},
      {anim:'enemy_pyramid'.loadAnimation(4), name:'pyradok'},
      {anim:'enemy_molecule'.loadAnimation(4), name:'tri-sphere'},
      {anim:'enemy_cube'.loadAnimation(4), name:'opopo'},
      {anim:'enemy_explosion'.loadAnimation(4), name:'explosion'},
    ];

    bricks = [];
    for (color in Type.allEnums(BrickColor)) {
      var name = color.getName().toLowerCase();
      bricks.push({anim:'brick_$name'.loadAnimation(4), name:name});
    }

    nextDemo();

    // Input bindings
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(A), (_)->{ nextDemo(); });
  }

  override function render(g2:Graphics):Void {
    g2.color = Color.White;
    g2.font = ALT_FONT;
    g2.fontSize = 46;
    g2.centerString(id, 200);
    g2.fontSize = fontSize;

    var top = 270;
    for (animation in demos) {
      // Name
      g2.centerString(animation.name.toUpperCase(), top);
      // Image
      var image = animation.anim.tick();
      g2.drawImage(image, (Game.WIDTH - image.width) * 0.5, top + dy1);

      top += dy2;
    }
  }

  function nextDemo():Void {
    n = (n % 3) + 1;
    switch n {
      case 1:
        id = 'PADDLES';
        demos = paddles;
        fontSize = 29;
        dy1 = 40;
        dy2 = 72;
      case 2:
        id = 'ENEMIES';
        demos = enemies;
        fontSize = 29;
        dy1 = 40;
        dy2 = 92;
      case 3:
        id = 'BRICKS';
        demos = bricks;
        fontSize = 24;
        dy1 = 25;
        dy2 = 52;
      default:
        // Should never happen
    }
  }
}
