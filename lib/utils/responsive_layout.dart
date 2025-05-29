import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const double phoneBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < phoneBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= phoneBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneBreakpoint) return 2;
    if (width < tabletBreakpoint) return 3;
    if (width < desktopBreakpoint) return 4;
    return 5;
  }

  static double getGridItemSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.05;
    final crossAxisCount = getGridCrossAxisCount(context);
    final spacing = width * 0.02;
    return (width - (padding * 2) - (spacing * (crossAxisCount - 1))) / crossAxisCount;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isPhone(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getFontSize(BuildContext context, double baseSize) {
    if (isPhone(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }

  static Widget builder({
    required BuildContext context,
    required Widget Function(BuildContext, BoxConstraints) mobile,
    Widget Function(BuildContext, BoxConstraints)? tablet,
    Widget Function(BuildContext, BoxConstraints)? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint && desktop != null) {
          return desktop(context, constraints);
        }
        if (constraints.maxWidth >= phoneBreakpoint && tablet != null) {
          return tablet(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }

  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneBreakpoint) {
      return width * 0.9;
    } else if (width < tabletBreakpoint) {
      return width * 0.7;
    } else if (width < desktopBreakpoint) {
      return width * 0.5;
    } else {
      return width * 0.4;
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneBreakpoint) {
      return width;
    } else if (width < tabletBreakpoint) {
      return phoneBreakpoint;
    } else if (width < desktopBreakpoint) {
      return tabletBreakpoint;
    } else {
      return desktopBreakpoint;
    }
  }

  static Widget centerContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
} 