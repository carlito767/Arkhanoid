import kha.input.Mouse as KhaMouse;

class Mouse {
  var mouse:Null<KhaMouse> = null;

  public function new() {
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function lock():Void {
    if (mouse != null && !mouse.isLocked()) {
      mouse.lock();
    }
  }

  //
  // Callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    lock();
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
  }

  function onMouseWheel(delta:Int):Void {
  }
}
