import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;

class Keyboard {
  var keyboard:Null<KhaKeyboard> = null;
  var isDown:Map<KeyCode, Bool> = new Map();

  public function new() {
    keyboard = KhaKeyboard.get();
    if (keyboard != null) {
      keyboard.notify(onKeyDown, onKeyUp, null);
    }
  }

  public function isPressed(key:KeyCode):Bool {
    return (isDown[key] == true);
  }

  //
  // Callbacks
  //

  function onKeyDown(key:KeyCode):Void {
    isDown[key] = true;
  }

  function onKeyUp(key:KeyCode):Void {
    isDown.remove(key);
  }
}
