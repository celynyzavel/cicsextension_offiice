import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/form_fields.dart';
import '../widgets/record_form.dart';

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
    required IconData icon,
    required Color color,
    required RecordType type,
  }) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kCardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: width < 600 ? 32 : 40,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: width < 600 ? 14 : 16,
                ),
              ),
            ],
          ),
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
                    const SizedBox(height: 20),

                    const Text(
                      'What would you like to add?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kWhite,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Center(
                      child: SizedBox(
                        width: width > 1000
                            ? 750
                            : width > 700
                                ? 650
                                : width,
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: width < 600 ? 1 : 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: width < 600 ? 3.8 : 1.35,
                          children: [
                            _selectionCard(
                              context: context,
                              title: "Add Program",
                              icon: Icons.event_note_outlined,
                              color: kPrimary,
                              type: RecordType.program,
                            ),
                            _selectionCard(
                              context: context,
                              title: "Add Project",
                              icon: Icons.volunteer_activism_outlined,
                              color: kGold,
                              type: RecordType.project,
                            ),
                            _selectionCard(
                              context: context,
                              title: "Add Activity",
                              icon: Icons.bolt_outlined,
                              color: Colors.green,
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
