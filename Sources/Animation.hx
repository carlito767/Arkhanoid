import kha.Image;

typedef Animation = {
  images:List<Image>,
  // Animate each 'step' frames
  step:Int,
  // Frames in cycle (-1 for no cycle)
  cycle:Int,
  // Frames since animation start
  heartbeat:Int,
}
