import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

using Graphics2Extension;
import input.Input;
import rounds.RawRound;
import rounds.RoundsBuilder;
import scenes.DemoAnimationScene;
import scenes.RoundScene;
import scenes.TitleScene;

class Game {
  public static inline var WIDTH = 600;
  public static inline var HEIGHT = 800;
  public static inline var FPS = 60;

  public var input(default,null):Input = new Input();
  public var rounds(default,never):Array<RawRound> = RoundsBuilder.rounds();

  public var score(default,set):Int = 0;
  function set_score(value) {
    if (value > settings.highScore) {
      settings.highScore = value;
      Settings.write(SETTINGS_FILENAME, settings);
    }
    return score = value;
  }

  public var debugMode:Bool = false;
  public var pause:Bool = false;

  public var scene:Scene;

  static inline var SETTINGS_FILENAME = 'settings';
  var settings:GameSettings;

  var fps:Int = 0;
  var frame:Int = 0;
  var previousTime:Float = Scheduler.realTime();

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
    input.bind(Key(Decimal), (_)->{ debugMode = !debugMode; });
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
    input.bind(Key(Pause), (_)->{ pause = !pause; });
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
    var data = RoundsBuilder.load('demo_world');
    var round = RoundsBuilder.cook(data);
    scene = new RoundScene(this, round, 0);
  }

  public function switchToRound(id:Int, lives:Int = 3):Void {
    if (id <= 0 || id > rounds.length) {
      backToTitle();
      return;
    }
    var round = RoundsBuilder.cook(rounds[id - 1]);
    scene = new RoundScene(this, round, lives);
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
    // FPS
    frame++;
    if (frame % FPS == 0) {
      frame = 0;
      var time = Scheduler.realTime();
      var dt = (time - previousTime) / FPS;
      fps = Math.round(1 / dt);
      previousTime = time;
    }

    final g2 = framebuffers[0].g2;
    g2.begin();

    if (debugMode) {
      // Display debug informations
      g2.color = Color.Yellow;
      g2.font = Assets.fonts.optimus;
      g2.fontSize = 30;
      g2.rightString('FPS:$fps', WIDTH - 10, 10);
    }
    else {
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
    }

    // Display scene
    scene.render(g2);

    g2.end();
  }
}
