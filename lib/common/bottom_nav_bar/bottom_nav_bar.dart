import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

import '../../router/app_router.dart';
import '../../utils/context_extensions.dart';
import 'nav_bar_logic.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(bottomNavBarLogicProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WaterDropNavBar(
        key: const Key('bottom_nav_bar'),
        backgroundColor: context.colorScheme.surface,
        waterDropColor: context.colorScheme.primary,
        selectedIndex: nav.navIndex,
        onItemSelected: (int index) {
          ref.read(bottomNavBarLogicProvider.notifier).setNavIndex(index);

          switch (index) {
            case 0:
              context.go(SGRoute.firstScreen.route);
              break;
            case 1:
              context.go(SGRoute.secondScreen.route);
              break;
            case 2:
              context.go(SGRoute.countriesScreen.route);
              break;
          }
        },
        barItems: <BarItem>[
          BarItem(
            filledIcon: Ionicons.home,
            outlinedIcon: Ionicons.home_outline,
          ),
          BarItem(
            filledIcon: Ionicons.information_circle,
            outlinedIcon: Ionicons.information_circle_outline,
          ),
          BarItem(
            filledIcon: Ionicons.globe,
            outlinedIcon: Ionicons.globe_outline,
          ),
        ],
      ),
    );
  }
}