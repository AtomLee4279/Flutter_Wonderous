import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/lazy_indexed_stack.dart';
import 'package:wonders/ui/common/measurable_widget.dart';
import 'package:wonders/ui/screens/artifact/artifact_carousel/artifact_carousel_screen.dart';
import 'package:wonders/ui/screens/editorial/editorial_screen.dart';
import 'package:wonders/ui/screens/wonder_details/wonder_details_tab_menu.dart';
import 'package:wonders/ui/screens/wonder_events/wonder_events.dart';

import '../photo_gallery/photo_gallery.dart';

///首页按照下拉提示操作后出现的页面（遗迹详情页，包含底部NavigationBar）
class WonderDetailsScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  WonderDetailsScreen({Key? key, required this.type, this.initialTabIndex = 0})
      : super(key: key);
  final WonderType type;
  final int initialTabIndex;

  @override
  State<WonderDetailsScreen> createState() => _WonderDetailsScreenState();
}

class _WonderDetailsScreenState extends State<WonderDetailsScreen>
    with GetItStateMixin, SingleTickerProviderStateMixin {
  late final _tabController = TabController(
    length: 4,
    vsync: this,
    initialIndex: widget.initialTabIndex,
  )..addListener(_handleTabChanged);
  AnimationController? _fade;

  double? _tabBarSize;
  bool _useNavRail = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    _fade?.forward(from: 0);
    setState(() {});
  }

  ///处理“向下阅读更多内容”提示箭头的交互
  void _handleTabMenuSized(Size size) {
    setState(() {
      _tabBarSize = (_useNavRail ? size.width : size.height) -
          WonderDetailsTabMenu.buttonInset;
    });
  }

  @override
  Widget build(BuildContext context) {
    ///判断tab是否需要使用NavigationRail
    _useNavRail = appLogic.shouldUseNavRail();
    debugPrint('wonders_detail_screen-MediaQuery.of(this):${context.sizePx}');
    final wonder = wondersLogic.getData(widget.type);
    int tabIndex = _tabController.index;

    ///是否需要隐藏tabBar的背景（例如在竖屏时，对应底下NavigationBar的白色背景栏是否需要隐藏）
    bool showTabBarBg = tabIndex != 1;
    final tabBarSize = _tabBarSize ?? 0;

    ///tab菜单栏偏移量
    final menuPadding = _useNavRail
        ? EdgeInsets.only(left: tabBarSize)
        : EdgeInsets.only(bottom: tabBarSize);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          /// Fullscreen tab views
          LazyIndexedStack(
            index: _tabController.index,
            children: [
              WonderEditorialScreen(wonder, contentPadding: menuPadding),

              ///图片页面
              PhotoGallery(
                  collectionId: wonder.unsplashCollectionId,
                  wonderType: wonder.type),

              ///艺术藏品页
              ArtifactCarouselScreen(
                  type: wonder.type, contentPadding: menuPadding),

              ///奇迹事件页（提供时间线页面入口）
              WonderEvents(type: widget.type, contentPadding: menuPadding),
            ],
          ),

          /// Tab menu
          /// 借助Align放置Wonders详情页tab栏（NavigationBar/NavigationRail）
          Align(
            alignment:
                _useNavRail ? Alignment.centerLeft : Alignment.bottomCenter,
            child: MeasurableWidget(
              onChange: _handleTabMenuSized,
              child: WonderDetailsTabMenu(
                tabController: _tabController,
                wonderType: wonder.type,
                showBg: showTabBarBg,
                axis: _useNavRail ? Axis.vertical : Axis.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
