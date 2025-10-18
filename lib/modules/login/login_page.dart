import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_examen/modules/products/product_list_page.dart';
import 'package:app_examen/modules/products/product_list_page.dart';

enum AuthMode { signIn, signUp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  AuthMode _mode = AuthMode.signIn;

  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_mode == AuthMode.signIn) {
        await _auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductListPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_humanizeError(e));
    } catch (e) {
      _showError('Ocurrió un error inesperado. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Ingresa tu correo para enviar el enlace de recuperación.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Te enviamos un correo para recuperar tu contraseña.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(_humanizeError(e));
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _humanizeError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Correo inválido.';
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'email-already-in-use':
        return 'Este correo ya tiene una cuenta.';
      default:
        return 'Error: ${e.message ?? e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mode == AuthMode.signIn ? 'Iniciar sesión' : 'Crear cuenta',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Bienvenida/o 👋',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _mode == AuthMode.signIn
                      ? 'Ingresa con tu correo y contraseña.'
                      : 'Crea tu cuenta para continuar.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'tucorreo@ejemplo.com',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'El correo es obligatorio.';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim()))
                      return 'Formato de correo inválido.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'La contraseña es obligatoria.';
                    if (v.length < 6) return 'Mínimo 6 caracteres.';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 8),

                // Submit
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          _mode == AuthMode.signIn
                              ? 'Ingresar'
                              : 'Crear cuenta',
                        ),
                      ),

                const SizedBox(height: 12),

                // Toggle login/register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _mode == AuthMode.signIn
                          ? '¿No tienes cuenta?'
                          : '¿Ya tienes cuenta?',
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _mode = _mode == AuthMode.signIn
                              ? AuthMode.signUp
                              : AuthMode.signIn;
                        });
                      },
                      child: Text(
                        _mode == AuthMode.signIn
                            ? 'Crear cuenta'
                            : 'Iniciar sesión',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder de Home (se reemplazará por la vista de inicio con accesos a módulos)
class _HomeAfterLogin extends StatelessWidget {
  const _HomeAfterLogin();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¡Sesión iniciada!',
              style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí agregaremos accesos a Productos, Categorías y Proveedores.',
            ),
          ],
        ),
      ),
    );
  }
}
