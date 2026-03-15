import 'package:flutter/material.dart';
import '../../app/modules/home/views/home_screen.dart';

mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  bool get isWeb => MediaQuery.of(context).size.width > 600;

  void navigateToWebContent(Widget content, String title) {
    if (isWeb) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      if (homeState != null) {
        homeState.navigateTo(content);
      }
    }
  }

  Future<R?> navigateToMobileScreen<R>(Widget screen) {
    return Navigator.push<R>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void navigateToDetail({
    required BuildContext context,
    required Widget webContent,
    required Widget mobileScreen,
    required String title,
  }) {
    if (isWeb) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      if (homeState != null) {
        homeState.navigateTo(webContent);
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => mobileScreen));
    }
  }
}
