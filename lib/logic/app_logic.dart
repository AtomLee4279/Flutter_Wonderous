import 'dart:async';
import 'dart:ui';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/platform_info.dart';
import 'package:wonders/ui/common/modals/fullscreen_video_viewer.dart';
import 'package:wonders/ui/common/utils/page_routes.dart';

class AppLogic {
  /// Indicates to the rest of the app that bootstrap has not completed.
  /// The router will use this to prevent redirects while bootstrapping.
  /// /// 向应用程序的其余部分指示引导程序尚未完成。
  /// 路由器将使用它来防止引导时的重定向。
  bool isBootstrapComplete = false;

  /// Indicates which orientations the app will allow be default. Affects Android/iOS devices only.
  /// Defaults to both landscape (hz) and portrait (vt)
  /// （仅对Android/IOS起效）指定了app的默认旋转方向
  List<Axis> supportedOrientations = [Axis.vertical, Axis.horizontal];

  /// Allow a view to override the currently supported orientations. For example, [FullscreenVideoViewer] always wants to enable both landscape and portrait.
  /// If a view sets this override, they are responsible for setting it back to null when finished.
  /// 允许视图覆盖当前支持的方向。例如，[FullscreenVideoViewer] 总是希望同时启用横向和纵向。
  /// 如果一个视图设置了这个覆盖，他们有责任在完成后将它设置回 null。
  List<Axis>? _supportedOrientationsOverride;
  set supportedOrientationsOverride(List<Axis>? value) {
    if (_supportedOrientationsOverride != value) {
      _supportedOrientationsOverride = value;
      _updateSystemOrientation();
    }
  }

  /// Initialize the app and all main actors.
  /// Loads settings, sets up services etc.
  /// 初始化app所有主要行为
  /// 加载相关设置等
  Future<void> bootstrap() async {
    debugPrint('bootstrap start...');
    // Set min-sizes for desktop apps
    ///若：是桌面端，设置最小尺寸
    if (PlatformInfo.isDesktop) {
      await DesktopWindow.setMinWindowSize($styles.sizes.minAppSize);
    }

    // Load any bitmaps the views might need
    ///加载所有Views所需的位图
    await AppBitmaps.init();

    // Set preferred refresh rate to the max possible (the OS may ignore this)
    ///尽可能地设置最大刷新率（系统可能会忽略该设置）
    if (PlatformInfo.isAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }

    // Settings
    ///加载设置逻辑
    await settingsLogic.load();

    // Localizations
    ///加载多语言
    await localeLogic.load();

    // Wonders Data
    ///初始化Wonders数据的业务逻辑
    wondersLogic.init();

    // Events
    ///初始化时间线事件
    timelineLogic.init();

    // Collectibles
    ///收藏品逻辑
    await collectiblesLogic.load();

    // Flag bootStrap as complete
    ///初始化完成标志位设为true
    isBootstrapComplete = true;

    // Load initial view (replace empty initial view which is covered by a native splash screen)
    ///加载起初的页面（替换空的初始页，该初始页面曾经被原生闪屏页所覆盖）
    bool showIntro = settingsLogic.hasCompletedOnboarding.value == false;
    if (showIntro) {
      appRouter.go(ScreenPaths.intro);
    } else {
      appRouter.go(ScreenPaths.home);
    }
  }

  ///展示一个全屏对话框的Route
  Future<T?> showFullscreenDialogRoute<T>(BuildContext context, Widget child,
      {bool transparent = false}) async {
    return await Navigator.of(context).push<T>(
      PageRoutes.dialog<T>(child, duration: $styles.times.pageTransition),
    );
  }

  /// Called from the UI layer once a MediaQuery has been obtained
  /// 该方法应该在外部获取到MediaQuery后，被UI层调用
  /// 判断设备是否属于小屏幕类型，从而设置垂直/水平翻转
  void handleAppSizeChanged() {
    debugPrint('handleAppSizeChanged:为屏幕设置合适的垂直/水平翻转');

    ///判断是否是小屏幕设备
    bool isSmall = display.size.shortestSide / display.devicePixelRatio < 600;

    /// Disable landscape layout on smaller form factors
    /// 若是小屏幕，则仅支持竖屏
    supportedOrientations =
        isSmall ? [Axis.vertical] : [Axis.vertical, Axis.horizontal];
    _updateSystemOrientation();
  }

  ///代表不同平台上渲染的【FlutterView】
  Display get display => PlatformDispatcher.instance.displays.first;

  ///是否应该使用NavigationRail
  ///横屏（宽>高）&& 高 >250
  bool shouldUseNavRail() {
    debugPrint(
        'app_logic-shouldUseNavRail:width ${display.size.width},height ${display.size.height}');
    return display.size.width > display.size.height &&
        display.size.height > 250;
  }

  /// Enable landscape, portrait or both. Views can call this method to override the default settings.
  /// For example, the [FullscreenVideoViewer] always wants to enable both landscape and portrait.
  /// If a view overrides this, it is responsible for setting it back to [supportedOrientations] when disposed.
  void _updateSystemOrientation() {
    ///_supportedOrientationsOverride:当前是否有自定义支持的翻转方向；否则按照默认设定的屏幕翻转方向
    final axisList = _supportedOrientationsOverride ?? supportedOrientations;
    //debugPrint('updateDeviceOrientation, supportedAxis: $axisList');
    final orientations = <DeviceOrientation>[];
    if (axisList.contains(Axis.vertical)) {
      orientations.addAll([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    if (axisList.contains(Axis.horizontal)) {
      orientations.addAll([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    SystemChrome.setPreferredOrientations(orientations);
  }
}

class AppImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    this.imageCache.maximumSizeBytes = 250 << 20; // 250mb
    return super.createImageCache();
  }
}
