import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import input.Input;
import rounds.Round;
import rounds.Round1;
import rounds.Round2;
import rounds.RoundFactory;
import states.GameStartState;
import states.StartState;
import states.State;

class Game {
  public static inline var WIDTH = 600;
  public static inline var HEIGHT = 800;
  public static inline var FPS = 60;

  public static inline var SETTINGS_FILENAME = 'settings';

  public final MAIN_FONT = Assets.fonts.generation;
  public final ALT_FONT = Assets.fonts.optimus;

  public var input(default, null):Input = new Input();

  public var rounds(default, null):Array<RoundFactory>;
  public var round:Round;

  public var state:State;

  var settings:GameSettings;

  public function new() {
    // Hide mouse
    if (input.mouse != null) {
      input.mouse.lock();
    }

    // Read settings
    settings = Settings.read(SETTINGS_FILENAME, {
      v:1,
      highScore:0,
    });
    settings.highScore = 99999;

    // Initialize rounds
    // https://haxe.org/blog/codingtips-new/
    rounds = [
      Round1.new,
      Round2.new,
      Round.new,
      Round.new,
      Round.new,
    ];

    // Initialize state
    round = new Round(0);
    switchToRound(0);

    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  public function switchToRound(id:Int):Void {
    if (id <= 0 || id > rounds.length) {
      state = new StartState(this);
    }
    else {
      var roundFactory = rounds[id - 1];
      round = roundFactory(id, round.lives);
      state = new GameStartState(this);
    }
  }

  function update():Void {
    input.update();
    state.update();
  }

  function render(framebuffers:Array<Framebuffer>):Void {
    final g2 = framebuffers[0].g2;
    g2.begin();

    // Display logo
    g2.color = Color.White;
    g2.drawImage(Assets.images.logo, 5, 0);

    // Display scores
    g2.font = MAIN_FONT;
    g2.fontSize = 18;

    g2.color = Color.fromBytes(230, 0, 0);
    g2.drawString('1UP', WIDTH - 70, 10);
    g2.drawString('HIGH SCORE', WIDTH - 205, 75);

    g2.color = Color.White;
    var scoreString = Std.string(round.score);
    var scoreWidth = g2.font.width(g2.fontSize, scoreString);
    g2.drawString(scoreString, WIDTH - scoreWidth - 10, 35);
    var highScoreString = Std.string(settings.highScore);
    var highScoreWidth = g2.font.width(g2.fontSize, highScoreString);
    g2.drawString(highScoreString, WIDTH - highScoreWidth - 10, 100);

    // Display state
    state.render(g2);

    g2.end();
  }

  public function switchMouseLock():Void {
    if (input.mouse != null) {
      if (input.mouse.isLocked()) {
        input.mouse.unlock();
      }
      else {
        input.mouse.lock();
      }
    }
  }
}
