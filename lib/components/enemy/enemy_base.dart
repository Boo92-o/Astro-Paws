import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/components/player.dart';
import '/astro_paws.dart';
import 'dart:async'; // для Timer
import '../bullet.dart';
import '../explosion.dart';

enum EnemyType {
  one,
  two,
  three,
  four,
}

class EnemyBase extends SpriteAnimationComponent
    with HasGameReference<AstroPawsGame>, CollisionCallbacks {
  final double enemySize;
  int enemyLife;
  final String enemySpritePath;
  final EnemyType enemySpeed;
  final bool enemyNeedsAnimation;
  bool _canDealDamage = true; // флаг урона
  final double damageCooldown = 1.0; // 1 секунда между ударами
  final int damageAmount = 20; // сколько урона наносит враг

  EnemyBase({
    super.position,
    required this.enemySize,
    required this.enemyLife,
    required this.enemySpritePath,
    required this.enemySpeed,
    this.enemyNeedsAnimation = true,
  }) : super(
    size: Vector2.all(enemySize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (enemyNeedsAnimation) {
      animation = await game.loadSpriteAnimation(
        enemySpritePath,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.5,
          textureSize: Vector2(62, 62),
        ),
      );
    } else {
      // Статичный враг (один кадр)
      animation = SpriteAnimation.spriteList(
        [
          await game.loadSprite(enemySpritePath),
        ],
        stepTime: double.infinity,


      );


    }

    // hitbox других размеров лучше всего
    add(RectangleHitbox.relative(
      Vector2(1.5, 0.5), // 50% ширины и высоты от спрайта
      parentSize: size,
      anchor: Anchor.center,
      position: Vector2.zero(), // точно по центру
    ));

  }

  double get speed {
    switch (enemySpeed) {
      case EnemyType.one:
        return 60;
      case EnemyType.two:
        return 120;
      case EnemyType.three:
        return 180;
      case EnemyType.four:
        return 240;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * speed;
    if (position.y > game.size.y) {
      removeFromParent();
    }

  }

  @override
  void onCollision(Set<Vector2> _, PositionComponent other) {
    if (other is Player) {
      if (_canDealDamage) {
        game.PlayerHP -= damageAmount;
       /* print('Игрок получил урон! HP: ${game.PlayerHP}');*/

        // Проверяем смерть игрока
        if (game.PlayerHP <= 0) {
/*          print('HP = 0 → Game Over');*/
          game.gameOver();
        }

        // ⚡ Блокируем урон на 1 секунду
        _canDealDamage = false;
        Future.delayed(Duration(seconds: damageCooldown.toInt()), () {
          _canDealDamage = true;
        });
      }
    }

    if (other is Bullet && position.y > 8) {
      if (enemyLife > 1) {
        enemyLife -= 1;
        other.removeFromParent();
        return;
      }

      removeFromParent();
      game.add(Explosion(position: position));
      other.removeFromParent();
      game.currentScore++;
    }

    super.onCollision(_, other);
  }
}

