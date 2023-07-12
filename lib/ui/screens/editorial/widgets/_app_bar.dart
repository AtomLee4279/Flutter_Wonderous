part of '../editorial_screen.dart';

///WonderEditorialScreen中，标题与正文之间的AppBar
class _AppBar extends StatelessWidget {
  _AppBar(this.wonderType,
      {Key? key, required this.sectionIndex, required this.scrollPos})
      : super(key: key);
  final WonderType wonderType;
  final ValueNotifier<int> sectionIndex;
  final ValueNotifier<double> scrollPos;
  final _titleValues = [
    $strings.appBarTitleFactsHistory,
    $strings.appBarTitleConstruction,
    $strings.appBarTitleLocation,
  ];

  final _iconValues = const [
    'history.png',
    'construction.png',
    'geography.png',
  ];

  ArchType _getArchType() {
    switch (wonderType) {
      case WonderType.chichenItza:
        return ArchType.flatPyramid;
      case WonderType.christRedeemer:
        return ArchType.wideArch;
      case WonderType.colosseum:
        return ArchType.arch;
      case WonderType.greatWall:
        return ArchType.arch;
      case WonderType.machuPicchu:
        return ArchType.pyramid;
      case WonderType.petra:
        return ArchType.wideArch;
      case WonderType.pyramidsGiza:
        return ArchType.pyramid;
      case WonderType.tajMahal:
        return ArchType.spade;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arch = _getArchType();
    return LayoutBuilder(builder: (_, constraints) {
      bool showOverlay = constraints.biggest.height < 300;
      return Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: $styles.times.med,
            child: Stack(
              key: ValueKey(showOverlay),
              fit: StackFit.expand,
              children: [
                /// Masked image
                /// 被阴影覆盖的底图
                BottomCenter(
                  child: SizedBox(
                    width: showOverlay
                        ? double.infinity
                        : $styles.sizes.maxContentWidth1,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: ClipPath(
                        // Switch arch type to Rect if we are showing the title bar
                        clipper: showOverlay ? null : ArchClipper(arch),
                        child: ValueListenableBuilder<double>(
                          valueListenable: scrollPos,
                          builder: (_, value, child) {
                            double opacity = (.4 + (value / 1500)).clamp(0, 1);
                            return ScalingListItem(
                              scrollPos: scrollPos,
                              child: Image.asset(
                                wonderType.photo1,
                                fit: BoxFit.cover,
                                opacity: AlwaysStoppedAnimation(opacity),
                              ),
                            );
                          },
                        ),
                      )
                          .animate(delay: $styles.times.pageTransition + 500.ms)
                          .fadeIn(duration: $styles.times.slow),
                    ),
                  ),
                ),

                /// Colored overlay
                /// 带颜色的遮罩
                if (showOverlay) ...[
                  AnimatedContainer(
                    duration: $styles.times.med,
                    color: wonderType.bgColor.withOpacity(showOverlay ? .8 : 0),
                  ),
                ],
              ],
            ),
          ),

          /// Circular Titlebar
          ///AppBar底部那个像半圆转盘一样的文字和图标
          ///当滚动到不同的section时，可以转动转盘上的section标题文字
          BottomCenter(
            child: ValueListenableBuilder<int>(
              valueListenable: sectionIndex,
              builder: (_, value, __) {
                return _CircularTitleBar(
                  index: value,
                  titles: _titleValues,
                  icons: _iconValues,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
