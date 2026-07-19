import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import 'landing_page.dart';
import 'dashboard_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  UserRole? _role;

  bool _obscure = true;
  bool _loading = false;

  final _emailRegex = RegExp(
    r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final formValid = _formKey.currentState!.validate();
    if (!formValid) return;

    if (_role == null) {
      showSnack(context, "Please select a role before logging in.");
      return;
    }

    setState(() => _loading = true);

    try {
      final userId = await AuthService.login(
        role: _role!,
        email: _email.text,
        password: _password.text,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (userId == null) {
        showSnack(
          context,
          "Invalid email or password for the selected role.",
        );
        return;
      }

      Session.set(email: _email.text, role: _role!, userId: userId);

      showSnack(context, "Login successful!", success: true);

      Widget destination;
      switch (_role!) {
        case UserRole.facultyExtensionist:
          destination = const LandingPage(role: UserRole.facultyExtensionist);
          break;
        case UserRole.extensionCoordinator:
          destination = const LandingPage(role: UserRole.extensionCoordinator);
          break;
        case UserRole.collegeDean:
          destination = const DashboardPage();
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, "Something went wrong. Please try again.");
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextSecondary),
      prefixIcon: Icon(icon, color: kPrimary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: kBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: kPrimary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8EF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 450,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: width < 600 ? 55 : 70,
                            backgroundImage:
                                const AssetImage("lib/assets/images/cicsLogo.jpg"),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "CICS Extension Projects and Technology Transfer",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Leading Innovations, Transforming Lives, Building the Nation",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 35),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: kCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kCardBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "LOGIN ACCOUNT",
                                  style: TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),

                                const SizedBox(height: 25),

                                DropdownButtonFormField<UserRole>(
                                  initialValue: _role,
                                  dropdownColor: kCard,
                                  style: const TextStyle(color: kTextPrimary),
                                  icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
                                  decoration: _fieldDecoration(
                                    label: "Role",
                                    icon: Icons.badge_outlined,
                                  ),
                                  items: UserRole.values
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(
                                            r.label,
                                            style: const TextStyle(color: kTextPrimary),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() => _role = v),
                                  validator: (v) =>
                                      v == null ? "Please select a role" : null,
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller: _email,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  style:
                                      const TextStyle(color: kTextPrimary),
                                  decoration: _fieldDecoration(
                                    label: "Email",
                                    icon: Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return "Email is required";
                                    }

                                    if (!_emailRegex
                                        .hasMatch(value.trim())) {
                                      return "Enter a valid email";
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  style:
                                      const TextStyle(color: kTextPrimary),
                                  decoration: _fieldDecoration(
                                    label: "Password",
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: kMuted,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscure = !_obscure;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return "Password is required";
                                    }

                                    if (value.length < 6) {
                                      return "Password must be at least 6 characters";
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 30),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimary,
                                        foregroundColor: kWhite,
                                        elevation: 0, // Container handles shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                color: kWhite,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              "LOG IN",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
