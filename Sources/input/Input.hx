package input;

import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;
import kha.input.Mouse as KhaMouse;

typedef InputHandler = InputEventType->Void;

typedef InputEvent = {
  type:InputEventType,
  handler:InputHandler,
}

typedef Bindings = Map<InputEventType, InputHandler>;

class Input {
  public var keyboard(default,null):Null<KhaKeyboard> = null;
  public var mouse(default,null):Null<KhaMouse> = null;

  var bindingsDown:Bindings = new Bindings();
  var bindingsUp:Bindings = new Bindings();
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

  public function bind(type:InputEventType, ?handlerDown:InputHandler, ?handlerUp:InputHandler):Void {
    if (handlerDown != null && bindingsDown.exists(type)) {
      trace('WARNING: Binding Down for $type already exist');
    }
    if (handlerDown == null) {
      bindingsDown.remove(type);
    }
    else {
      bindingsDown.set(type, handlerDown);
    }

    if (handlerUp != null && bindingsUp.exists(type)) {
      trace('WARNING: Binding Up for $type already exist');
    }
    if (handlerUp == null) {
      bindingsUp.remove(type);
    }
    else {
      bindingsUp.set(type, handlerUp);
    }
  }

  public function bindMulti(types:Array<InputEventType>, ?handlerDown:InputHandler, ?handlerUp:InputHandler):Void {
    for (type in types) {
      bind(type, handlerDown, handlerUp);
    }
  }

  public function clearBindings():Void {
    // TODO: update Kha for Map.clear()
    // https://github.com/HaxeFoundation/haxe/issues/2550
    bindingsDown = new Bindings();
    bindingsUp = new Bindings();
    events.clear();
  }

  //
  // Events
  //

  inline function addEvent(type:InputEventType, bindings:Bindings):Void {
    var handler = bindings.get(type);
    if (handler != null) {
      events.add({type:type, handler:handler});
    }
  }

  //
  // Keyboard callbacks
  //

  function onKeyDown(key:KeyCode):Void {
    addEvent(Key(key), bindingsDown);
  }

  function onKeyUp(key:KeyCode):Void {
    addEvent(Key(key), bindingsUp);
  }

  //
  // Mouse callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    addEvent(Mouse(button), bindingsDown);
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    addEvent(Mouse(button), bindingsUp);
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
  }

  function onMouseWheel(delta:Int):Void {
  }
}
