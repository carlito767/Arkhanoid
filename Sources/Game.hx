import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import input.Input;
import rounds.Round;
import rounds.RoundDataFactory;
import rounds.RoundsBuilder;
import scenes.DemoAnimationScene;
import scenes.DemoWorldScene;
import scenes.RoundScene;
import scenes.TitleScene;
using Graphics2Extension;

class Game {
  public static inline var WIDTH = 600;
  public static inline var HEIGHT = 800;
  public static inline var FPS = 60;

  public var input(default,null):Input = new Input();
  public var rounds(default,never):Array<RoundDataFactory> = RoundsBuilder.rounds();

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

  public var debugMode:Bool = false;
  public var godMode:Bool = false;
  public var pause:Bool = false;

  public var scene:Scene;

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

    // Initialize scene
    backToTitle();

    // Initialize game loop
    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  //
  // Input bindings
  //

  public function resetBindings():Void {
    input.clearBindings();

    #if debug
    input.bind(Key(D), (_)->{ debugMode = !debugMode; });
    input.bind(Key(G), (_)->{ godMode = !godMode; });
    input.bind(Key(H), (_)->{
      settings.highScore = 0;
      Settings.write(SETTINGS_FILENAME, settings);
    });
    #end

    input.bind(Mouse(Left), (_)->{
      if (input.mouse != null) {
        if (input.mouse.isLocked()) {
          input.mouse.unlock();
        }
        else {
          input.mouse.lock();
        }
      }
    });
    input.bind(Key(P), (_)->{ pause = !pause; });
  }

  //
  // Scenes
  //

  public function backToTitle():Void {
    scene = new TitleScene(this);
  }

  public function showDemoAnimation():Void {
    scene = new DemoAnimationScene(this);
  }

  public function showDemoWorld():Void {
    scene = new DemoWorldScene(this);
  }

  public function switchToRound(id:Int, lives:Int = 3):Void {
    if (id <= 0 || id > rounds.length) {
      backToTitle();
      return;
    }
    var roundDataFactory = rounds[id - 1];
    if (roundDataFactory != null) {
      var round = new Round(id, lives, roundDataFactory());
      scene = new RoundScene(this, round);
    }
  }

  //
  // Game loop
  //

  function update():Void {
    input.update();
    if (!pause) {
      scene.update();
    }
  }

  function render(framebuffers:Array<Framebuffer>):Void {
    final g2 = framebuffers[0].g2;
    g2.begin();

    // Display logo
    g2.color = Color.White;
    g2.drawImage(Assets.images.logo, 5, 0);

    // Display scores
    g2.font = Assets.fonts.generation;
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

    // Display scene
    scene.render(g2);

    g2.end();
  }
}
