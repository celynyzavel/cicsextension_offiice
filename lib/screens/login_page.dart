import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'landing_page.dart';

const kAvatarUrl =
    "https://scontent.fmnl7-1.fna.fbcdn.net/v/t39.30808-6/531819041_1238315274973150_920925310850444405_n.jpg?stp=dst-jpg_tt6&cstp=mx960x958&ctp=s960x958&_nc_cat=108&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeFjSwdnGdtEox9gaLllTohRcKqjpVE-Zz5wqqOlUT5nPvTyOt8jofsez9noUP3ZmVpDbqkSR1CN513heq1XPvA-&_nc_ohc=D4jHcajGWj4Q7kNvwHlH6hS&_nc_oc=AdqmOLnwXj0ep2S_4PQkWJwx2EJIqV1aI1bw8okbsoBye5RALnjx1sGvUM7ofqPVzhA&_nc_zt=23&_nc_ht=scontent.fmnl7-1.fna&_nc_gid=48KHjks8dhIzGVQ4-aar5g&_nc_ss=7b2a8&oh=00_AQCHvtC4VgAo0DsNPuQvm33wB56PlOSUWwwVdQTkvdCr6g&oe=6A520A87";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    showSnack(context, 'Login successful!');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LandingPage()));
  }

  InputDecoration _fieldDecoration({required String label, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextSecondary),
      prefixIcon: Icon(icon, color: kPrimary),
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      filled: true,
      fillColor: kCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(kAvatarUrl),
                  ),
                  const SizedBox(height: 16),
                  const Text('CICS Extension Projects and Technology Transfer',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kWhite)),
                  const SizedBox(height: 6),
                  const Text('Sign in to continue',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: kTextSecondary)),
                  const SizedBox(height: 32),
                  cardBox(
                    child: TextFormField(
                      controller: _email,
                      style: const TextStyle(color: kWhite),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(label: 'Email', icon: Icons.email_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Email is required'
                          : (!_emailRegex.hasMatch(v.trim()) ? 'Enter a valid email address' : null),
                    ),
                  ),
                  cardBox(
                    child: TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      style: const TextStyle(color: kWhite),
                      decoration: _fieldDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: kMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : (v.length < 6 ? 'Password must be at least 6 characters' : null),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: kWhite,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
                          : const Text('Log In', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
