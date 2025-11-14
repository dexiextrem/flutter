// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_list_screen.dart';
import 'screens/eshop_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const ProviderScope(child: HvaApp()));
}

class HvaApp extends StatelessWidget {
  const HvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HVA Νέα',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

// ————————————————————————
// MAIN SCREEN – APPBAR ΜΟΝΟ ΣΤΑ 3 TABS
// ————————————————————————
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  // ΛΙΣΤΑ ΜΕ ΤΙΤΛΟΥΣ APPBAR
  static const List<String> _appBarTitles = [
    '', // Αρχική → ΧΩΡΙΣ APPBAR
    'Νέα',
    'eShop',
    'Σχετικά',
  ];

  Widget _buildOffstageNavigator(int tabIndex) {
    return Offstage(
      offstage: _selectedIndex != tabIndex,
      child: Navigator(
        key: _navigatorKeys[tabIndex],
        onGenerateRoute: (settings) {
          Widget page;
          switch (tabIndex) {
            case 0:
              page = const HomeScreen();
              break;
            case 1:
              page = const NewsListScreen();
              break;
            case 2:
              page = const EshopScreen();
              break;
            case 3:
              page = const AboutScreen();
              break;
            default:
              page = const HomeScreen();
          }
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: Duration.zero,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAppBar = _selectedIndex != 0; // ΜΟΝΟ ΑΝ ΔΕΝ ΕΙΝΑΙ ΑΡΧΙΚΗ

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigator = _navigatorKeys[_selectedIndex]!.currentState!;
        if (navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: Text(_appBarTitles[_selectedIndex]),
              )
            : null, // ΧΩΡΙΣ APPBAR ΣΤΗΝ ΑΡΧΙΚΗ
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (_selectedIndex == index) {
              _navigatorKeys[index]!.currentState!.popUntil((route) => route.isFirst);
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6A1B9A),
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Αρχική'),
            BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Νέα'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'eShop'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Σχετικά'),
          ],
        ),
      ),
    );
  }
}