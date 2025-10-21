import 'package:flutter/material.dart';

class SafeGameContainer extends StatelessWidget {
  final Widget child;
  final String? backgroundImage;

  const SafeGameContainer({
    super.key,
    required this.child,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;
        double targetAspectRatio = 16 / 9;

        double currentAspectRatio = screenWidth / screenHeight;

        if (currentAspectRatio > targetAspectRatio) {
          // экран шире чем 16:9 → добавляем отступы по бокам
          double targetWidth = screenHeight * targetAspectRatio;
          double padding = (screenWidth - targetWidth) / 2;
          return Container(
            decoration: backgroundImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            padding: EdgeInsets.symmetric(horizontal: padding),
            alignment: Alignment.center,
            child: AspectRatio(aspectRatio: targetAspectRatio, child: child),
          );
        } else {
          // экран выше чем 16:9 → добавляем отступы сверху и снизу
          double targetHeight = screenWidth / targetAspectRatio;
          double padding = (screenHeight - targetHeight) / 2;
          return Container(
            decoration: backgroundImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            padding: EdgeInsets.symmetric(vertical: padding),
            alignment: Alignment.center,
            child: AspectRatio(aspectRatio: targetAspectRatio, child: child),
          );
        }
      },
    );
  }
}
