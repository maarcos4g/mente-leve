import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Tela de seleção de avatar, inspirada na tela "Escolha um ícone" da Netflix.
///
/// Os avatares são exibidos em um grid.
/// Ao tocar em um avatar, a tela é fechada e retorna o nome do arquivo
/// (ex.: `cat.svg`) via `Navigator.pop`.
class SelectAvatarView extends StatelessWidget {
  const SelectAvatarView({super.key, this.selectedPath});

  /// Avatar atualmente selecionado (destacado com borda).
  final String? selectedPath;

  static const _assetsFolder = 'assets/avatars';

  static const _avatars = [
    {'path': 'cat.svg', 'label': 'Gato'},
    {'path': 'dog.svg', 'label': 'Cachorro'},
    {'path': 'husky-dog.svg', 'label': 'Husky'},
    {'path': 'rabbit.svg', 'label': 'Coelho'},
    {'path': 'pig.svg', 'label': 'Porco'},
    {'path': 'cow.svg', 'label': 'Vaca'},
    {'path': 'goat.svg', 'label': 'Cabra'},
    {'path': 'horse.svg', 'label': 'Cavalo'},
    {'path': 'lion.svg', 'label': 'Leão'},
    {'path': 'tiger.svg', 'label': 'Tigre'},
    {'path': 'elepant.svg', 'label': 'Elefante'},
    {'path': 'giraffe.svg', 'label': 'Girafa'},
    {'path': 'rhino.svg', 'label': 'Rinoceronte'},
    {'path': 'hippopotamus.svg', 'label': 'Hipopótamo'},
    {'path': 'gorilla.svg', 'label': 'Gorila'},
    {'path': 'monkey.svg', 'label': 'Macaco'},
    {'path': 'buffalo.svg', 'label': 'Búfalo'},
    {'path': 'snake.svg', 'label': 'Cobra'},
    {'path': 'bear.svg', 'label': 'Urso'},
    {'path': 'panda.svg', 'label': 'Panda'},
    {'path': 'koala.svg', 'label': 'Coala'},
    {'path': 'fox.svg', 'label': 'Raposa'},
    {'path': 'deer.svg', 'label': 'Veado'},
    {'path': 'bird.svg', 'label': 'Pássaro'},
    {'path': 'walrus.svg', 'label': 'Morsa'},
  ];

  static const _backgrounds = [
    TailwindColors.red500,
    TailwindColors.orange500,
    TailwindColors.amber400,
    TailwindColors.lime500,
    TailwindColors.emerald500,
    TailwindColors.cyan500,
    TailwindColors.blue500,
    TailwindColors.violet500,
    TailwindColors.pink500,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Escolha seu avatar',
          style: AppTextStyles.captionMedium,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _avatars.length,
        itemBuilder: (context, index) {
          final avatar = _avatars[index];
          return _AvatarTile(
            assetPath: '$_assetsFolder/${avatar['path']}',
            label: avatar['label']!,
            background: _backgrounds[index % _backgrounds.length],
            selected: avatar['path'] == selectedPath,
            onTap: () => Navigator.pop(context, avatar['path']),
          );
        },
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.assetPath,
    required this.label,
    required this.background,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(4),
            border: selected
                ? Border.all(color: Colors.black87, width: 3)
                : null,
          ),
          child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
