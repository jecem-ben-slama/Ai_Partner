import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/presentation/screens/history_screen.dart';
import 'package:ai_partner/presentation/screens/home_screen.dart';
import 'package:ai_partner/presentation/screens/settings_screen.dart';
import 'package:floating_navbar/floating_navbar.dart';
import 'package:floating_navbar/floating_navbar_item.dart';
import 'package:flutter/material.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int index = 0;
  final List<Widget> screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: false,
      body: screens[index],
      bottomNavigationBar: FloatingNavBar(
        resizeToAvoidBottomInset: false,
        color: Color(0xFF161925),
        selectedIconColor: Color(0xFFFDFFFC),
        unselectedIconColor: Color(0xFFFDFFFC),
        items: [
          FloatingNavBarItem(
            title: l10n.homeLabel,
            page: screens[0],
            iconData: Icons.home,
          ),
          FloatingNavBarItem(
            title: l10n.bookmarkLabel,
            page: screens[1],
            iconData: Icons.bookmark,
          ),
          FloatingNavBarItem(
            title: l10n.settingsLabel,
            page: screens[2],
            iconData: Icons.settings,
          ),
        ],
        horizontalPadding: 20,
        hapticFeedback: true,
        showTitle: true,
        onPageChanged: (value) {
          setState(() {
            index = value;
          });
        },
      ),
    );
  }
}
