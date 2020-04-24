package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

import input.InputEventType;

typedef PowerupData = {
  anim:Animation,
  name:String,
  desc:String,
}

class StartState extends State {
  var displayCount:Int = 0;

  var powerups:Array<PowerupData>;
  var roundId:Int;

  public function new(game:Game) {
    super(game);

    powerups = [
      { anim:AnimationTools.loadSequence('powerup_laser'), name:'laser', desc:'enables the vaus\nto fire a laser' },
      { anim:AnimationTools.loadSequence('powerup_slow'), name:'slow', desc:'slow down the\nenergy ball' },
      { anim:AnimationTools.loadSequence('powerup_life'), name:'extra life', desc:'gain an additional\nvaus' },
      { anim:AnimationTools.loadSequence('powerup_expand'), name:'expand', desc:'expands the vaus' },
      { anim:AnimationTools.loadSequence('powerup_catch'), name:'catch', desc:'catches the energy\nball' },
      { anim:AnimationTools.loadSequence('powerup_duplicate'), name:'duplicate', desc:'duplicates the energy\nball' },
    ];
    roundId = 0;

    // Input bindings
    game.input.clearBindings();
    game.input.bind(Mouse(Left), game.switchMouseLock);
    game.input.bind(Key(Backspace), function(type:InputEventType) {
      if (roundId > 0) {
        roundId = Std.int(roundId / 10);
      }
    });
    game.input.bindMulti([Key(Space), Key(Return)], function(type:InputEventType) {
      if (roundId == 0) {
        roundId = 1;
      }
      game.switchToRound(roundId);
    });
    game.input.bindMulti(numericTypes(), function(type:InputEventType) {
      var n = number(type);
      if (n != null && (n > 0 || roundId > 0)) {
        var r = roundId * 10 + n;
        if (r <= game.rounds.length) {
          roundId = r;
        }
      }
    });
  }

  override function render(g2:Graphics):Void {
    g2.font = game.ALT_FONT;

    // Display powerups
    g2.color = Color.White;
    g2.fontSize = 46;
    g2.drawString('POWERUPS', 210, 200);

    var left = 30;
    var top = 270;
    for (powerup in powerups) {
        // Image
        var image = (displayCount % 4 == 0) ? AnimationTools.cycle(powerup.anim) : powerup.anim.first();
        g2.color = Color.White;
        g2.drawImage(image, left, top);
        // Name
        g2.color = Color.White;
        g2.fontSize = 29;
        g2.drawString(powerup.name.toUpperCase(), left + image.width + 20, top - 3);
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

  //
  // Numeric Event Types
  //

  function numericTypes():Array<InputEventType> {
    return [
      Key(Zero), Key(One), Key(Two), Key(Three), Key(Four), Key(Five), Key(Six), Key(Seven), Key(Eight), Key(Nine),
      Key(Numpad0), Key(Numpad1), Key(Numpad2), Key(Numpad3), Key(Numpad4), Key(Numpad5), Key(Numpad6), Key(Numpad7), Key(Numpad8), Key(Numpad9),
    ];
  }

  function number(type:InputEventType):Null<Int> {
    switch (type) {
      case Key(key):
        switch (key) {
          case Zero | One | Two | Three | Four | Five | Six | Seven | Eight | Nine:
            return key - Zero;
          case Numpad0 | Numpad1 | Numpad2 | Numpad3 | Numpad4 | Numpad5 | Numpad6 | Numpad7 | Numpad8 | Numpad9:
            return key - Numpad0;
          case _:
            return null;
        }
        return null;
      case _:
        return null;
    }
  }
}
