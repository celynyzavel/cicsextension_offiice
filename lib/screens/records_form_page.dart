import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/form_fields.dart';
import '../widgets/record_form.dart';
import '../widgets/common_widgets.dart';

class RecordsFormPage extends StatefulWidget {
  const RecordsFormPage({super.key});

  @override
  State<RecordsFormPage> createState() => _RecordsFormPageState();
}

class _RecordsFormPageState extends State<RecordsFormPage> {
  RecordType? _type;

  Widget _selectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required RecordType type,
  }) {
    return InkWell(
      onTap: () => setState(() => _type = type),
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
                    title,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextSecondary, fontSize: 12),
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

    final title = switch (_type) {
      null => 'Input Records',
      RecordType.program => 'Add Program',
      RecordType.project => 'Add Project',
      RecordType.activity => 'Add Activity',
    };

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: kSidebar,
        foregroundColor: kWhite,
        leading: _type != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _type = null),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _type == null
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    const Text(
                      'What would you like to add?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose a record type to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: kTextSecondary),
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width > 600 ? 480 : width),
                        child: Column(
                          children: [
                            _selectionCard(
                              context: context,
                              title: "Add Program",
                              subtitle: "A multi-year extension program",
                              icon: Icons.event_note_outlined,
                              color: kPrimary,
                              type: RecordType.program,
                            ),
                            const SizedBox(height: 14),
                            _selectionCard(
                              context: context,
                              title: "Add Project",
                              subtitle: "A project under a program",
                              icon: Icons.volunteer_activism_outlined,
                              color: kGold,
                              type: RecordType.project,
                            ),
                            const SizedBox(height: 14),
                            _selectionCard(
                              context: context,
                              title: "Add Activity",
                              subtitle: "A specific activity or session",
                              icon: Icons.bolt_outlined,
                              color: kSuccess,
                              type: RecordType.activity,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : RecordForm(
                key: ValueKey(_type),
                fields: switch (_type!) {
                  RecordType.program => programFields,
                  RecordType.project => projectFields,
                  RecordType.activity => activityFields,
                },
                recordLabel: switch (_type!) {
                  RecordType.program => 'Program',
                  RecordType.project => 'Project',
                  RecordType.activity => 'Activity',
                },
              ),
      ),
    );
  }
}