import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'features/auth/presentation/login_screen.dart';
import 'features/beers/presentation/beer_list_screen.dart';
import 'theme/app_theme.dart';

class BeerBuddyApp extends StatelessWidget {
  const BeerBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeerBuddy',
      debugShowCheckedModeBanner: false,
      theme: BeerBuddyTheme.build(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<auth.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // NB: sinu projektis on praegu klass "BeerListcreen"
          return BeerListScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
