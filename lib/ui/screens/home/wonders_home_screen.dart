import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'package:wonders/ui/common/controls/app_header.dart';
import 'package:wonders/ui/common/controls/app_page_indicator.dart';
import 'package:wonders/ui/common/gradient_container.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/common/utils/app_haptics.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';
import 'package:wonders/ui/wonder_illustrations/common/animated_clouds.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration_config.dart';

import '../../wonder_illustrations/common/wonder_title_text.dart';

part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';

class HomeScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Shows a horizontally scrollable list PageView sandwiched between Foreground and Background layers
/// arranged in a parallax style.
/// 显示夹在前景层和背景层之间的水平可滚动列表 （PageView）。
/// 它以视差样式排列
///
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  List<WonderData> get _wonders => wondersLogic.all;
  bool _isMenuOpen = false;

  /// Set initial wonderIndex
  late int _wonderIndex = 0;
  int get _numWonders => _wonders.length;

  /// Used to polish the transition when leaving this page for the details view.
  /// Used to capture the _swipeAmt at the time of transition, and freeze the wonder foreground in place as we transition away.
  /// 用于离开此页面以查看详细信息视图时,做平滑过渡。
  /// 用于在过渡时捕获 _swipeAmt，并在我们过渡离开时将奇迹前景冻结在适当的位置
  double? _swipeOverride;

  /// Used to let the foreground fade in when this view is returned to (from details)
  /// 用于从详情返回此视图时，让前景淡入
  bool _fadeInOnNextBuild = false;

  /// All of the items that should fade in when returning from details view.
  /// Using individual tweens is more efficient than tween the entire parent
  /// 当从详情页返回时，所有items都应该淡入
  /// 使用独立的tweens比在整个parent-widget使用tweens更高效
  final _fadeAnims = <AnimationController>[];

  WonderData get currentWonder => _wonders[_wonderIndex];

  late final _VerticalSwipeController _swipeController =
      _VerticalSwipeController(this, _showDetailsPage);

  bool _isSelected(WonderType t) => t == currentWonder.type;

  @override
  void initState() {
    super.initState();
    // Create page controller,
    // allow 'infinite' scrolling by starting at a very high page, or remember the previous value
    final initialPage = _numWonders * 9999;
    _pageController =
        PageController(viewportFraction: 1, initialPage: initialPage);
    _wonderIndex = initialPage % _numWonders;
  }

  ///处理页面左右翻页
  void _handlePageChanged(value) {
    setState(() {
      _wonderIndex = value % _numWonders;
    });
    AppHaptics.lightImpact();
  }

  ///处理左上角菜单页面的打开
  void _handleOpenMenuPressed() async {
    setState(() => _isMenuOpen = true);
    WonderType? pickedWonder =
        await appLogic.showFullscreenDialogRoute<WonderType>(
      context,
      HomeMenu(data: currentWonder),
      transparent: true,
    );
    setState(() => _isMenuOpen = false);
    if (pickedWonder != null) {
      _setPageIndex(_wonders.indexWhere((w) => w.type == pickedWonder));
    }
  }

  void _handleFadeAnimInit(AnimationController controller) {
    _fadeAnims.add(controller);
    controller.value = 1;
  }

  void _handlePageIndicatorDotPressed(int index) => _setPageIndex(index);

  void _setPageIndex(int index) {
    if (index == _wonderIndex) return;
    // To support infinite scrolling, we can't jump directly to the pressed index. Instead, make it relative to our current position.
    final pos =
        ((_pageController.page ?? 0) / _numWonders).floor() * _numWonders;
    _pageController.jumpToPage(pos + index);
  }

  ///push详情页
  void _showDetailsPage() async {
    _swipeOverride = _swipeController.swipeAmt.value;
    context.push(ScreenPaths.wonderDetails(currentWonder.type));
    await Future.delayed(100.ms);
    _swipeOverride = null;
    _fadeInOnNextBuild = true;
  }

  void _startDelayedFgFade() async {
    try {
      for (var a in _fadeAnims) {
        a.value = 0;
      }
      await Future.delayed(300.ms);
      for (var a in _fadeAnims) {
        a.forward();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  ///由于该HomeScreen位于WondersAppScaffold的widget树KeyedSubtree()子节点之下，
  ///```
  ///KeyedSubtree(
  ///       //用自适应缩放比例设置key，从而控制widget是否需要rebuild
  ///       key: ValueKey($styles.scale),
  ///       //...
  ///       )
  ///```
  ///所以当屏幕尺寸比例发生改变(即：屏幕翻转/鼠标拉伸改变窗口尺寸等)时，将触发HomeScreen的rebuild
  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen-触发build');
    if (_fadeInOnNextBuild == true) {
      _startDelayedFgFade();
      _fadeInOnNextBuild = false;
    }

    return _swipeController.wrapGestureDetector(Container(
      color: $styles.colors.black,
      child: Stack(
        children: [
          Stack(
            children: [
              /// Background
              /// 最底层的背景图和天上的云
              ..._buildBgAndClouds(),

              /// Wonders Illustrations (main content)
              ///奇迹插图（中间的建筑物图案，其实包含了左右滑的pageView）
              _buildMgPageView(),

              /// Foreground illustrations and gradients
              /// 画面前的渐变前景插图（类似舞台幕布）
              _buildFgAndGradients(),

              /// Controls that float on top of the various illustrations
              ///浮在顶层的可交互控件
              ///（包括：左上角：菜单按钮、底部：奇迹名称、（左右翻页）radio圆点、底部隐藏更多内容的提示箭头）
              _buildFloatingUi(),
            ],
          ).animate().fadeIn(),
        ],
      ),
    ));
  }

  Widget _buildMgPageView() {
    return ExcludeSemantics(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemBuilder: (_, index) {
          final wonder = _wonders[index % _wonders.length];
          final wonderType = wonder.type;
          bool isShowing = _isSelected(wonderType);
          return _swipeController.buildListener(
            builder: (swipeAmt, _, child) {
              final config = WonderIllustrationConfig.mg(
                isShowing: isShowing,
                zoom: .05 * swipeAmt,
              );
              return WonderIllustration(wonderType, config: config);
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBgAndClouds() {
    return [
      // Background
      ..._wonders.map((e) {
        final config =
            WonderIllustrationConfig.bg(isShowing: _isSelected(e.type));
        return WonderIllustration(e.type, config: config);
      }).toList(),
      // Clouds
      FractionallySizedBox(
        widthFactor: 1,
        heightFactor: .5,
        child: AnimatedClouds(wonderType: currentWonder.type, opacity: 1),
      )
    ];
  }

  Widget _buildFgAndGradients() {
    Widget buildSwipeableBgGradient(Color fgColor) {
      return _swipeController.buildListener(
          builder: (swipeAmt, isPointerDown, _) {
        return IgnorePointer(
          child: FractionallySizedBox(
            heightFactor: .6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fgColor.withOpacity(0),
                    fgColor.withOpacity(.5 +
                        fgColor.opacity * .25 +
                        (isPointerDown ? .05 : 0) +
                        swipeAmt * .20),
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),
        );
      });
    }

    final gradientColor = currentWonder.type.bgColor;
    return Stack(children: [
      /// Foreground gradient-1, gets darker when swiping up
      BottomCenter(
        child: buildSwipeableBgGradient(gradientColor.withOpacity(.65)),
      ),

      /// Foreground decorators
      ..._wonders.map((e) {
        return _swipeController.buildListener(builder: (swipeAmt, _, child) {
          final config = WonderIllustrationConfig.fg(
            isShowing: _isSelected(e.type),
            zoom: .4 * (_swipeOverride ?? swipeAmt),
          );
          return Animate(
              effects: const [FadeEffect()],
              onPlay: _handleFadeAnimInit,
              child: IgnorePointer(
                  child: WonderIllustration(e.type, config: config)));
        });
      }).toList(),

      /// Foreground gradient-2, gets darker when swiping up
      BottomCenter(
        child: buildSwipeableBgGradient(gradientColor),
      ),
    ]);
  }

  ///浮在顶层的可交互控件
  ///（包括：左上角：菜单按钮、底部：奇迹名称、（左右翻页）radio圆点、底部隐藏更多内容的提示箭头）
  Widget _buildFloatingUi() {
    return Stack(children: [
      /// Floating controls / UI
      //[底部文字、（左右翻页）页面indicator、和向下箭头]
      AnimatedSwitcher(
        duration: $styles.times.fast,
        child: AnimatedOpacity(
          opacity: _isMenuOpen ? 0 : 1,
          duration: $styles.times.med,

          ///RepaintBoundary：
          ///将子widget分离到自己的层中，
          ///确保层中的widget重构时，不会触发外部整体重构
          ///使用这个需要权衡cpu和内存成本
          child: RepaintBoundary(
            child: OverflowBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity),
                  const Spacer(),

                  /// Title Content
                  LightText(
                    child: IgnorePointer(
                      ignoringSemantics: false,
                      child: Transform.translate(
                        offset: Offset(0, 30),
                        child: Column(
                          children: [
                            ///靠近底部，切换历史古迹Indicator之上的当前古迹标题
                            Semantics(
                              liveRegion: true,
                              button: true,
                              header: true,
                              onIncrease: () => _setPageIndex(_wonderIndex + 1),
                              onDecrease: () => _setPageIndex(_wonderIndex - 1),
                              onTap: () => _showDetailsPage(),
                              // Hide the title when the menu is open for visual polish
                              child: WonderTitleText(currentWonder,
                                  enableShadows: true),
                            ),
                            Gap($styles.insets.md),
                            AppPageIndicator(
                              count: _numWonders,
                              controller: _pageController,
                              color: $styles.colors.white,
                              dotSize: 8,
                              onDotPressed: _handlePageIndicatorDotPressed,
                              semanticPageTitle: $strings.homeSemanticWonder,
                            ),
                            Gap($styles.insets.md),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Animated arrow and background
                  /// Wrap in a container that is full-width to make it easier to find for screen readers
                  /// 对向下箭头和背景执行动画
                  /// 将它们封装在Container内
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,

                    /// Lose state of child objects when index changes, this will re-run all the animated switcher and the arrow anim
                    /// 当index改变的时候将丢弃子widget对象的状态
                    key: ValueKey(_wonderIndex),
                    child: Stack(
                      children: [
                        /// Expanding rounded rect that grows in height as user swipes up
                        /// 当用户向上滑动（展示更多）时，拉伸圆角矩形的高度
                        Positioned.fill(
                            child: _swipeController.buildListener(
                          builder: (swipeAmt, _, child) {
                            double heightFactor = .5 + .5 * (1 + swipeAmt * 4);

                            ///FractionallySizedBox：
                            ///按照可用（宽/高）比例因子设置子widget占用的尺寸
                            return FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: heightFactor,
                              child:
                                  Opacity(opacity: swipeAmt * .5, child: child),
                            );
                          },

                          ///这里是拖动向下箭头按钮时出现的高度被拉长的矩形
                          child: VtGradient(
                            [
                              $styles.colors.white.withOpacity(0),
                              $styles.colors.white.withOpacity(1)
                            ],
                            const [.3, 1],
                            borderRadius: BorderRadius.circular(99),
                          ),
                        )),

                        /// Arrow Btn that fades in and out
                        /// 底部“展示更多”箭头按钮
                        _AnimatedArrowButton(
                            onTap: _showDetailsPage,
                            semanticTitle: currentWonder.title),
                      ],
                    ),
                  ),
                  Gap($styles.insets.md),
                ],
              ),
            ),
          ),
        ),
      ),

      /// Menu Btn
      /// 左上角的菜单按钮
      TopLeft(
        child: AnimatedOpacity(
          duration: $styles.times.fast,
          opacity: _isMenuOpen ? 0 : 1,
          child: AppHeader(
            backIcon: AppIcons.menu,
            backBtnSemantics: $strings.homeSemanticOpenMain,
            onBack: _handleOpenMenuPressed,
            isTransparent: true,
          ),
        ),
      ),
    ]);
  }
}
