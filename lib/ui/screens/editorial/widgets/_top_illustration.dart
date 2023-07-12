part of '../editorial_screen.dart';

///顶部插图
class _TopIllustration extends StatelessWidget {
  const _TopIllustration(this.type, {Key? key, this.fgOffset = Offset.zero})
      : super(key: key);
  final WonderType type;
  final Offset fgOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///背景插图1
        WonderIllustration(type,
            config: WonderIllustrationConfig.bg(
                enableAnims: false, shortMode: true)),

        ///插图2（名胜古迹主体）
        Transform.translate(
          // Small bump down to make sure we cover the edge between the editorial page and the sky.
          //小的凹凸以确保我们覆盖编辑页面和天空之间的边缘。
          offset: fgOffset + Offset(0, 10),
          child: WonderIllustration(
            type,
            config: WonderIllustrationConfig.mg(
                enableAnims: false, shortMode: true),
          ),
        ),
      ],
    );
  }
}
