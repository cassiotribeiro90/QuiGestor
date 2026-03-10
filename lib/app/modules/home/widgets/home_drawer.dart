import 'package:flutter/material.dart';
import 'side_menu.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SideMenu(isCompact: false), // Mesmo menu, mas dentro de um Drawer
    );
  }
}
