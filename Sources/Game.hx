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
import states.DemoState;
import states.GameStartState;
import states.StartState;
import states.State;

class Game {
  public static inline var WIDTH = 600;
  public static inline var HEIGHT = 800;
  public static inline var FPS = 60;

  public static inline var LIVES = 3;

  public final MAIN_FONT = Assets.fonts.generation;
  public final ALT_FONT = Assets.fonts.optimus;

  public var input(default,null):Input = new Input();

  public var rounds(default,null):Array<RoundFactory>;

  public var state:State;

  public var score(default,set):Int = 0;
  function set_score(value) {
    if (value > settings.highScore) {
      settings.highScore = value;
      Settings.write(SETTINGS_FILENAME, settings);
    }
    return score = value;
  }

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
    backToTitle();

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

  public function showDemo():Void {
    state = new DemoState(this);
  }

  public function switchToRound(id:Int, lives:Int = LIVES):Void {
    var roundFactory = rounds[id - 1];
    if (roundFactory != null) {
      var round = roundFactory(id, lives);
      state = new GameStartState(this, round);
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
    var scoreString = Std.string(score);
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
