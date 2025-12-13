import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '/astro_paws.dart';

class SkinMenu extends StatefulWidget {
  final AstroPawsGame game;
  const SkinMenu({super.key, required this.game});

  @override
  State<SkinMenu> createState() => _SkinMenuState();
}

class _SkinMenuState extends State<SkinMenu> {
  int _currentIndex = 0;

  @override
  void initState(){
    super.initState();

    Timer(const Duration(seconds: 1), () => widget.game.audioManager?.playMusic('chose_music.mp3') );


/*    widget.game.audioManager?.playMusic('chose_music.mp3');*/
  }



  @override
  void dispose(){
    super.dispose();
    widget.game.audioManager?.stopMusic();
  }


  // 🎨 Персонажи
  final List<Map<String, dynamic>> _skins = [
    {
      'name': 'IRON FATE',
      'path': 'player.png',
      'desc': 'Не летает. Он утверждается в пространстве. Враг разобьётся о его броню, прежде чем он исчерпает боезапас.',
      'frames': 3,
      'frameToShow': 1, // показываем средний кадр
    },
    {
      'name': 'NEXUS',
      'path': 'Blaze2.png',
      'desc': 'Он видит битву как сеть импульсов.',
      'frames': 3,
      'frameToShow': 1,
    },
    {
      'name': 'VOID HUNTER',
      'path': 'KlaEd.png',
      'desc': 'Он приходит туда, куда флот не суётся.',
      'frames': 3,
      'frameToShow': 1,
    },
  ];

  final PageStorageBucket _bucket = PageStorageBucket();






  // 🧩 Метод, показывающий только нужный кадр из sprite sheet
  Widget _buildSingleFrame(String path, int frames, int frameToShow,
      {double height = 200}) {
    return FutureBuilder<Image>(
      future: _extractFrame(path, frames, frameToShow),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data!;
      },
    );
  }

  // 🧠 Логика обрезки кадра
  Future<Image> _extractFrame(String path, int frames, int frameToShow) async {
    final image = Image.asset(path);
    final imageProvider = image.image;
    final completer = Completer<ImageInfo>();

    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        completer.complete(info);
      }),
    );

    final imageInfo = await completer.future;
    final spriteWidth = imageInfo.image.width / frames;

    return Image.asset(
      path,
      fit: BoxFit.contain,
      alignment: Alignment.topLeft,
      frameBuilder: (context, child, frame, _) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: 1 / frames,
            child: Transform.translate(
              offset: Offset(-spriteWidth * frameToShow, 0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: SafeArea(
        child: PageStorage(
          bucket: _bucket,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose your character',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.amberAccent,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🌀 Карусель
              CarouselSlider.builder(
                itemCount: _skins.length,
                itemBuilder: (context, index, realIndex) {
                  final skin = _skins[index];
                  final isSelected = _currentIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.8),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                      ],
                      border: Border.all(
                        color:
                        isSelected ? Colors.amberAccent : Colors.white24,
                        width: isSelected ? 3.5 : 1.5,
                      ),
                      color: Colors.white10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔹 теперь показываем только один кадр
                        _buildSingleFrame(
                          'assets/images/${skin['path']}',
                          skin['frames'],
                          skin['frameToShow'],
                          height: isSelected ? 220 : 180,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          skin['name'],
                          style: TextStyle(
                            color:
                            isSelected ? Colors.amberAccent : Colors.white,
                            fontSize: isSelected ? 22 : 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skin['desc'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 380,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.7,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 🔘 Кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      widget.game.overlays.remove('SkinMenu');
                      widget.game.overlays.add('MainMenu');
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    label: const Text(
                      'Назад',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      final selected = _skins[_currentIndex];
                      widget.game.selectedSkin = selected['path'];
                      widget.game.overlays.remove('SkinMenu');
                      widget.game.overlays.add('MainMenu');

                      if (mounted) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          SnackBar(
                            content: Text('✅ Выбран: ${selected['name']}'),
                            backgroundColor: Colors.green.shade700,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, color: Colors.black),
                    label: const Text(
                      'Выбрать',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
