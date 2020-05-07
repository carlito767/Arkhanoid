package states;

import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

import components.Animation;
import components.BrickColor;
using AnimationExtension;
using Graphics2Extension;

typedef Demo = {
  anim:Animation,
  name:String,
}

class DemoAnimationState implements State {
  var game:Game;

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
    this.game = game;

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
      {anim:'enemy_cone'.loadAnimation(4), name:'konerds'},
      {anim:'enemy_pyramid'.loadAnimation(4), name:'pyradoks'},
      {anim:'enemy_molecule'.loadAnimation(4), name:'tri-spheres'},
      {anim:'enemy_cube'.loadAnimation(4), name:'opopos'},
      {anim:'enemy_explosion'.loadAnimation(4), name:'explosion'},
    ];

    bricks = [];
    for (color in AbstractEnumTools.getValues(BrickColor)) {
      bricks.push({anim:'brick_$color'.loadAnimation(4), name:color});
    }

    nextDemo();

    // Input bindings
    game.input.clearBindings();
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(A), (_)->{ nextDemo(); });
  }

  public function update():Void {
  }

  public function render(g2:Graphics):Void {
    g2.color = Color.White;
    g2.font = game.ALT_FONT;
    g2.fontSize = 46;
    g2.centerString(id, 200);
    g2.fontSize = fontSize;

    var top = 270;
    for (animation in demos) {
      // Name
      g2.centerString(animation.name.toUpperCase(), top);
      // Image
      var image = animation.anim.tick();
      g2.drawImage(image, (System.windowWidth() - image.width) * 0.5, top + dy1);

      top += dy2;
    }
  }

  function nextDemo():Void {
    n++;
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
        game.backToTitle();
    }
  }
}