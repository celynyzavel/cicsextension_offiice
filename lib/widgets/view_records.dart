import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/records.dart';
import '../models/form_fields.dart';
import '../services/firestore_services.dart';
import '../services/session.dart';
import 'common_widgets.dart';
import 'edit_record_dialog.dart';

enum ViewRecordsScope { extensionOnly, all }

class ViewRecordsPage extends StatefulWidget {
  final ViewRecordsScope scope;
  final bool canDeletePrograms;
  final bool canDeleteTechTransfers;
  final bool canUpdatePrograms;

  const ViewRecordsPage({
    super.key,
    this.scope = ViewRecordsScope.all,
    this.canDeletePrograms = true,
    this.canDeleteTechTransfers = true,
    this.canUpdatePrograms = true,
  });

  @override
  State<ViewRecordsPage> createState() => _ViewRecordsPageState();
}

class _ViewRecordsPageState extends State<ViewRecordsPage> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _refresh(showSnackOnSuccess: false);
  }

  Future<void> _refresh({bool showSnackOnSuccess = true}) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await FirestoreService.loadAllRecordsIntoStorage();
      if (mounted) {
        setState(() {});
        if (showSnackOnSuccess) {
          showSnack(context, "Records refreshed.", success: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, "Failed to refresh records: $e", success: false);
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  bool _ownedByCurrentUser(Map<String, dynamic> data) {
    final userId = Session.currentUserId ?? '';
    return userId.isNotEmpty && (data['User ID'] ?? '').toString() == userId;
  }

  List<ActivityRecord> _visibleActivities(ProjectRecord project) {
    if (widget.scope != ViewRecordsScope.extensionOnly) return project.activities;
    return project.activities.where((a) => _ownedByCurrentUser(a.data)).toList();
  }

  List<ProjectRecord> _visibleProjects(ProgramRecord program) {
    if (widget.scope != ViewRecordsScope.extensionOnly) return program.projects;
    return program.projects.where((p) => _ownedByCurrentUser(p.data)).toList();
  }

 
  List<ProgramRecord> _visiblePrograms() {
    if (widget.scope != ViewRecordsScope.extensionOnly) {
      return RecordStorage.programs;
    }

    final result = <ProgramRecord>[];
    ProgramRecord? standaloneProjectsProgram;
    ProgramRecord? standaloneActivitiesProgram;
    ProjectRecord? standaloneActivitiesProject;


    ProgramRecord ensureStandaloneProjectsProgram() {
      return standaloneProjectsProgram ??= ProgramRecord(
        {"Program Title": "My Standalone Projects", "type": "Program"},
        id: "MY-STANDALONE-PROJECTS",
      );
    }

    ProjectRecord ensureStandaloneActivitiesProject() {
      if (standaloneActivitiesProject == null) {
        standaloneActivitiesProgram = ProgramRecord(
          {"Program Title": "My Standalone Activities", "type": "Program"},
          id: "MY-STANDALONE-ACTIVITIES",
        );
        standaloneActivitiesProject = ProjectRecord(
          {
            "Project Title": "General Activities",
            "type": "Project",
            "User ID": Session.currentUserId ?? '',
          },
          id: "MY-STANDALONE-ACTIVITIES-PROJECT",
        );
        standaloneActivitiesProgram!.projects.add(standaloneActivitiesProject!);
      }
      return standaloneActivitiesProject!;
    }

    for (final program in RecordStorage.programs) {
      final programOwned = _ownedByCurrentUser(program.data);
      if (programOwned) result.add(program);

      for (final project in program.projects) {
        final projectOwned = _ownedByCurrentUser(project.data);
        if (projectOwned && !programOwned) {
          ensureStandaloneProjectsProgram().projects.add(project);
        }
        if (!projectOwned) {
          for (final activity in project.activities) {
            if (_ownedByCurrentUser(activity.data)) {
              ensureStandaloneActivitiesProject().activities.add(activity);
            }
          }
        }
      }
    }

    if (standaloneProjectsProgram != null) result.add(standaloneProjectsProgram!);
    if (standaloneActivitiesProgram != null) result.add(standaloneActivitiesProgram!);
    return result;
  }

  Widget _recordCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required List<MapEntry<String, dynamic>> entries,
    List<Widget> nested = const [],
    VoidCallback? onUpdate,
    VoidCallback? onDelete,
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
            ...entries.where((e) => e.value.toString().trim().isNotEmpty).map(
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
            actionButtonRow(onUpdate: onUpdate, onDelete: onDelete),
            if (nested.isNotEmpty) ...[
              const Divider(color: kCardBorder, height: 20, indent: 16, endIndent: 16),
              ...nested,
            ],
          ],
        ),
      ),
    );
  }

  Widget actionButtonRow({VoidCallback? onUpdate, VoidCallback? onDelete}) {
    if (onUpdate == null && onDelete == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onDelete != null) ...[
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 17, color: kDanger),
              label: const Text("Delete", style: TextStyle(color: kDanger)),
            ),
            if (onUpdate != null) const SizedBox(width: 4),
          ],
          if (onUpdate != null)
            TextButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text("Update"),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: kDanger, size: 30),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: kTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDanger, foregroundColor: kWhite),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTechTransfers = widget.scope == ViewRecordsScope.all;
    final visiblePrograms = _visiblePrograms();

    final hasPrograms = visiblePrograms.isNotEmpty;
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
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _refreshing ? null : () => _refresh(),
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: kWhite),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),

      body: (!hasPrograms && !hasTechTransfers)
          ? RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.folder_off_outlined,
                    title: "No Records Available",
                    subtitle:
                        "Submitted programs, projects, and technology transfers will appear here.",
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      onUpdate: () => showEditRecordSheet(
                        context,
                        title: "Update Technology Transfer",
                        fields: technologyTransferFields,
                        data: techTransfer.data,
                        onSave: (updated) {
                          setState(() => techTransfer.data = updated);
                          showSnack(context, "Information updated successfully.", success: true);
                          if (techTransfer.docId != null) {
                            FirestoreService
                                .updateTechnologyTransfer(techTransfer.docId!, updated)
                                .catchError((e) {
                              if (mounted) {
                                showSnack(context, "Failed to sync update: $e", success: false);
                              }
                            });
                          }
                        },
                      ),
                      onDelete: widget.canDeleteTechTransfers
                          ? () => _confirmDelete(
                                context,
                                title: "Delete Technology Transfer",
                                message:
                                    "Are you sure you want to delete \"${techTransfer.data["System Name"] ?? "this record"}\"? This cannot be undone.",
                                onConfirm: () {
                                  setState(
                                    () => RecordStorage.techTransfers.remove(techTransfer),
                                  );
                                  if (techTransfer.docId != null) {
                                    FirestoreService
                                        .deleteTechnologyTransfer(techTransfer.docId!)
                                        .catchError((e) {
                                      if (mounted) {
                                        showSnack(context, "Failed to sync delete: $e",
                                            success: false);
                                      }
                                    });
                                  }
                                },
                              )
                          : null,
                    ),
                  ),
                  if (hasPrograms) const SizedBox(height: 8),
                ],

                if (hasPrograms) ...[
                  SectionLabel("Extension Projects"),
                  ...visiblePrograms.map((program) {
                    return _recordCard(
                      icon: Icons.folder,
                      accent: kPrimary,
                      title: program.data["Program Title"] ?? "Program",
                      subtitle: program.data["Status"] ?? "",
                      entries: program.data.entries.toList(),
                      onUpdate: widget.canUpdatePrograms
                          ? () => showEditRecordSheet(
                                context,
                                title: "Update Program",
                                fields: programFields,
                                data: program.data,
                                onSave: (updated) {
                                  setState(() => program.data = updated);
                                  showSnack(context, "Information updated successfully.",
                                      success: true);
                                  if (program.docId != null) {
                                    FirestoreService
                                        .updateProgram(program.docId!, updated)
                                        .catchError((e) {
                                      if (mounted) {
                                        showSnack(context, "Failed to sync update: $e",
                                            success: false);
                                      }
                                    });
                                  }
                                },
                              )
                          : null,
                      onDelete: widget.canDeletePrograms
                          ? () => _confirmDelete(
                                context,
                                title: "Delete Program",
                                message:
                                    "Are you sure you want to delete \"${program.data["Program Title"] ?? "this program"}\"? Its projects and activities will be deleted too. This cannot be undone.",
                                onConfirm: () {
                                  setState(
                                    () => RecordStorage.programs.remove(program),
                                  );
                                  if (program.docId != null) {
                                    FirestoreService
                                        .deleteProgram(program.docId!)
                                        .catchError((e) {
                                      if (mounted) {
                                        showSnack(context, "Failed to sync delete: $e",
                                            success: false);
                                      }
                                    });
                                  }
                                },
                              )
                          : null,
                      nested: _visibleProjects(program).map((project) {
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
                                  ...project.data.entries
                                      .where((e) => e.value.toString().trim().isNotEmpty)
                                      .map(
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
                                  actionButtonRow(
                                    onUpdate: widget.canUpdatePrograms
                                        ? () => showEditRecordSheet(
                                              context,
                                              title: "Update Project",
                                              fields: projectFields,
                                              data: project.data,
                                              onSave: (updated) {
                                                setState(() => project.data = updated);
                                                showSnack(
                                                    context,
                                                    "Information updated successfully.",
                                                    success: true);
                                                if (project.docId != null) {
                                                  FirestoreService
                                                      .updateProject(project.docId!, updated)
                                                      .catchError((e) {
                                                    if (mounted) {
                                                      showSnack(context,
                                                          "Failed to sync update: $e",
                                                          success: false);
                                                    }
                                                  });
                                                }
                                              },
                                            )
                                        : null,
                                    onDelete: widget.canDeletePrograms
                                        ? () => _confirmDelete(
                                              context,
                                              title: "Delete Project",
                                              message:
                                                  "Are you sure you want to delete \"${project.data["Project Title"] ?? "this project"}\"? Its activities will be deleted too. This cannot be undone.",
                                              onConfirm: () {
                                                setState(
                                                  () => program.projects.remove(project),
                                                );
                                                if (project.docId != null) {
                                                  FirestoreService
                                                      .deleteProject(project.docId!)
                                                      .catchError((e) {
                                                    if (mounted) {
                                                      showSnack(context,
                                                          "Failed to sync delete: $e",
                                                          success: false);
                                                    }
                                                  });
                                                }
                                              },
                                            )
                                        : null,
                                  ),
                                  ..._visibleActivities(project).map(
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
                                              ...activity.data.entries
                                                  .where((e) => e.value.toString().trim().isNotEmpty)
                                                  .map(
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
                                              actionButtonRow(
                                                onUpdate: widget.canUpdatePrograms
                                                    ? () => showEditRecordSheet(
                                                          context,
                                                          title: "Update Activity",
                                                          fields: activityFields,
                                                          data: activity.data,
                                                          onSave: (updated) {
                                                            setState(
                                                                () => activity.data = updated);
                                                            showSnack(
                                                                context,
                                                                "Information updated successfully.",
                                                                success: true);
                                                            if (activity.docId != null) {
                                                              FirestoreService
                                                                  .updateActivity(
                                                                      activity.docId!, updated)
                                                                  .catchError((e) {
                                                                if (mounted) {
                                                                  showSnack(context,
                                                                      "Failed to sync update: $e",
                                                                      success: false);
                                                                }
                                                              });
                                                            }
                                                          },
                                                        )
                                                    : null,
                                                onDelete: widget.canDeletePrograms
                                                    ? () => _confirmDelete(
                                                          context,
                                                          title: "Delete Activity",
                                                          message:
                                                              "Are you sure you want to delete \"${activity.data["Activity Title"] ?? "this activity"}\"? This cannot be undone.",
                                                          onConfirm: () {
                                                            setState(
                                                              () => project.activities
                                                                  .remove(activity),
                                                            );
                                                            if (activity.docId != null) {
                                                              FirestoreService
                                                                  .deleteActivity(
                                                                      activity.docId!)
                                                                  .catchError((e) {
                                                                if (mounted) {
                                                                  showSnack(
                                                                      context,
                                                                      "Failed to sync delete: $e",
                                                                      success: false);
                                                                }
                                                              });
                                                            }
                                                          },
                                                        )
                                                    : null,
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
                              RecordStorage.programs.removeWhere(
                                (p) => visiblePrograms.contains(p),
                              );
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