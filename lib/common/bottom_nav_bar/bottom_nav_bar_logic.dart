import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavBarModel {
  final int navIndex;

  NavBarModel({required this.navIndex});

  NavBarModel copyWith({int? navIndex}) {
    return NavBarModel(
      navIndex: navIndex ?? this.navIndex,
    );
  }
}

class NavBarNotifier extends StateNotifier<NavBarModel> {
  NavBarNotifier() : super(NavBarModel(navIndex: 0));

  void setNavIndex(int index) {
    state = state.copyWith(navIndex: index);
  }
}

final bottomNavBarLogicProvider =
StateNotifierProvider<NavBarNotifier, NavBarModel>((ref) {
  return NavBarNotifier();
});