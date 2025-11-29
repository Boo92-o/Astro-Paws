import 'package:flame/components.dart';

class CharacterData {
  final String name;
  final String spriteSheet;
  final int frames;
  final Vector2 frameSize;

  const CharacterData({
    required this.name,
    required this.spriteSheet,
    required this.frames,
    required this.frameSize,
  });
}
