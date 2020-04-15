import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Game {
  public function new() {
    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  function update():Void {
  }

  function render(framebuffers:Array<Framebuffer>):Void {
  }
}
