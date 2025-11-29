

import 'package:astro_paws/components/fuel.dart';
import 'package:astro_paws/components/gradient_background.dart';
import 'package:astro_paws/hud/pause_button.dart';
import 'package:astro_paws/utils/assets.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '/components/bullet.dart';
import 'components/audio.dart';
import 'components/enemy/enemy_base.dart';
import '/components/player.dart';
import 'hud/main_hud.dart';
import 'dart:async' as async;
import 'components/explosion.dart';
import 'high_score_manager.dart';
import 'components/enemy/boss.dart';
import 'overlays/boss_interface_life.dart';
import 'overlays/interface_life.dart';


class AstroPawsGame extends FlameGame with PanDetector, HasCollisionDetection {
  late Player player;
  int currentScore = 0;
  DateTime pawShieldTime = DateTime.now();
  bool hasKibble = false;
  DateTime kibbleTime = DateTime.now();
  late Timer _bossTimer;
  bool _isBossActive = false;
  bool get isBossActive => _isBossActive;
  List<SpawnComponent> _enemySpawners = [];
  ParallaxComponent? _starsParallax;
  late double period = count;
  late double count = 1;
  async.Timer? _countTimer;
  late double period2 = count2;
  late double count2 = 5;
  late double period3 = count3;
  late double count3 = 9;
  late final AudioManager audioManager;
  int PlayerHP = 100;
  bool hasPawShield = true;
  int BossHp = 200;

  void updateCount() {
    _countTimer?.cancel();
    const duration = Duration(seconds: 5);

    _countTimer = async.Timer.periodic(duration, (async.Timer t) {
      count -= 0.2;
      period = count;
      debugPrint('Count updated: $count');
    });
    _countTimer = async.Timer.periodic(duration, (async.Timer t) {
      count2 -= 0.2;
      period2 = count2;
      debugPrint('Count2 updated: $count2');
    });
    _countTimer = async.Timer.periodic(duration, (async.Timer t) {
      count3 -= 0.2;
      period3 = count3;
      debugPrint('Count3 updated: $count3');
    });
  }

  void stopTimer() {
    _countTimer?.cancel();
  }


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // debugMode = true;

