import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/platform_info.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/app_backdrop.dart';
import 'package:wonders/ui/common/centered_box.dart';
import 'package:wonders/ui/common/curved_clippers.dart';
import 'package:wonders/ui/common/hidden_collectible.dart';
import 'package:wonders/ui/common/list_gradient.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/common/timeline_event_card.dart';
import 'package:wonders/ui/common/wonders_timeline_builder.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';

import '../../common/app_icons.dart';
import '../../common/controls/app_header.dart';

part 'widgets/_events_list.dart';
part 'widgets/_timeline_btn.dart';
part 'widgets/_wonder_image_with_timeline.dart';

///名胜古迹事件标签页，提供时间线页面入口
class WonderEvents extends StatefulWidget {
  const WonderEvents(
      {Key? key, required this.type, this.contentPadding = EdgeInsets.zero})
      : super(key: key);
  final WonderType type;
  final EdgeInsets contentPadding;
  @override
  State<WonderEvents> createState() => _WonderEventsState();
}

class _WonderEventsState extends State<WonderEvents> {
  late final _data = wondersLogic.getData(widget.type);
  final _eventsListKey = GlobalKey<_EventsListState>();
  double _scrollPos = 0;

  void _handleScroll(double pos) => _scrollPos = pos;

  @override
  Widget build(BuildContext context) {
    debugPrint('WonderEvents:build');
    void handleTimelineBtnPressed() =>
        context.push(ScreenPaths.timeline(widget.type));
    // Main view content switches between 1 and 2 column layouts
    // On mobile, use the 2 column layout on screens close to landscape (>.85). This is primarily an optimization for foldable devices which have square-ish dimensions when opened.
    /// 主视图内容在 1 列布局和 2 列布局之间切换
    /// 在移动设备上，在接近横向 (>.85) 的屏幕上使用 2 列布局。这主要是针对可折叠设备的优化，这些设备在打开时具有方形尺寸。
    final twoColumnAspect = PlatformInfo.isMobile ? .85 : 1;

    ///若：屏幕宽高比>twoColumnAspect,则使用两列部署
    bool useTwoColumnLayout = context.mq.size.aspectRatio > twoColumnAspect;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: $styles.colors.black,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              /// Main view
              Positioned.fill(
                top: $styles.insets.sm,
                child: Padding(
                  padding: widget.contentPadding,
                  child: useTwoColumnLayout
                      ? _buildTwoColumn(context)
                      : _buildSingleColumn(),
                ),
              ),

              /// Header w/ TimelineBtn
              TopCenter(
                child: AppHeader(
                  showBackBtn: false,
                  isTransparent: true,
                  trailing: (_) => CircleIconBtn(
                      icon: AppIcons.timeline,
                      onPressed: handleTimelineBtnPressed,
                      semanticLabel: $strings.eventsListButtonOpenGlobal),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Landscape layout is a row, with the WonderImage on left and EventsList on the right
  Widget _buildTwoColumn(BuildContext context) {
    final double timelineImageSize = (context.heightPx - 350).clamp(200, 500);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: $styles.insets.lg, horizontal: $styles.insets.sm),
      child: Row(
        children: [
          /// WonderImage w/ Timeline btn
          Expanded(
            child: CenteredBox(
              width: $styles.sizes.maxContentWidth3,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: $styles.insets.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WonderImageWithTimeline(
                        data: _data, height: timelineImageSize),
                    Gap($styles.insets.lg),
                    SizedBox(
                        width: 400, child: _TimelineBtn(type: widget.type)),
                  ],
                ),
              ),
            ),
          ),

          /// EventsList
          Expanded(
            child: CenteredBox(
              width: $styles.sizes.maxContentWidth2,
              child: _EventsList(
                key: _eventsListKey,
                data: _data,
                topHeight: 100,
                blurOnScroll: false,
                onScroll: _handleScroll,
                initialScrollOffset: _scrollPos,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Portrait layout is a stack with the EventsList scrolling overtop of the WonderImage
  /// WonderEvents垂直布局列表的页面
  /// 纵向布局是一个堆栈，EventsList 在 WonderImage 上方滚动
  Widget _buildSingleColumn() {
    return LayoutBuilder(builder: (_, constraints) {
      ///高度使用数学公式设定（高度最小为200）
      double topHeight = max(constraints.maxHeight * .55, 200);
      return CenteredBox(
        ///最大宽度约束
        width: $styles.sizes.maxContentWidth2,
        child: Stack(
          children: [
            /// Top content, sits underneath scrolling list
            _WonderImageWithTimeline(height: topHeight, data: _data),

            /// EventsList + TimelineBtn
            Column(
              children: [
                Expanded(
                  /// EventsList
                  /// 列表
                  child: _EventsList(
                    key: _eventsListKey,
                    data: _data,
                    topHeight: topHeight,
                    blurOnScroll: true,
                    showTopGradient: false,
                    onScroll: _handleScroll,
                    initialScrollOffset: _scrollPos,
                  ),
                ),
                Gap($styles.insets.lg),

                /// TimelineBtn
                _TimelineBtn(
                    type: _data.type, width: $styles.sizes.maxContentWidth2),
                Gap($styles.insets.lg),
              ],
            ),
          ],
        ),
      );
    });
  }
}
