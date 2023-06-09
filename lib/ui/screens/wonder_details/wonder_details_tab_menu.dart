import 'package:wonders/common_libs.dart';

class WonderDetailsTabMenu extends StatelessWidget {
  static const double buttonInset = 12;

  ///tab按钮前面的home按钮
  static const double homeBtnSize = 74;
  static const double minTabSize = 25;
  static const double maxTabSize = 100;

  const WonderDetailsTabMenu(
      {Key? key,
      required this.tabController,
      this.showBg = false,
      required this.wonderType,
      this.axis = Axis.horizontal})
      : super(key: key);

  final TabController tabController;
  final bool showBg;
  final WonderType wonderType;
  final Axis axis;

  ///tab按钮是否水平排列（默认水平）
  bool get isVertical => axis == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    Color iconColor = showBg ? $styles.colors.black : $styles.colors.white;
    // Measure available size after subtracting the home button size and insets
    ///计算减去home按钮及边距insets后的可用空间
    final availableSize = ((isVertical ? context.heightPx : context.widthPx) -
        homeBtnSize -
        $styles.insets.md);
    // Calculate tabBtnSize based on availableSize
    ///根据可用空间计算tab按钮尺寸
    ///clamp：返回限制在[最小，最大]区间范围内的最邻近的值。
    final double tabBtnSize = (availableSize / 4).clamp(minTabSize, maxTabSize);
    // Figure out some extra gap, in the case that the tabBtns are wider than the homeBtn
    ///计算额外间距，以防止tab按钮比home按钮还要宽
    final double gapAmt = max(0, tabBtnSize - homeBtnSize);
    // Store off safe areas which we will need to respect in the layout below
    ///缓存安全区，以防底部布局异常
    ///MediaQuery.of(context).padding: 用于获取上下左右的安全padding，这里获取了底部和顶部
    final double safeAreaBtm = context.mq.padding.bottom,
        safeAreaTop = context.mq.padding.top;
    // Insets the bg from the rounded wonder icon making it appear offset. The tab btns will use the same padding.
    ///?从圆形奇迹图标中插入背景，使其看起来偏移。选项卡 btns 将使用相同的填充
    final buttonInsetPadding = isVertical
        ? EdgeInsets.only(right: buttonInset)
        : EdgeInsets.only(top: buttonInset);
    return Padding(
      padding: isVertical
          ? EdgeInsets.only(top: safeAreaTop)
          : EdgeInsets.only(top: safeAreaTop),
      child: Stack(
        children: [
          /// Background, animates in and out based on `showBg`,
          /// has padding along the inside edge which makes the home-btn appear to hang over the edge.
          /// 背景，借助“showBg”变量做进入和出去的动画
          Positioned.fill(
            child: Padding(
              padding: buttonInsetPadding,
              child: AnimatedOpacity(
                duration: $styles.times.fast,
                opacity: showBg ? 1 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: $styles.colors.white,
                    borderRadius: isVertical
                        ? BorderRadius.only(topRight: Radius.circular(32))
                        : null,
                  ),
                ),
              ),
            ),
          ),

          /// Buttons
          /// A centered row / column of tabButtons w/ an wonder home button
          /// 部署按钮（一行tab按钮+一个home按钮）
          Padding(
            /// When in hz mode add safeArea bottom padding, vertical layout should not need it
            padding: EdgeInsets.only(bottom: isVertical ? 0 : safeAreaBtm),
            child: SizedBox(
              width: isVertical ? null : double.infinity,
              height: isVertical ? double.infinity : null,

              ///FocusTraversalGroup:一个小部件，
              ///描述其后代的焦点遍历的继承焦点策略，将它们分组到一个单独的遍历组中。
              child: FocusTraversalGroup(
                child: Flex(
                  direction: axis,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Home btn
                    Padding(
                      /// Small amt of padding for home-btn
                      padding: isVertical
                          ? EdgeInsets.only(left: $styles.insets.xs)
                          : EdgeInsets.only(bottom: $styles.insets.xs),
                      child: _WonderHomeBtn(
                        size: homeBtnSize,
                        wonderType: wonderType,
                        borderSize: showBg ? 6 : 2,
                      ),
                    ),
                    Gap(gapAmt),

                    /// A second Row / Col holding tab buttons
                    /// Add the btn inset padding so they will be centered on the colored background
                    Padding(
                      padding: buttonInsetPadding,
                      child: Flex(
                          direction: axis,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// Tabs
                            _TabBtn(
                              0,
                              tabController,
                              iconImg: 'editorial',
                              label: $strings.wonderDetailsTabLabelInformation,
                              color: iconColor,
                              axis: axis,
                              mainAxisSize: tabBtnSize,
                            ),
                            _TabBtn(
                              1,
                              tabController,
                              iconImg: 'photos',
                              label: $strings.wonderDetailsTabLabelImages,
                              color: iconColor,
                              axis: axis,
                              mainAxisSize: tabBtnSize,
                            ),
                            _TabBtn(
                              2,
                              tabController,
                              iconImg: 'artifacts',
                              label: $strings.wonderDetailsTabLabelArtifacts,
                              color: iconColor,
                              axis: axis,
                              mainAxisSize: tabBtnSize,
                            ),
                            _TabBtn(
                              3,
                              tabController,
                              iconImg: 'timeline',
                              label: $strings.wonderDetailsTabLabelEvents,
                              color: iconColor,
                              axis: axis,
                              mainAxisSize: tabBtnSize,
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WonderHomeBtn extends StatelessWidget {
  const _WonderHomeBtn(
      {Key? key,
      required this.size,
      required this.wonderType,
      required this.borderSize})
      : super(key: key);

  final double size;
  final WonderType wonderType;
  final double borderSize;

  @override
  Widget build(BuildContext context) {
    return CircleBtn(
      onPressed: () => Navigator.of(context).pop(),
      bgColor: $styles.colors.white,
      semanticLabel: $strings.wonderDetailsTabSemanticBack,
      child: AnimatedContainer(
        curve: Curves.easeOut,
        duration: $styles.times.fast,
        width: size - borderSize * 2,
        height: size - borderSize * 2,
        margin: EdgeInsets.all(borderSize),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: wonderType.fgColor,
          image: DecorationImage(
              image: AssetImage(wonderType.homeBtn), fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn(
    this.index,
    this.tabController, {
    Key? key,
    required this.iconImg,
    required this.color,
    required this.label,
    required this.axis,
    required this.mainAxisSize,
  }) : super(key: key);

  static const double crossBtnSize = 60;

  final int index;
  final TabController tabController;
  final String iconImg;
  final Color color;
  final String label;
  final Axis axis;
  final double mainAxisSize;

  bool get _isVertical => axis == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    // return _isVertical
    //     ? SizedBox(height: mainAxisSize, width: crossBtnSize, child: Placeholder())
    //     : SizedBox(height: crossBtnSize, width: mainAxisSize, child: Placeholder());
    bool selected = tabController.index == index;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final iconImgPath =
        '${ImagePaths.common}/tab-$iconImg${selected ? '-active' : ''}.png';
    String tabLabel = localizations.tabLabel(
        tabIndex: index + 1, tabCount: tabController.length);
    tabLabel = '$label: $tabLabel';

    ///计算底部icon尺寸：取两者最小
    final double iconSize = min(mainAxisSize, 32);

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        label: tabLabel,
        child: ExcludeSemantics(
          child: AppBtn.basic(
            onPressed: () => tabController.index = index,
            semanticLabel: label,
            minimumSize: _isVertical
                ? Size(crossBtnSize, mainAxisSize)
                : Size(mainAxisSize, crossBtnSize),
            // Image icon
            child: Image.asset(
              iconImgPath,
              height: iconSize,
              width: iconSize,
              color: selected ? null : color,
            ),
          ),
        ),
      ),
    );
  }
}
