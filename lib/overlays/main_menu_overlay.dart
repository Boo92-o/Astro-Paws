import 'package:flutter/material.dart';
import '../astro_paws.dart';
import '../utils/assets.dart';



class MainMenuOverlay extends StatefulWidget    {
  final AstroPawsGame game;

  MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => MainMenuOverlayState();
}

class MainMenuOverlayState extends State<MainMenuOverlay> {




 @override
 void initState(){
   super.initState();
   widget.game.audioManager?.playMusic('music.ogg');
}

 @override
 void dispose(){
   super.dispose();
   widget.game.audioManager?.stopMusic();
 }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Затемнение фона
        Container(color: Colors.black.withOpacity(0.6)),

        // Меню
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The   Last    Starfighter ',
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 63, color: Colors.purple)],
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('MainMenu');
                  widget.game.initializeGame();
                  widget.game.resumeEngine();
                  widget.game.audioManager?.playMusic(Assets.assetsAudioMusic);
                  Assets.restartBoss = true;
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'START GAME',
                  style: TextStyle(fontSize: 23, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Позже можно добавить выбор персонажей
                  widget.game.overlays.remove('MainMenu');
                  widget.game.overlays.add('SkinMenu');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'SELECT CHARACTER',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }




}
