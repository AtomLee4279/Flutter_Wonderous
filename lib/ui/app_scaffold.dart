import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/app_scroll_behavior.dart';

class WondersAppScaffold extends StatelessWidget {
  const WondersAppScaffold({Key? key, required this.child}) : super(key: key);
  final Widget child;
  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    // Listen to the device size, and update AppStyle when it changes
    ///监听设备尺寸变化，当它发生改变时，更新app的风格
    MediaQuery.of(context);
    appLogic.handleAppSizeChanged();
    // Set default timing for animations in the app
    ///设置动画默认时长：快速
    Animate.defaultDuration = _style.times.fast;
    // Create a style object that will be passed down the widget tree
    ///创建一个风格对象，它将会向widget树以下传递
    _style = AppStyle(screenSize: context.sizePx);
    return KeyedSubtree(
      ///用自适应缩放比例设置key，从而控制widget是否需要rebuild
      key: ValueKey($styles.scale),
      child: Theme(
        data: $styles.colors.toThemeData(),
        // Provide a default texts style to allow Hero's to render text properly
        ///提供一个默认的文本风格，从而允许Hero控件渲染字体属性
        child: DefaultTextStyle(
          style: $styles.text.body,
          // Use a custom scroll behavior across entire app
          ///使用自定义滚动行为贯穿整个app
          child: ScrollConfiguration(
            behavior: AppScrollBehavior(),
            child: child,
          ),
        ),
      ),
    );
  }
}
