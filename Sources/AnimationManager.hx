import kha.Assets;

class AnimationManager {
  public static function fromSequence(id:String):Animation {
    var sequence:Array<String> = [];
    var count = 1;
    while (true) {
      var spriteId = '${id}_${count}';
      if (Assets.images.get(spriteId) == null) {
        break;
      }
      sequence.push(spriteId);
      count++;
    }
    return {
      sequence:sequence,
      current:1,
    }
  }

  public static function next(animation:Animation) {
    animation.current = (animation.current + 1) % animation.sequence.length;
  }
}
