import kha.Scheduler;
import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;

class Keyboard {
  var keyboard:Null<KhaKeyboard> = null;
  var down:Map<KeyCode, Bool> = new Map();
  var downDuration:Map<KeyCode, Float> = new Map();

  var previousTime:Float = Scheduler.time();

  public function new() {
    keyboard = KhaKeyboard.get();
    if (keyboard != null) {
      keyboard.notify(onKeyDown, onKeyUp, null);
    }
  }

  public function update():Void {
    var currentTime = Scheduler.time();
    var dt = currentTime - previousTime;
    previousTime = currentTime;

    for (k => v in downDuration) {
      downDuration[k] = v + dt;
    }
  }

  public function isDown(key:KeyCode):Bool {
    return (down[key] == true);
  }

  public function isPressed(key:KeyCode):Bool {
    return (down[key] == true && downDuration[key] == 0.0);
  }

  public function numberPressed():Null<Int> {
    for (keyCode in [ KeyCode.Zero, KeyCode.One, KeyCode.Two, KeyCode.Three, KeyCode.Four, KeyCode.Five, KeyCode.Six, KeyCode.Seven, KeyCode.Eight, KeyCode.Nine ]) {
      if (isPressed(keyCode)) {
        return keyCode - KeyCode.Zero;
      }
    }
    for (keyCode in [ KeyCode.Numpad0, KeyCode.Numpad1, KeyCode.Numpad2, KeyCode.Numpad3, KeyCode.Numpad4, KeyCode.Numpad5, KeyCode.Numpad6, KeyCode.Numpad7, KeyCode.Numpad8, KeyCode.Numpad9 ]) {
      if (isPressed(keyCode)) {
        return keyCode - KeyCode.Numpad0;
      }
    }
    return null;
  }

  //
  // Callbacks
  //

  function onKeyDown(key:KeyCode):Void {
    down[key] = true;
    downDuration[key] = 0.0;
  }

  function onKeyUp(key:KeyCode):Void {
    down.remove(key);
    downDuration.remove(key);
  }
}
