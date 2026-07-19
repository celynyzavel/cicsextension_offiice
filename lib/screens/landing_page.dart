import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/view_records.dart';
import '../models/user_role.dart';
import 'login_page.dart';
import 'records_form_page.dart';
import 'technology_transfer_form.dart';
import 'dashboard_page.dart';

extension _RoleInitials on UserRole {
  String get initials {
    switch (this) {
      case UserRole.facultyExtensionist:
        return 'FE';
      case UserRole.extensionCoordinator:
        return 'EC';
      case UserRole.collegeDean:
        return 'CD';
    }
  }
}

class LandingPage extends StatelessWidget {
  final UserRole role;
  const LandingPage({super.key, required this.role});

  bool get _isFaculty => role == UserRole.facultyExtensionist;

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kDanger, foregroundColor: kWhite),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kCardBorder),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            IconBadge(icon: icon, color: color, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isFaculty = _isFaculty;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const SizedBox.shrink(),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 
            child: Center(
              child: Text(
                role.label,
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            child: Text(
              role.initials,
              style: const TextStyle(
                color: kWhite,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 6),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                BrandHeaderBanner(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: const AssetImage("lib/assets/images/cicsLogo.jpg"),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Welcome to CICS Extension Projects and Technology Transfer",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width < 600 ? 20 : 25,
                          fontWeight: FontWeight.w600,
                          color: kWhite,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Leading Innovations, Transforming Lives, Building the Nation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width < 600 ? 13 : 15,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 30,
                        runSpacing: 6,
                        children: const [
                          _ContactTag(icon: Icons.apartment, text: "Alangilan Campus"),
                          _ContactTag(icon: Icons.call_outlined, text: "425-0139 / 425-0143"),
                          _ContactTag(icon: Icons.dialpad, text: "CICS Extension: 2223"),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel("Quick actions"),
                          const SizedBox(height: 6),
                          if (isFaculty)
                            _actionCard(
                              context,
                              icon: Icons.edit_note,
                              label: "Extension Projects",
                              subtitle: "Add programs, projects, and activities",
                              color: kPrimary,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RecordsFormPage()),
                                );
                              },
                            ),
                          if (!isFaculty)
                            _actionCard(
                              context,
                              icon: Icons.sync_alt_outlined,
                              label: "Technology Transfer",
                              subtitle: "Log a new technology transfer record",
                              color: kPrimary,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TechnologyTransferPage()),
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                          _actionCard(
                            context,
                            icon: Icons.folder_open,
                            label: "View Records",
                            subtitle: "Browse saved submissions",
                            color: kGold,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewRecordsPage(
                                    scope: isFaculty ? ViewRecordsScope.extensionOnly : ViewRecordsScope.all,
                                    canDeletePrograms: isFaculty,
                                    canDeleteTechTransfers: !isFaculty,
                                    canUpdatePrograms: isFaculty,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (!isFaculty) ...[
                            const SizedBox(height: 12),
                            _actionCard(
                              context,
                              icon: Icons.bar_chart_rounded,
                              label: "Dashboard",
                              subtitle: "View metrics and impact reports",
                              color: kSidebar,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}
