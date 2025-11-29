import 'package:flame/components.dart';
import '/astro_paws.dart';

class Explosion extends SpriteAnimationComponent with HasGameReference<AstroPawsGame> {
  final double explosionSize; // ДОБАВЬТЕ ЭТОТ ПАРАМЕТР

  Explosion({
    required Vector2 position,
    this.explosionSize = 1.0, // ЗНАЧЕНИЕ ПО УМОЛЧАНИЮ
  }) : super(
    position: position,
    size: Vector2.all(64 * explosionSize), // ИСПОЛЬЗУЕМ ПАРАМЕТР
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
      ),
    );

    // Автоматическое удаление после анимации
    add(TimerComponent(
      period: 0.6,
      onTick: removeFromParent,
      removeOnFinish: true,
    ));
  }
}