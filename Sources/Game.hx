import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import input.Input;
import rounds.Round;
import rounds.RoundDataFactory;
import rounds.RoundsBuilder;
import states.DemoAnimationState;
import states.DemoWorldState;
import states.GameStartState;
import states.StartState;
import states.State;
using Graphics2Extension;

class Game {
  public static inline var WIDTH = 600;
  public static inline var HEIGHT = 800;
  public static inline var FPS = 60;

  public final MAIN_FONT = Assets.fonts.generation;
  public final ALT_FONT = Assets.fonts.optimus;

  public var input(default,null):Input = new Input();
  public var rounds(default,never):Array<RoundDataFactory> = RoundsBuilder.rounds();
  public var state:State;

  public var score(default,set):Int = 0;
  function set_score(value) {
    if (value > settings.highScore) {
      settings.highScore = value;
      if (!godMode) {
        Settings.write(SETTINGS_FILENAME, settings);
      }
    }
    return score = value;
  }

  public var godMode:Bool = false;

  static inline var SETTINGS_FILENAME = 'settings';
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

    // Initialize state
    backToTitle();

    // Initialize game loop
    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  public function backToTitle():Void {
    state = new StartState(this);
  }

  public function resetHighScore():Void {
    settings.highScore = 0;
    Settings.write(SETTINGS_FILENAME, settings);
  }

  public function showDemoAnimation():Void {
    state = new DemoAnimationState(this);
  }

  public function showDemoWorld():Void {
    state = new DemoWorldState(this);
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

  public function switchToRound(id:Int, lives:Int = 3):Void {
    if (id <= 0 || id > rounds.length) {
      backToTitle();
      return;
    }
    var roundDataFactory = rounds[id - 1];
    if (roundDataFactory != null) {
      var round = new Round(id, lives, roundDataFactory());
      state = new GameStartState(this, round);
    }
  }

  //
  // Game loop
  //

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
    g2.rightString('1UP', WIDTH - 10, 10);
    g2.rightString('HIGH SCORE', WIDTH - 10, 75);

    g2.color = Color.White;
    g2.rightString(Std.string(score), WIDTH - 10, 35);
    g2.rightString(Std.string(settings.highScore), WIDTH - 10, 100);

    // Display "God Mode"
    if (godMode) {
      g2.color = Color.Yellow;
      g2.rightString('GOD MODE', WIDTH - 10, 125);
    }

    // Display state
    state.render(g2);

    g2.end();
  }
}
