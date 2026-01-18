import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _email.text.trim();
    final pass = _password.text;
    final pass2 = _password2.text;

    try {
      if (email.isEmpty || pass.isEmpty) {
        setState(() => _error = 'Sisesta email ja parool.');
        return;
      }

      if (pass != pass2) {
        setState(() => _error = 'Paroolid ei ühti.');
        return;
      }

      if (pass.length < 6) {
        setState(() => _error = 'Parool peab olema vähemalt 6 tähemärki.');
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (mounted) Navigator.of(context).pop(); // back to Login
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'email-already-in-use' => 'See email on juba kasutusel.',
          'invalid-email' => 'Emaili vorming on vale.',
          'weak-password' => 'Parool on liiga nõrk.',
          _ => 'Register failed: ${e.message ?? e.code}',
        };
      });
    } catch (e) {
      setState(() => _error = 'Register failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              t.scaffoldBackgroundColor,
              t.colorScheme.surface.withOpacity(0.88),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: t.colorScheme.primary.withOpacity(0.18),
                                border: Border.all(
                                  color: t.colorScheme.primary.withOpacity(0.35),
                                ),
                              ),
                              child: Icon(
                                Icons.local_bar,
                                color: t.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create account',
                                  style: t.textTheme.headlineSmall,
                                ),
                                Text(
                                  'BeerBuddy • Your private beer journal',
                                  style: t.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password2,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Repeat password',
                            prefixIcon: Icon(Icons.lock_reset),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: t.textTheme.bodySmall?.copyWith(
                              color: t.colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        ElevatedButton.icon(
                          onPressed: _loading ? null : _register,
                          icon: _loading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.person_add),
                          label: const Text('Create account'),
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton(
                          onPressed: _loading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Back to login'),
                        ),

                        const SizedBox(height: 6),
                        Text(
                          'Offline-first • Private • Syncs to Firebase',
                          style: t.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
