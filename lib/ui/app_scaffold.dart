import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/app_scroll_behavior.dart';

// class WondersAppScaffold extends StatefulWidget {
//   const WondersAppScaffold({super.key, required this.child});
//   final Widget child;
//   static AppStyle style = AppStyle();
//   @override
//   State<WondersAppScaffold> createState() => WondersAppScaffoldState();
// }
//
// class WondersAppScaffoldState extends State<WondersAppScaffold> {
//   @override
//   void didChangeDependencies() {
//     WondersAppScaffold.style = AppStyle(screenSize: context.sizePx);
//
//     ///监听设备尺寸比例变化，当它发生改变(即：屏幕翻转/鼠标拉伸改变窗口尺寸等)，更新app的风格（更改支持的横/竖屏设置）
//     appLogic.handleAppSizeChanged();
//     debugPrint(
//         'WondersAppScaffold-监听屏幕scale：${WondersAppScaffold.style.scale}');
//     super.didChangeDependencies();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     MediaQuery.of(context);
//     // Set default timing for animations in the app
//     ///设置动画默认时长：快速
//     Animate.defaultDuration = WondersAppScaffold.style.times.fast;
//     return Theme(
//       data: $styles.colors.toThemeData(),
//       // Provide a default texts style to allow Hero's to render text properly
//       ///提供一个默认的文本风格，从而允许Hero控件渲染字体属性
//       child: DefaultTextStyle(
//         style: $styles.text.body,
//         // Use a custom scroll behavior across entire app
//         ///使用自定义滚动行为贯穿整个app
//         child: ScrollConfiguration(
//           behavior: AppScrollBehavior(),
//           child: widget.child,
//         ),
//       ),
//     );
//   }
// }

class WondersAppScaffold extends StatelessWidget {
  const WondersAppScaffold({Key? key, required this.child}) : super(key: key);
  final Widget child;
  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();
  @override
  Widget build(BuildContext context) {
    // Listen to the device size, and update AppStyle when it changes
    ///监听设备尺寸比例变化，当它发生改变(即：屏幕翻转/鼠标拉伸改变窗口尺寸等)，更新app的风格（更改支持的横/竖屏设置）
    debugPrint('WondersAppScaffold-监听屏幕scale：${_style.scale}');
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
