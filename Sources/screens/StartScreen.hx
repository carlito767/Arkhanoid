package screens;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

typedef PowerupData = {
  anim:AnimationData,
  name:String,
  desc:String,
}

class StartScreen extends Screen {
  var displayCount:Int;
  var round:Int;
  var powerups:Array<PowerupData>;

  public function new() {
    super();

    displayCount = 0;
    round = 0;
    powerups = [
        { anim:Animation.fromSequence('powerup_laser'), name:'laser', desc:'enables the vaus\nto fire a laser' },
        { anim:Animation.fromSequence('powerup_slow'), name:'slow', desc:'slow down the\nenergy ball' },
        { anim:Animation.fromSequence('powerup_life'), name:'extra life', desc:'gain an additional\nvaus' },
        { anim:Animation.fromSequence('powerup_expand'), name:'expand', desc:'expands the vaus' },
        { anim:Animation.fromSequence('powerup_catch'), name:'catch', desc:'catches the energy\nball' },
        { anim:Animation.fromSequence('powerup_duplicate'), name:'duplicate', desc:'duplicates the energy\nball' },
    ];
  }

  override function update():Void {
    if (game.keyboard.isPressed(KeyCode.Space) || game.keyboard.isPressed(KeyCode.Return)) {
      if (round == 0) {
        round = 1;
      }
      game.switchTo(round);
    }
    var n = game.keyboard.numberPressed();
    if (n != null && (n > 0 || round > 0)) {
      var r = round * 10 + n;
      if (r <= game.MAX_ROUND) {
        round = r;
      }
    }
    if (game.keyboard.isPressed(KeyCode.Backspace) && round > 0) {
      round = Std.int(round / 10);
    }
  }

  override function render(g2:Graphics):Void {
    g2.font = game.ALT_FONT;

    // Display Powerups
    g2.color = Color.White;
    g2.fontSize = 46;
    g2.drawString('POWERUPS', 210, 200);

    var left = 30;
    var top = 270;
    for (powerup in powerups) {
        if (displayCount % 4 == 0) {
          Animation.next(powerup.anim);
        }
        // Sprite
        var sprite = Assets.images.get(powerup.anim.sequence[powerup.anim.current]);
        g2.color = Color.White;
        g2.drawImage(sprite, left, top);
        // Name
        g2.color = Color.White;
        g2.fontSize = 29;
        g2.drawString(powerup.name.toUpperCase(), left + sprite.width + 20, top - 3);
        // Description
        g2.fontSize = 20;
        var desc = powerup.desc.split('\n');
        for (i in 0...desc.length) {
          g2.drawString(desc[i].toUpperCase(), left, top + 25 + (i * g2.fontSize));
        }

        left += 180;
        if (left > 400) {
          left = 30;
          top += 100;
        }
    }

    // Display instructions
    var switchColor = (displayCount % 30) > 14;

    g2.fontSize = 65;
    var instruction1 = 'SPACEBAR TO START';
    var instruction1Width = g2.font.width(g2.fontSize, instruction1);
    var instruction1X = (WIDTH - instruction1Width) / 2;
    g2.color = Color.fromBytes(220, 220, 220);
    g2.drawString(instruction1, instruction1X + 3, 503);
    g2.color = (switchColor) ? Color.Yellow : Color.White;
    g2.drawString(instruction1, instruction1X, 500);

    g2.fontSize = 43;
    var instruction2 = 'OR ENTER LEVEL';
    var instruction2Width = g2.font.width(g2.fontSize, instruction2);
    var instruction2X = (WIDTH - instruction2Width) / 2;
    g2.color = (switchColor) ? Color.White : Color.Red;
    g2.drawString(instruction2, instruction2X, 575);

    // Level
    if (round > 0) {
      g2.fontSize = 54;
      var level = Std.string(round);
      var levelWidth = g2.font.width(g2.fontSize, level);
      var levelX = (WIDTH - levelWidth) / 2;
      g2.color = Color.White;
      g2.drawString(level, levelX, 625);
    }

    // Taito
    g2.color = Color.fromBytes(128, 128, 128);
    g2.fontSize = 32;
    var taito = [ 'Based on original Arkanoid game', 'by Taito Corporation 1986' ];
    for (i in 0...taito.length) {
      var taitoWidth = g2.font.width(g2.fontSize, taito[i]);
      g2.drawString(taito[i], (WIDTH - taitoWidth) / 2, 700 + (i * g2.fontSize));
    }

    // Update display count
    displayCount++;
  }
}
