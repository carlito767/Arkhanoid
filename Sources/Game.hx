import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Game {
  var mouse:Mouse;

  public function new() {
    // Hide mouse
    var mouse = new Mouse();
    mouse.lock();

    Scheduler.addTimeTask(update, 0, 1 / FPS);
    System.notifyOnFrames(render);
  }

  function update():Void {
  }

  function render(framebuffers:Array<Framebuffer>):Void {
    final g2 = framebuffers[0].g2;
    g2.begin();

    g2.drawImage(Assets.images.logo, 5, 0);

    g2.end();
  }
}
