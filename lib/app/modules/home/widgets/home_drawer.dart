import 'package:flutter/material.dart';
import 'side_menu.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 [HomeDrawer] Renderizando...');
    return const Drawer(
      child: SideMenu(isCompact: false), // Usa o mesmo menu centralizado
    );
  }
}
