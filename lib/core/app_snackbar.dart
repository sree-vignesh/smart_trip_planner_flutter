import 'package:flutter/material.dart';
import 'package:smart_trip_planner/core/colors.dart';

class AppSnackbar {
  /// Show a floating, animated snackbar
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    double bottomMargin = 80,
    double horizontalMargin = 16,
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: bottomMargin,
        left: horizontalMargin,
        right: horizontalMargin,
      ),
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(120),
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
    );

    // Use ScaffoldMessenger to show the snackBar
    ScaffoldMessenger.of(context).showSnackBar(
      // Wrap in SlideTransition for custom animation
      SnackBar(
        content: snackBar.content,
        duration: snackBar.duration,
        behavior: snackBar.behavior,
        margin: snackBar.margin,
        elevation: snackBar.elevation,
        shape: snackBar.shape,
        backgroundColor: snackBar.backgroundColor,
        animation: CurvedAnimation(
          parent: AnimationController(
            vsync: Scaffold.of(context),
            duration: const Duration(milliseconds: 400),
          ),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
