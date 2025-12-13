import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '/astro_paws.dart';

/// Единый интерфейс жизней и очков
class LifeInterface extends PositionComponent
    with HasGameReference<AstroPawsGame> {
  late final RectangleComponent _playerHpBg;
  late final RectangleComponent _playerHpBar;
  late final RectangleComponent _bossHpBg;
  late final RectangleComponent _bossHpBar;
  late final TextComponent _scoreText;

  double _playerMaxHp = 100;
  double _bossMaxHp = 200;

  LifeInterface();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(10, 10);
    size = Vector2(game.size.x - 20, 30);

    // 🔹 Фон и полоса игрока
    _playerHpBg = RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(150, 12),
      paint: Paint()..color = Colors.grey.shade800,
    );
    _playerHpBar = RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(150, 12),
      paint: Paint()..color = Colors.greenAccent,
    );

    // 🔹 Фон и полоса босса
    _bossHpBg = RectangleComponent(
      position: Vector2(size.x - 195, 0),
      size: Vector2(150, 12),
      paint: Paint()..color = Colors.grey.shade800,
    );
    _bossHpBar = RectangleComponent(
      position: Vector2(size.x - 195, 0),
      size: Vector2(150, 12),
      paint: Paint()..color = Colors.redAccent,
    );

    // 🔹 Текст очков
    _scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2 - 40, -4),
    );

    addAll([
      _playerHpBg,
      _playerHpBar,
      _bossHpBg,
      _bossHpBar,
      _scoreText,
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // === HP игрока ===
    double playerHpPercent =
    (game.PlayerHP / _playerMaxHp).clamp(0, 1).toDouble();
    _playerHpBar.size.x = 150 * playerHpPercent;
    _playerHpBar.paint.color = playerHpPercent > 0.5
        ? Colors.greenAccent
        : playerHpPercent > 0.25
        ? Colors.orangeAccent
        : Colors.redAccent;

    // === HP босса ===
    if (game.isBossActive) {
      double bossHpPercent =
      (game.BossHp / _bossMaxHp).clamp(0, 1).toDouble();
      _bossHpBar.size.x = 150 * bossHpPercent;
      _bossHpBg.opacity = 1;
      _bossHpBar.opacity = 1;
    } else {
      _bossHpBg.opacity = 0;
      _bossHpBar.opacity = 0;
    }

    // === Очки ===
    _scoreText.text = 'Score: ${game.currentScore}';
  }
}
