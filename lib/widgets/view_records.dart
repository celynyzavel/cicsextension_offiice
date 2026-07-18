import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/records.dart';
import 'common_widgets.dart';

enum ViewRecordsScope { extensionOnly, all }

class ViewRecordsPage extends StatefulWidget {
  final ViewRecordsScope scope;
  final bool canDeletePrograms;
  final bool canDeleteTechTransfers;

  const ViewRecordsPage({
    super.key,
    this.scope = ViewRecordsScope.all,
    this.canDeletePrograms = true,
    this.canDeleteTechTransfers = true,
  });

  @override
  State<ViewRecordsPage> createState() => _ViewRecordsPageState();
}

class _ViewRecordsPageState extends State<ViewRecordsPage> {
  Widget _recordCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required List<MapEntry<String, dynamic>> entries,
    List<Widget> nested = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
        boxShadow: kCardShadow,
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          collapsedIconColor: kMuted,
          iconColor: kTextSecondary,
          leading: IconBadge(icon: icon, color: accent, size: 38),
          title: Text(
            title,
            style: const TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(alignment: Alignment.centerLeft, child: StatusChip(subtitle)),
                ),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: [
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(color: kTextPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (nested.isNotEmpty) ...[
              const Divider(color: kCardBorder, height: 20, indent: 16, endIndent: 16),
              ...nested,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTechTransfers = widget.scope == ViewRecordsScope.all;

    final hasPrograms = RecordStorage.programs.isNotEmpty;
    final hasTechTransfers = showTechTransfers && RecordStorage.techTransfers.isNotEmpty;

    final canClearPrograms = widget.canDeletePrograms && hasPrograms;
    final canClearTechTransfers = widget.canDeleteTechTransfers && hasTechTransfers;
    final canClearAnything = canClearPrograms || canClearTechTransfers;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text("View Records"),
        centerTitle: true,
        backgroundColor: kSidebar,
        foregroundColor: kWhite,
      ),

      body: (!hasPrograms && !hasTechTransfers)
          ? const EmptyState(
              icon: Icons.folder_off_outlined,
              title: "No Records Available",
              subtitle: "Submitted programs, projects, and technology transfers will appear here.",
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                if (hasTechTransfers) ...[
                  SectionLabel("Technology Transfer"),
                  ...RecordStorage.techTransfers.map(
                    (techTransfer) => _recordCard(
                      icon: Icons.sync_alt,
                      accent: kGold,
                      title: techTransfer.data["System Name"] ?? "Technology Transfer",
                      subtitle: techTransfer.data["Usage Status"] ?? "",
                      entries: techTransfer.data.entries.toList(),
                    ),
                  ),
                  if (hasPrograms) const SizedBox(height: 8),
                ],

                if (hasPrograms) ...[
                  SectionLabel("Extension Projects"),
                  ...RecordStorage.programs.map((program) {
                    return _recordCard(
                      icon: Icons.folder,
                      accent: kPrimary,
                      title: program.data["Program Title"] ?? "Program",
                      subtitle: program.data["Status"] ?? "",
                      entries: program.data.entries.toList(),
                      nested: program.projects.map((project) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kCardBorder),
                            ),
                            child: Theme(
                              data: ThemeData(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                collapsedIconColor: kMuted,
                                iconColor: kTextSecondary,
                                leading: const Icon(Icons.folder_open, color: kGold),
                                title: Text(
                                  project.data["Project Title"] ?? "Project",
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: (project.data["Status"] ?? "").isEmpty
                                    ? null
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: StatusChip(project.data["Status"] ?? ""),
                                        ),
                                      ),
                                children: [
                                  ...project.data.entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 130,
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(
                                                color: kTextSecondary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              entry.value.toString(),
                                              style: const TextStyle(color: kTextPrimary, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ...project.activities.map(
                                    (activity) => Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: kCard,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: kCardBorder),
                                        ),
                                        child: Theme(
                                          data: ThemeData(dividerColor: Colors.transparent),
                                          child: ExpansionTile(
                                            collapsedIconColor: kMuted,
                                            iconColor: kTextSecondary,
                                            leading: const Icon(Icons.event, color: Color(0xFF2F9E44)),
                                            title: Text(
                                              activity.data["Activity Title"] ?? "Activity",
                                              style: const TextStyle(
                                                color: kTextPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            subtitle: (activity.data["Status"] ?? "").isEmpty
                                                ? null
                                                : Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: StatusChip(activity.data["Status"] ?? ""),
                                                    ),
                                                  ),
                                            children: [
                                              ...activity.data.entries.map(
                                                (entry) => Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 16, vertical: 6),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 130,
                                                        child: Text(
                                                          entry.key,
                                                          style: const TextStyle(
                                                            color: kTextSecondary,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          entry.value.toString(),
                                                          style: const TextStyle(
                                                              color: kTextPrimary, fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (activity.knowledgeGain != null)
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 16, vertical: 6),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(
                                                        width: 130,
                                                        child: Text(
                                                          'Knowledge Gain',
                                                          style: TextStyle(
                                                            color: kTextSecondary,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${activity.knowledgeGain!.toStringAsFixed(1)}%',
                                                          style: const TextStyle(
                                                            color: kSuccess,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 13,
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
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ],
            ),

      floatingActionButton: canClearAnything
          ? FloatingActionButton.extended(
              backgroundColor: kDanger,
              foregroundColor: kWhite,
              tooltip: "Clear Records",
              icon: const Icon(Icons.delete_forever),
              label: const Text("Clear"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    icon: const Icon(Icons.warning_amber_rounded, color: kDanger, size: 30),
                    title: const Text("Clear Records"),
                    content: Text(
                      canClearPrograms && canClearTechTransfers
                          ? "Are you sure you want to delete all records you manage (Extension Projects and Technology Transfer)?"
                          : canClearPrograms
                              ? "Are you sure you want to delete all saved Extension Project records?"
                              : "Are you sure you want to delete all saved Technology Transfer records?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel", style: TextStyle(color: kTextSecondary)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDanger,
                          foregroundColor: kWhite,
                        ),
                        onPressed: () {
                          setState(() {
                            if (canClearPrograms) {
                              RecordStorage.programs.clear();
                            }
                            if (canClearTechTransfers) {
                              RecordStorage.techTransfers.clear();
                            }
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }
}
