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

  final _emailRegex = RegExp(
    r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _loading = false);

    showSnack(context, "Login successful!");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LandingPage(),
      ),
    );
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
      backgroundColor: kBackground,
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
                                const NetworkImage(kAvatarUrl),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "CICS Extension Projects and Technology Transfer",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kWhite,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Leading Innovations, Transforming Lives, Building the Nation",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 15,
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
                                  color: Colors.black.withOpacity(.25),
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
                                    color: kWhite,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),

                                const SizedBox(height: 25),

                                TextFormField(
                                  controller: _email,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  style:
                                      const TextStyle(color: kWhite),
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
                                      const TextStyle(color: kWhite),
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

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        _loading ? null : _login,
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary,
                                      foregroundColor: kWhite,
                                      elevation: 4,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child:
                                                CircularProgressIndicator(
                                              color: kWhite,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "LOG IN",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
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
