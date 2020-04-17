package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

typedef PowerupData = {
  anim:AnimationData,
  name:String,
  desc:String,
}

class StartState implements IState {
  var displayCount:Int;

  var powerups:Array<PowerupData>;
  var roundId:Int;

  public function new() {
    displayCount = 0;

    powerups = [
        { anim:Animation.fromSequence('powerup_laser'), name:'laser', desc:'enables the vaus\nto fire a laser' },
        { anim:Animation.fromSequence('powerup_slow'), name:'slow', desc:'slow down the\nenergy ball' },
        { anim:Animation.fromSequence('powerup_life'), name:'extra life', desc:'gain an additional\nvaus' },
        { anim:Animation.fromSequence('powerup_expand'), name:'expand', desc:'expands the vaus' },
        { anim:Animation.fromSequence('powerup_catch'), name:'catch', desc:'catches the energy\nball' },
        { anim:Animation.fromSequence('powerup_duplicate'), name:'duplicate', desc:'duplicates the energy\nball' },
    ];
    roundId = 0;
  }

  public function update(game:Game):Void {
    if (game.keyboard.isPressed(KeyCode.Space) || game.keyboard.isPressed(KeyCode.Return)) {
      if (roundId == 0) {
        roundId = 1;
      }
      game.switchToRound(roundId);
    }
    var n = game.keyboard.numberPressed();
    if (n != null && (n > 0 || roundId > 0)) {
      var r = roundId * 10 + n;
      if (r <= game.rounds.length) {
        roundId = r;
      }
    }
    if (game.keyboard.isPressed(KeyCode.Backspace) && roundId > 0) {
      roundId = Std.int(roundId / 10);
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    g2.font = game.ALT_FONT;

    // Display powerups
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

    var instruction1 = 'SPACEBAR TO START';
    g2.fontSize = 65;
    g2.color = Color.fromBytes(220, 220, 220);
    g2.centerString(instruction1, 503, 3);
    g2.color = (switchColor) ? Color.Yellow : Color.White;
    g2.centerString(instruction1, 500);

    g2.fontSize = 43;
    g2.color = (switchColor) ? Color.White : Color.Red;
    g2.centerString('OR ENTER LEVEL', 575);

    // Display level
    if (roundId > 0) {
      g2.color = Color.White;
      g2.fontSize = 54;
      g2.centerString(Std.string(roundId), 625);
    }

    // Display Taito
    g2.color = Color.fromBytes(128, 128, 128);
    g2.fontSize = 32;
    var taito = [ 'Based on original Arkanoid game', 'by Taito Corporation 1986' ];
    for (i in 0...taito.length) {
      g2.centerString(taito[i], 700 + (i * g2.fontSize));
    }

    // Update display count
    displayCount++;
  }
}
