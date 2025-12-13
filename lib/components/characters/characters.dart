import 'character_data.dart';
import 'package:flame/components.dart';

class Characters {
  static final CharacterData cat = CharacterData(
    name: "Captain Whiskers",
    spriteSheet: "player.png",
    frames: 3,
    frameSize: Vector2(96, 96),
  );

  static final CharacterData roboCat = CharacterData(
    name: "Robo Kitty",
    spriteSheet: "robo_player.png",
    frames: 4,
    frameSize: Vector2(96, 96),
  );

  static final CharacterData demonCat = CharacterData(
    name: "Demon Cat",
    spriteSheet: "Nairan.png",
    frames: 6,
    frameSize: Vector2(96, 96),
  );

  static List<CharacterData> all = [
    cat,
    roboCat,
    demonCat,
  ];
}
