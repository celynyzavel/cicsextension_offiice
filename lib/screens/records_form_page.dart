import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/form_fields.dart';
import '../widgets/record_form.dart';

class RecordsFormPage extends StatefulWidget {
  const RecordsFormPage({super.key});
  @override
  State<RecordsFormPage> createState() => _RecordsFormPageState();
}

class _RecordsFormPageState extends State<RecordsFormPage> {
  RecordType? _type;

  Widget _selectionBox(String title, String subtitle, IconData icon, RecordType type) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _type = type),
      child: cardBox(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(radius: 26, backgroundColor: kBackground, child: Icon(icon, color: kGold, size: 26)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kWhite)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: kTextSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kPrimary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_type) {
      null => 'Extension Projects',
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
        leading: _type != null ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _type = null)) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _type == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('What would you like to add?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kWhite)),
                  const SizedBox(height: 16),
                  _selectionBox('Add Program', 'Register a new extension program', Icons.event_note_outlined, RecordType.program),
                  _selectionBox('Add Project', 'Record a new extension project activity', Icons.volunteer_activism_outlined, RecordType.project),
                  _selectionBox('Add Activity', 'Log a standalone activity or one under a project', Icons.bolt_outlined, RecordType.activity),
                ],
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
