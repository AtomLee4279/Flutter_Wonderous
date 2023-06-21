import 'dart:async';

import 'package:flutter/material.dart';

///Throttler用于限制后续调用
class Throttler {
  Throttler(this.interval);
  final Duration interval;

  VoidCallback? _action;
  Timer? _timer;

  void call(VoidCallback action, {bool immediateCall = true}) {
    // Let the latest action override whatever was there before
    ///不管之前的action是什么，都覆盖
    _action = action;
    // If no timer is running, we want to start one
    if (_timer == null) {
      //  If immediateCall is true, we handle the action now
      ///immediateCall = true,即刻调用
      if (immediateCall) {
        _callAction();
      }
      // Start a timer that will temporarily throttle subsequent calls, and eventually make a call to whatever _action is (if anything)
      ///启动一个计时器，该计时器将暂时卡住_callAction的调用，
      ///并最终调用 最新的 _callAction （如果有的话）
      _timer = Timer(interval, _callAction);
    }
  }

  void _callAction() {
    _action?.call(); // If we have an action queued up, complete it.
    _timer = null;
  }

  void reset() {
    _action = null;
    _timer = null;
  }
}
