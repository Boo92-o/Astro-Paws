import 'package:flutter/material.dart';
import '/astro_paws.dart';

import '../high_score_manager.dart';

class PauseMenu extends StatefulWidget {

  final AstroPawsGame game;

  const PauseMenu({required this.game, super.key});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  @override
  Widget build(BuildContext context) {
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 300,
          width: 400,
          decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t let the lemons win!',
                style: TextStyle(
                  fontSize: 24,
                  color: whiteTextColor,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  widget.game.resumeEngine();
                  widget.game.overlays.remove('Pause');
                },
                child: const Text('Back to Fight',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                  ),),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                 widget.game.audioManager?.stopMusic();
                },
                child: const Text('Music Stop',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}