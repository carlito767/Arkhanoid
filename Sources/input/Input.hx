package input;

import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;
import kha.input.Mouse as KhaMouse;

typedef InputHandler = InputEventType->Void;

typedef InputEvent = {
  type:InputEventType,
  handler:InputHandler,
}

class Input {
  public var keyboard(default, null):Null<KhaKeyboard> = null;
  public var mouse(default, null):Null<KhaMouse> = null;

  var bindings:Map<InputEventType, InputHandler> = new Map();
  var events:List<InputEvent> = new List();

  public function new() {
    // Initialize keyboard
    keyboard = KhaKeyboard.get();
    if (keyboard != null) {
      keyboard.notify(onKeyDown, onKeyUp, null);
    }

    // Initialize mouse
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function update():Void {
    for (event in events) {
      event.handler(event.type);
    }
    events.clear();
  }

  //
  // Bindings
  //

  public function bind(type:InputEventType, handler:InputHandler):Void {
    bindings.set(type, handler);
  }

  public function bindMulti(types:Array<InputEventType>, handler:InputHandler):Void {
    for (type in types) {
      bind(type, handler);
    }
  }

  public function clearBindings():Void {
    // TODO: update Kha for Map.clear()
    // https://github.com/HaxeFoundation/haxe/issues/2550
    bindings = new Map();
  }

  //
  // Keyboard callbacks
  //

  function onKeyDown(key:KeyCode):Void {
    var handler = bindings.get(Key(key));
    if (handler != null) {
      events.add({type:Key(key), handler:handler});
    }
  }

  function onKeyUp(key:KeyCode):Void {
  }

  //
  // Mouse callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    var handler = bindings.get(Mouse(button));
    if (handler != null) {
      events.add({type:Mouse(button), handler:handler});
    }
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
  }

  function onMouseWheel(delta:Int):Void {
  }
}
