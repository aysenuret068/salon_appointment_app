import 'package:flutter/material.dart';
import '../services/admin_auth_service.dart';
import '../services/admin_session.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AdminAuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Email ve şifre zorunludur.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final session = await _auth.login(email: _email.text, password: _password.text);
      await AdminSession.save(session);
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/admin-panel', (_) => false);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF080D18),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(padding: const EdgeInsets.all(36), decoration: BoxDecoration(
        color: const Color(0xFF111827), border: Border.all(color: const Color(0xFF253047)),
        borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 32)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFF97316), size: 48),
          const SizedBox(height: 20),
          const Text('Yönetim Paneli', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Yetkili Personel Girişi', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
          const SizedBox(height: 30),
          _field(_email, 'Email', Icons.mail_outline), const SizedBox(height: 16),
          _field(_password, 'Şifre', Icons.lock_outline, password: true),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_error!, style: const TextStyle(color: Color(0xFFFCA5A5)))),
          const SizedBox(height: 24),
          SizedBox(height: 50, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
            onPressed: _loading ? null : _login,
            child: _loading ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Yönetim Paneline Giriş', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]),
      ),
    ))),
  );

  Widget _field(TextEditingController controller, String label, IconData icon, {bool password = false}) => TextField(
    controller: controller, obscureText: password && _obscure, onSubmitted: (_) { if (!_loading) _login(); },
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Color(0xFF94A3B8)), prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      suffixIcon: password ? IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF94A3B8))) : null,
      filled: true, fillColor: const Color(0xFF0B1220), enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFF97316)), borderRadius: BorderRadius.circular(10))));
}
