import 'package:flutter/material.dart';

import 'globals.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'discover_page.dart';
import 'profile_page.dart';
import 'chat_history_page.dart';
import 'chat_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Dog Tinder',
      theme: ThemeData(
        primaryColor: const Color(persimon),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(persimon)),
        scaffoldBackgroundColor: const Color(creamWhite),
        useMaterial3: false,
      ),
      home: const _RootGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/discover': (_) => const DiscoverPage(),
        '/profile': (_) => const ProfilePage(),
        '/chats': (_) => const ChatHistoryPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = (settings.arguments as Map<String, dynamic>?) ?? {};
          final dogName = (args['dogName'] as String?) ?? '';
          final dogImageUrl = (args['dogImageUrl'] as String?) ?? '';
          return MaterialPageRoute(
            builder: (_) => ChatPage(
              dogName: dogName,
              dogImageUrl: dogImageUrl,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Ekran startowy zależnie od tego czy mamy zalogowanego usera
    if (loggedIn && user != null) {
      return const DiscoverPage();
    }
    return const LoginPage();
  }
}
