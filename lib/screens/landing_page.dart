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

  // ============================================================
  // LOGOUT — confirms with the user, then clears the navigation
  // stack and sends them back to the Login page.
  // ============================================================
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('CICS Extension Projects and Technology Transfer'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _handleTap,
                onDoubleTap: _handleDoubleTap,
                child: AnimatedScale(
                  scale: _isEnlarged ? 1.35 : 1.0,
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
                          color: _avatarColors[_colorIndex].withValues(alpha: 0.6),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                          "https://scontent.fmnl7-1.fna.fbcdn.net/v/t39.30808-6/531819041_1238315274973150_920925310850444405_n.jpg?stp=dst-jpg_tt6&cstp=mx960x958&ctp=s960x958&_nc_cat=108&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeFjSwdnGdtEox9gaLllTohRcKqjpVE-Zz5wqqOlUT5nPvTyOt8jofsez9noUP3ZmVpDbqkSR1CN513heq1XPvA-&_nc_ohc=D4jHcajGWj4Q7kNvwHlH6hS&_nc_oc=AdqmOLnwXj0ep2S_4PQkWJwx2EJIqV1aI1bw8okbsoBye5RALnjx1sGvUM7ofqPVzhA&_nc_zt=23&_nc_ht=scontent.fmnl7-1.fna&_nc_gid=48KHjks8dhIzGVQ4-aar5g&_nc_ss=7b2a8&oh=00_AQCHvtC4VgAo0DsNPuQvm33wB56PlOSUWwwVdQTkvdCr6g&oe=6A520A87"),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Welcome to CICS Extension Projects and Technology Transfer',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kWhite)),
              const SizedBox(height: 10),
              const Text('Leading Innovations, Transforming Lives, Building the Nation',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: kTextSecondary)),
              const SizedBox(height: 20),
              const Text('Alangilan Campus',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: kTextSecondary)),
              const SizedBox(height: 10),
              const Text('Trunkline: 425-0139; 425-0143',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: kTextSecondary)),
              const SizedBox(height: 10),
              const Text('CICS Extension: 2223',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: kTextSecondary)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _actionCard(
                    context,
                    icon: Icons.edit_note,
                    label: 'Extension Projects',
                    color: kPrimary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecordsFormPage()),
                    ),
                  ),
                  _actionCard(
                    context,
                    icon: Icons.edit_note,
                    label: 'Technology Transfer',
                    color: kPrimary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TechnologyTransferPage()),
                    ),
                  ),
                  _actionCard(
                    context,
                    icon: Icons.folder_open,
                    label: 'View Records',
                    color: kGold,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ViewRecordsPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
