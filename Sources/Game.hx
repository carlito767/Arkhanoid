import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import rounds.IRound;
import rounds.Round1;
import rounds.RoundFactory;

import states.GameStartState;
import states.StartState;

class Game {
  public final MAIN_FONT = Assets.fonts.generation;
  public final ALT_FONT = Assets.fonts.optimus;

  public var keyboard(default, never):Keyboard = new Keyboard();
  public var mouse(default, never):Mouse = new Mouse();

  public var rounds(default, null):Array<RoundFactory>;
  public var round:Null<IRound>;

  var settings:SettingsData;

  var score:Int;

  var state:IProcess;

  public function new() {
    // Hide mouse
    mouse.lock();

    // Read settings
    settings = Settings.read();
    settings.highScore = 99999;

    // Initialize game
    score = 0;

    // Initialize rounds
    // https://haxe.org/blog/codingtips-new/
    rounds = [
      Round1.new,
    ];

    // Initialize state
    switchToRound(0);

    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  public function switchToRound(roundId:Int):Void {
    if (roundId <= 0 || roundId > rounds.length) {
      round = null;
      state = new StartState();
    }
    else {
      var roundFactory = rounds[roundId - 1];
      round = roundFactory();
      state = new GameStartState();
    }
  }

  function update():Void {
    state.update(this);
    keyboard.update();
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
    state.render(this, g2);

    g2.end();
  }
}
