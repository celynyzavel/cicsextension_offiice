import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/view_records.dart';
import 'login_page.dart';
import 'records_form_page.dart';
import 'technology_transfer_form.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isEnlarged = false;

  int _colorIndex = 0;
  final List<Color> _avatarColors = [kCard, const Color.fromARGB(255, 61, 224, 28)];

  void _handleTap() {
    setState(() => _isEnlarged = !_isEnlarged);
    showSnack(context, _isEnlarged ? 'Image enlarged!' : 'Image back to normal size');
  }

  void _handleDoubleTap() {
    setState(() => _colorIndex = (_colorIndex + 1) % _avatarColors.length);
    showSnack(context, 'Image color changed!');
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Log Out', style: TextStyle(color: kWhite)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: kOrange)),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  final width = MediaQuery.of(context).size.width;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: EdgeInsets.all(width * 0.025),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: width < 600 ? 30 : 36,
          ),
          SizedBox(height: width * 0.02),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kWhite,
              fontSize: width < 600 ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: kBackground,
    appBar: AppBar(
      title: const Text(
        'CICS Extension Projects and Technology Transfer',
      ),
      centerTitle: true,
      backgroundColor: kSidebar,
      foregroundColor: kWhite,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _confirmLogout(context),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;

        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 650) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.05),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _handleTap,
                    onDoubleTap: _handleDoubleTap,
                    child: AnimatedScale(
                      scale: _isEnlarged ? 1.35 : 1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _avatarColors[_colorIndex],
                          boxShadow: [
                            BoxShadow(
                              color: _avatarColors[_colorIndex]
                                  .withValues(alpha: 0.6),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: width < 600 ? 55 : 70,
                          backgroundImage: const NetworkImage(kAvatarUrl),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Welcome to CICS Extension Projects and Technology Transfer",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width < 600 ? 24 : 30,
                      fontWeight: FontWeight.bold,
                      color: kWhite,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Leading Innovations, Transforming Lives, Building the Nation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width < 600 ? 15 : 18,
                      color: kTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Alangilan Campus",
                    style: TextStyle(
                      fontSize: width < 600 ? 15 : 17,
                      color: kTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Trunkline: 425-0139; 425-0143",
                    style: TextStyle(
                      fontSize: width < 600 ? 15 : 17,
                      color: kTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "CICS Extension: 2223",
                    style: TextStyle(
                      fontSize: width < 600 ? 15 : 17,
                      color: kTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio:
                        crossAxisCount == 1 ? 3.2 : 1.2,
                    children: [
                      _actionCard(
                        context,
                        icon: Icons.edit_note,
                        label: "Extension Projects",
                        color: kPrimary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RecordsFormPage(),
                            ),
                          );
                        },
                      ),
                      _actionCard(
                        context,
                        icon: Icons.sync_alt_outlined,
                        label: "Technology Transfer",
                        color: kPrimary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TechnologyTransferPage(),
                            ),
                          );
                        },
                      ),
                      _actionCard(
                        context,
                        icon: Icons.folder_open,
                        label: "View Records",
                        color: kGold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ViewRecordsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}
