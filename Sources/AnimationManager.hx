import kha.Assets;
import kha.Image;

class AnimationManager {
  public static function fromSequence(id:String):Animation {
    var sequence:Array<Image> = [];
    while (true) {
      var image = Assets.images.get('${id}_${sequence.length + 1}');
      if (image == null) {
        break;
      }
      sequence.push(image);
    }
    if (sequence.length == 0) {
      throw 'No image for "$id"';
    }
    return {
      sequence:sequence,
      current:0,
    }
  }

  public static function current(animation:Animation):Image {
    return animation.sequence[animation.current];
  }

  public static function next(animation:Animation):Image {
    animation.current = (animation.current + 1) % animation.sequence.length;
    return animation.sequence[animation.current];
  }

  public static function end(animation:Animation):Bool {
    return (animation.current >= animation.sequence.length - 1);
  }
}
