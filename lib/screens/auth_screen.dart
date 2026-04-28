import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/assignment_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailLoginCtrl = TextEditingController();
  final _passLoginCtrl = TextEditingController();
  final _emailRegCtrl = TextEditingController();
  final _passRegCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscureLogin = true;
  bool _obscureReg = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailLoginCtrl.dispose();
    _passLoginCtrl.dispose();
    _emailRegCtrl.dispose();
    _passRegCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  void _setLoading(bool v) => setState(() => _isLoading = v);

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _afterLogin() async {
    final p = context.read<AssignmentProvider>();
    await p.load();
    p.listenToAssignments();
  }

  // ── Google Sign-In ────────────────────────────────
  Future<void> _googleSignIn() async {
    _setLoading(true);
    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (result != null) await _afterLogin();
    } catch (e) {
      _showError('Google sign-in failed. Try again.');
    } finally {
      _setLoading(false);
    }
  }

  // ── Email Login ───────────────────────────────────
  Future<void> _emailLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      await AuthService.instance.signInWithEmail(
        email: _emailLoginCtrl.text.trim(),
        password: _passLoginCtrl.text,
      );
      await _afterLogin();
    } on Exception catch (e) {
      _showError(_friendlyError(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  // ── Register ──────────────────────────────────────
  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_passRegCtrl.text != _passConfirmCtrl.text) {
      _showError('Passwords do not match.');
      return;
    }
    _setLoading(true);
    try {
      await AuthService.instance.registerWithEmail(
        email: _emailRegCtrl.text.trim(),
        password: _passRegCtrl.text,
      );
      await _afterLogin();
    } on Exception catch (e) {
      _showError(_friendlyError(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  // ── Forgot password ───────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailLoginCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email first.');
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      _showSuccess('Password reset email sent!');
    } catch (e) {
      _showError('Failed to send reset email.');
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found')) return 'No account found with this email.';
    if (raw.contains('wrong-password')) return 'Incorrect password.';
    if (raw.contains('email-already-in-use')) return 'Email already registered.';
    if (raw.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (raw.contains('invalid-email')) return 'Invalid email address.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    return 'Something went wrong. Try again.';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Title
              Text('Assignment\nManager',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                    height: 1.2,
                  )),
              const SizedBox(height: 8),
              Text('Track your deadlines, never miss a submission.',
                  style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface.withOpacity(0.5))),

              const SizedBox(height: 40),

              // Google button
              _GoogleButton(
                onTap: _isLoading ? null : _googleSignIn,
              ),

              const SizedBox(height: 24),

              // Divider
              Row(children: [
                Expanded(
                    child: Divider(color: scheme.outline.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or',
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withOpacity(0.4))),
                ),
                Expanded(
                    child: Divider(color: scheme.outline.withOpacity(0.3))),
              ]),

              const SizedBox(height: 24),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: scheme.onSurface.withOpacity(0.5),
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab content
              SizedBox(
                height: 320,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _loginForm(scheme),
                    _registerForm(scheme),
                  ],
                ),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 16),
                Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Login form ────────────────────────────────────
  Widget _loginForm(ColorScheme scheme) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _emailField(_emailLoginCtrl, scheme),
          const SizedBox(height: 14),
          _passwordField(
            ctrl: _passLoginCtrl,
            scheme: scheme,
            obscure: _obscureLogin,
            onToggle: () => setState(() => _obscureLogin = !_obscureLogin),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot password?',
                  style: TextStyle(
                      fontSize: 12, color: scheme.primary)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _emailLogin,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Login',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Register form ─────────────────────────────────
  Widget _registerForm(ColorScheme scheme) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _emailField(_emailRegCtrl, scheme),
          const SizedBox(height: 14),
          _passwordField(
            ctrl: _passRegCtrl,
            scheme: scheme,
            obscure: _obscureReg,
            hint: 'Password (min 6 chars)',
            onToggle: () => setState(() => _obscureReg = !_obscureReg),
          ),
          const SizedBox(height: 14),
          _passwordField(
            ctrl: _passConfirmCtrl,
            scheme: scheme,
            obscure: _obscureConfirm,
            hint: 'Confirm password',
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v != _passRegCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _register,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Account',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailField(TextEditingController ctrl, ColorScheme scheme) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email required';
        if (!v.contains('@')) return 'Invalid email';
        return null;
      },
      decoration: _inputDecoration(
          label: 'Email', icon: Icons.email_outlined, scheme: scheme),
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required ColorScheme scheme,
    required bool obscure,
    required VoidCallback onToggle,
    String hint = 'Password',
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator ??
          (v) {
            if (v == null || v.isEmpty) return 'Password required';
            if (v.length < 6) return 'Min 6 characters';
            return null;
          },
      decoration: _inputDecoration(
        label: hint,
        icon: Icons.lock_outline,
        scheme: scheme,
        suffix: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: scheme.onSurface.withOpacity(0.4)),
          onPressed: onToggle,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required ColorScheme scheme,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: scheme.onSurface.withOpacity(0.4)),
      suffixIcon: suffix,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary),
      ),
    );
  }
}

// ── Google button ──────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _GoogleButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G logo (SVG-like using Text)
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Text('G',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4))),
            ),
            const SizedBox(width: 10),
            Text('Continue with Google',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}