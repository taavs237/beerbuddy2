import 'package:flutter/material.dart';
import '../state/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.register(_email.text.trim(), _password.text);

      if (!mounted) return;
      Navigator.of(context).pop(); // tagasi LoginScreeni
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();

    // FirebaseAuthException tuleb tihti kujul "[firebase_auth/code] message"
    if (msg.contains('email-already-in-use')) {
      return 'See e-mail on juba kasutusel. Proovi logida sisse.';
    }
    if (msg.contains('weak-password')) {
      return 'Parool on liiga nõrk. Pane vähemalt 6 tähemärki.';
    }
    if (msg.contains('invalid-email')) {
      return 'Emaili vorming on vale.';
    }

    return 'Registreerimine ebaõnnestus: $msg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BeerBuddy • Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'At least 6 characters',
              ),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _onRegister,
                child: _loading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
