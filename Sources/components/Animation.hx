package components;

import kha.Image;

typedef Animation = {
  images:Array<Image>,
  // Animate each 'step' frames
  step:Int,
  // Frames in cycle (-1 for no cycle)
  cycle:Int,
  // Frames since animation start
  heartbeat:Int,
  // Paused?
  paused:Bool,
}
