import 'package:astro_paws/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/astro_paws.dart';
import 'explosion.dart';

class Bullet extends SpriteComponent
    with HasGameReference<AstroPawsGame>, CollisionCallbacks {
  final double angleOffset;
  final bool isEnemyBullet;

  Bullet({
    required Vector2 position,
    this.angleOffset = 0.0,
    this.isEnemyBullet = false,
  }) : super(
    position: position,
    size: Vector2(6, 18),
    anchor: Anchor.center,
  );

  static const double bulletSpeed = 500; // чуть быстрее и стабильнее

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = false;

    sprite = await game.loadSprite(
      isEnemyBullet ? 'enemy_bullet.png' : 'bullet.png',
    );

    // Центрированный хитбокс
    add(RectangleHitbox.relative(
      Vector2(0.8, 0.8),
      parentSize: size,
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Вычисляем направление движения
    final velocity = isEnemyBullet ? bulletSpeed : -bulletSpeed;
    position.y += velocity * dt;

    // Корректно удаляем пулю, если она за пределами экрана
    if (position.y < -size.y || position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // === 1. Если вражеская пуля попала в игрока ===
    if (isEnemyBullet && other is Player) {
      game.PlayerHP -= 10; // Урон по игроку
      game.add(Explosion(position: other.position));
      if (game.PlayerHP < 0) game.PlayerHP = 0;

      // Эффект взрыва на игроке
      game.add(Explosion(position: other.position));

      // Удаляем пулю
      removeFromParent();



    }

    if (game.PlayerHP <= 0) {
      other.removeFromParent();
      (game as AstroPawsGame).gameOver();
    }
  }


}