    add(GradientBackground(colors: [
      const Color(0xFF0A0717),
      const Color(0xFF17112F),
      const Color(0xFF1E163D),
      const Color(0xFF291D54),
      const Color(0xFF261860)
    ]));
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('stars.png'),
        ParallaxImageData('stars_2.png'),
      ],
      baseVelocity: Vector2(0, -1),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
      size: size,
      velocityMultiplierDelta: Vector2(0, 3),
    );
    add(parallax);

    // ↓↓↓ ДОБАВЬТЕ ИНИЦИАЛИЗАЦИЮ БОССА ЗДЕСЬ ↓↓↓
    _bossTimer = Timer(60, repeat: true, onTick: _spawnBoss);
    _bossTimer.start();
    updateCount();

  }

  void initializeGame() {
    hasPawShield = false; // сброс перед добавлением игрока
    PlayerHP = 100;

    add(HealthBarInterface());

    if (_isBossActive) {
      add(BossInterfaceLife());
/*      _changeToBossBackground();*/
    }

    player = Player(Player.new);

    add(player);



    //Spawn different enemies at different intervals

    addEnemies();

    addPowerUps();

    add(MainHud());
  }

  void addPowerUps() {
    add(SpawnComponent(
        period: 73,
        factory: (index) {
          return Fuel(
              fuelSize: 32, fuelSpritePath: Assets.PlayerMoving, fuelType: FuelType.paw);
        },
        area: Rectangle.fromLTWH(
          size.x * 0.1,
          0,
          size.x * 0.8,
          -30,
        )));

    add(SpawnComponent(
        period: 39,
        factory: (index) {
          return Fuel(
              fuelSize: 50,
              fuelSpritePath: Assets.KibblePower,
              fuelType: FuelType.kibble);
        },
        area: Rectangle.fromLTWH(size.x * 0.1, 0, size.x * 0.8, -30)));
  }

  void addEnemies() {
    // Очищаем список перед добавлением новых спавнеров
    _enemySpawners.clear();

    final enemySpawner1 = SpawnComponent(
      period: 0.3,
      factory: (index) {
        return EnemyBase(
          enemySize: 64,
          enemyLife: 1,
          enemySpritePath: Assets.EnemyMoving,
          enemySpeed: EnemyType.three,
          enemyNeedsAnimation: true,
        );
      },
      area: Rectangle.fromLTWH(
        size.x * 0.1,
        0,
        size.x * 0.8,
        -64,
      ),
    );
    add(enemySpawner1);
    _enemySpawners.add(enemySpawner1);

    final enemySpawner2 = SpawnComponent(
        period: 9,
        factory: (index) {
          return EnemyBase(
              enemyNeedsAnimation: false,
              enemySize: 80,
              enemyLife: 3,
              enemySpritePath: Assets.CucumberEnemy,
              enemySpeed: EnemyType.two);
        },
        area: Rectangle.fromLTWH(
          size.x * 0.1,
          0,
          size.x * 0.8,
          -64,
        ));
    add(enemySpawner2);
    _enemySpawners.add(enemySpawner2);

    final enemySpawner3 = SpawnComponent(
        period: 17,
        factory: (index) {
          return EnemyBase(
              enemyNeedsAnimation: false,
              enemySize: 120,
              enemyLife: 5,
              enemySpritePath: Assets.LizardEnemy,
              enemySpeed: EnemyType.one);
        },
        area: Rectangle.fromLTWH(
          size.x * 0.1,
          0,
          size.x * 0.8,
          -64,
        ));
    add(enemySpawner3);
    _enemySpawners.add(enemySpawner3);
  }

  void _spawnBoss() {
    if (!_isBossActive) {
      _isBossActive = true;
      add(Boss());
/*      _changeToBossBackground();*/
      _reduceAsteroidSpawn();
    }
  }

  void onBossDefeated() {
    _isBossActive = false;
/*    _changeToNormalBackground();*/
    _restoreAsteroidSpawn();

    _bossTimer.stop();
    _bossTimer.start();

    print('Босс побежден! Следующий через 60 секунд');
  }

  void _changeToBossBackground() {
    children.whereType<GradientBackground>().forEach((bg) => bg.removeFromParent());


  }

  void _changeToNormalBackground() {
    children.whereType<GradientBackground>().forEach((bg) => bg.removeFromParent());

    add(GradientBackground(colors: [
      const Color(0xFF0A0717),
      const Color(0xFF17112F),
      const Color(0xFF1E163D),
      const Color(0xFF291D54),
      const Color(0xFF261860)
    ]));
  }

  void _reduceAsteroidSpawn() {
    // Полностью останавливаем спавн врагов
    for (final spawner in _enemySpawners) {
      spawner.timer.stop(); // Полная остановка таймера
    }
    print('Спавн врагов полностью остановлен');
  }

  void _restoreAsteroidSpawn() {
    // Возобновляем спавн врагов
    for (final spawner in _enemySpawners) {
      spawner.timer.start(); // Запускаем таймер снова
    }
    print('Спавн врагов возобновлен');
  }



  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.moveTo(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bossTimer.update(dt);
    print(PlayerHP);

  }



  Future<void> gameOver() async {
    overlays.add('GameOver');

    pauseEngine();

    final highScore = await HighScoreManager.getHighScore();
    if (currentScore > highScore) {
      await HighScoreManager.setHighScore(currentScore);
    }
  }


  void resetGame() {
    currentScore = 0;
    hasPawShield = false; // сброс перед добавлением игрока
    PlayerHP = 100;
    hasKibble = false;
    overlays.remove('GameOver');
    player.removeFromParent();
    children
        .whereType<EnemyBase>()
        .forEach((enemy) => enemy.removeFromParent());
    children.whereType<Bullet>().forEach((bullet) => bullet.removeFromParent());
    children.whereType<MainHud>().forEach((hud) => hud.removeFromParent());
    children
        .whereType<Explosion>()
        .forEach((explosion) => explosion.removeFromParent());
    children
        .whereType<SpawnComponent>()
        .forEach((spawn) => spawn.removeFromParent());
    children.whereType<Boss>().forEach((boss) => boss.removeFromParent());
    children.whereType<Fuel>().forEach((item) => item.removeFromParent());
    children
        .whereType<PauseButton>()
        .forEach((item) => item.removeFromParent());
    children.whereType<Player>().forEach((item) => item.removeFromParent());


    initializeGame();
    resumeEngine();
  }

}

