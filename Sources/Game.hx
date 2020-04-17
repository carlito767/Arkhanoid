import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import rounds.IRound;
import rounds.Round1;
import rounds.RoundFactory;

import screens.GameScreen;
import screens.Screen;
import screens.StartScreen;

class Game {
  public static var ME:Game;

  public final MAIN_FONT = Assets.fonts.generation;
  public final ALT_FONT = Assets.fonts.optimus;

  public var maxRound(get,never):Int; inline function get_maxRound() return rounds.length;

  public var keyboard:Keyboard = new Keyboard();
  public var mouse:Mouse = new Mouse();

  var settings:SettingsData;
  var playerScore:Int;

  var rounds:Array<RoundFactory>;
  var screen:Screen;

  public function new() {
    ME = this;

    // Hide mouse
    mouse.lock();

    // Read settings
    settings = Settings.read();
    settings.highScore = 99999;

    // Initialize player score
    playerScore = 0;

    // Initialize rounds
    // https://haxe.org/blog/codingtips-new/
    rounds = [
      Round1.new,
    ];

    // Initialize current screen
    switchTo(0);

    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  public function switchTo(round:Int):Void {
    if (round <= 0 || round > rounds.length) {
      screen = new StartScreen();
    }
    else {
      var roundFactory = rounds[round - 1];
      screen = new GameScreen(roundFactory);
    }
  }

  function update():Void {
    screen.update();
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
    var playerScoreString = Std.string(playerScore);
    var playerScoreWidth = g2.font.width(g2.fontSize, playerScoreString);
    g2.drawString(playerScoreString, WIDTH - playerScoreWidth - 10, 35);
    var highScoreString = Std.string(settings.highScore);
    var highScoreWidth = g2.font.width(g2.fontSize, highScoreString);
    g2.drawString(highScoreString, WIDTH - highScoreWidth - 10, 100);

    // Display screen
    screen.render(g2);

    g2.end();
  }
}
