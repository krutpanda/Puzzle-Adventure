import 'package:flutter/material.dart';

class AnimationService {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOut;

  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: defaultCurve,
      )),
      child: child,
    );
  }

  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: defaultCurve,
      )),
      child: child,
    );
  }

  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
    Offset? origin,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: defaultCurve,
      )),
      child: child,
    );
  }

  static Widget combinedTransition({
    required Widget child,
    required Animation<double> animation,
    Offset slideBegin = const Offset(0.0, 0.2),
    double scaleBegin = 0.95,
    double fadeBegin = 0.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            Tween<double>(
              begin: slideBegin.dy * 100,
              end: 0.0,
            )
                .animate(CurvedAnimation(
                  parent: animation,
                  curve: defaultCurve,
                ))
                .value,
          ),
          child: Opacity(
            opacity: Tween<double>(
              begin: fadeBegin,
              end: 1.0,
            )
                .animate(CurvedAnimation(
                  parent: animation,
                  curve: defaultCurve,
                ))
                .value,
            child: Transform.scale(
              scale: Tween<double>(
                begin: scaleBegin,
                end: 1.0,
              )
                  .animate(CurvedAnimation(
                    parent: animation,
                    curve: defaultCurve,
                  ))
                  .value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  static Route<T> pageRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return combinedTransition(
          animation: animation,
          child: child,
        );
      },
      transitionDuration: defaultDuration,
      reverseTransitionDuration: defaultDuration,
    );
  }

  static Widget staggeredList({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    Duration? delay,
    Axis direction = Axis.vertical,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      scrollDirection: direction,
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: AnimationController(
                vsync: Navigator.of(context) as TickerProvider,
                duration: defaultDuration,
              )..forward(),
              curve: Interval(
                (index / itemCount) / 2,
                1.0,
                curve: defaultCurve,
              ),
            ),
          ),
          builder: (context, child) => combinedTransition(
            animation: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: AnimationController(
                  vsync: Navigator.of(context) as TickerProvider,
                  duration: defaultDuration,
                )..forward(),
                curve: Interval(
                  (index / itemCount) / 2,
                  1.0,
                  curve: defaultCurve,
                ),
              ),
            ),
            child: itemBuilder(context, index),
          ),
        );
      },
    );
  }
} 