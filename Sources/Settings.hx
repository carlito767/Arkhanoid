import kha.Storage;

class Settings {
  static inline var FILENAME = 'settings';
  static inline var VERSION = 1;

  static var defaults:SettingsData = {
    v: VERSION,
    highScore: 0,
  };

  public static function read():SettingsData {
    var file = Storage.namedFile(FILENAME);
    var data:SettingsData = file.readObject();
    if (data != null && data.v == VERSION) {
      return data;
    }
    return defaults;
  }

  public static function write(settings:SettingsData):Void {
    var file = Storage.namedFile(FILENAME);
    settings.v = VERSION;
    file.writeObject(settings);
  }
}
