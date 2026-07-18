import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/form_fields.dart';
import '../models/records.dart';
import 'common_widgets.dart';

class RecordForm extends StatefulWidget {
  final List<FieldSpec> fields;
  final String recordLabel;
  const RecordForm({super.key, required this.fields, required this.recordLabel});

  @override
  State<RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  final _formKey = GlobalKey<FormState>();

  late final List<TextEditingController> _controllers = widget.fields.map((f) {
    if (f.type == FieldType.dropdown) {
      if (f.label == "Parent Program") {
        final titles = _getProgramTitles();
        return TextEditingController(text: titles.isNotEmpty ? titles.first : '');
      } else if (f.label == "Parent Project") {
        final titles = _getProjectTitles();
        return TextEditingController(text: titles.isNotEmpty ? titles.first : '');
      } else {
        return TextEditingController(text: f.options.isNotEmpty ? f.options.first : '');
      }
    }
    return TextEditingController();
  }).toList();

  // Rows for any facultyList fields: index -> list of {id, name, role}
  final Map<int, List<Map<String, String>>> _facultyRows = {};
  int _facultyIdCounter = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.fields.length; i++) {
      if (widget.fields[i].type == FieldType.facultyList) {
        _facultyRows[i] = [
          {'id': (_facultyIdCounter++).toString(), 'name': '', 'role': ''}
        ];
      }
    }

    // Now that every controller exists, populate the read-only ID
    // fields based on whatever the parent dropdowns start out as.
    for (int i = 0; i < widget.fields.length; i++) {
      final f = widget.fields[i];
      if (f.type == FieldType.dropdown) {
        if (f.label == "Parent Program") {
          _syncIdField("Parent Program ID", _idForProgramTitle(_controllers[i].text));
        } else if (f.label == "Parent Project") {
          _syncIdField("Parent Project ID", _idForProjectTitle(_controllers[i].text));
        }
      }
    }
  }

  // ---- Name lists for the parent dropdowns (what the user sees/picks) ----

  List<String> _getProgramTitles() {
    return RecordStorage.programs
        .map((p) => p.data["Program Title"] as String)
        .toList();
  }

  List<String> _getProjectTitles() {
    List<String> projects = [];
    for (final program in RecordStorage.programs) {
      for (final project in program.projects) {
        projects.add(project.data["Project Title"] as String);
      }
    }
    return projects;
  }

  // ---- Name -> auto-generated ID lookups, used to populate the
  // read-only "Parent Program ID" / "Parent Project ID" fields ----

  String? _idForProgramTitle(String title) {
    for (final p in RecordStorage.programs) {
      if (p.data["Program Title"] == title) return p.id;
    }
    return null;
  }

  String? _idForProjectTitle(String title) {
    for (final program in RecordStorage.programs) {
      for (final project in program.projects) {
        if (project.data["Project Title"] == title) return project.id;
      }
    }
    return null;
  }

  /// Writes [value] into the controller for the field labeled [idLabel]
  /// (e.g. "Parent Program ID"), if that field exists in this form.
  void _syncIdField(String idLabel, String? value) {
    final idx = widget.fields.indexWhere((f) => f.label == idLabel);
    if (idx != -1) {
      _controllers[idx].text = value ?? '';
    }
  }

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimary,
            surface: kCard,
            onSurface: kTextPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _controllers[index].text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _clear() {
    for (var i = 0; i < _controllers.length; i++) {
      final f = widget.fields[i];

      // Read-only ID fields are derived from their dropdown — they get
      // set below when we process that dropdown, so skip them here.
      if (f.type == FieldType.readonly) continue;

      if (f.type == FieldType.facultyList) {
        setState(() {
          _facultyRows[i] = [
            {'id': (_facultyIdCounter++).toString(), 'name': '', 'role': ''}
          ];
        });
        _controllers[i].clear();
        continue;
      }
      if (f.type == FieldType.dropdown) {
        if (f.label == "Parent Program") {
          final titles = _getProgramTitles();
          _controllers[i].text = titles.isNotEmpty ? titles.first : "";
          _syncIdField("Parent Program ID", _idForProgramTitle(_controllers[i].text));
        } else if (f.label == "Parent Project") {
          final titles = _getProjectTitles();
          _controllers[i].text = titles.isNotEmpty ? titles.first : "";
          _syncIdField("Parent Project ID", _idForProjectTitle(_controllers[i].text));
        } else {
          _controllers[i].text = f.options.isNotEmpty ? f.options.first : "";
        }
      } else {
        _controllers[i].clear();
      }
    }
    _formKey.currentState?.reset();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Save the record
    Map<String, dynamic> record = {
      "type": widget.recordLabel,
      "dateSaved": DateTime.now().toString(),
    };

    for (int i = 0; i < widget.fields.length; i++) {
      record[widget.fields[i].label] = _controllers[i].text;
    }

    //============================
    // SAVE PROGRAM
    //============================
    if (widget.recordLabel == "Program") {
      RecordStorage.programs.add(
        ProgramRecord(record),
      );
    }

    //============================
    // SAVE PROJECT
    //============================
    else if (widget.recordLabel == "Project") {
      // The FK is the auto-filled "Parent Program ID" field, NOT the
      // "Parent Program" name field — names can repeat or be renamed,
      // IDs can't.
      String parentProgramId = record["Parent Program ID"] ?? "";

      bool found = false;

      for (var program in RecordStorage.programs) {
        if (program.id == parentProgramId) {
          program.projects.add(
            ProjectRecord(record),
          );

          found = true;
          break;
        }
      }

      // Standalone project
      if (!found) {
        ProgramRecord standalone = ProgramRecord({
          "Program Title": "Standalone Projects",
          "type": "Program",
        });

        standalone.projects.add(
          ProjectRecord(record),
        );

        RecordStorage.programs.add(standalone);
      }
    }

    //============================
    // SAVE ACTIVITY
    //============================
    else if (widget.recordLabel == "Activity") {
      // Same idea: match on the auto-filled "Parent Project ID".
      String parentProjectId = record["Parent Project ID"] ?? "";

      bool found = false;

      for (var program in RecordStorage.programs) {
        for (var project in program.projects) {
          if (project.id == parentProjectId) {
            project.activities.add(
              ActivityRecord(record),
            );

            found = true;
            break;
          }
        }
        if (found) break;
      }

      // Standalone activity
      if (!found) {
        ProgramRecord standaloneProgram = ProgramRecord({
          "Program Title": "Standalone Activities",
          "type": "Program",
        });

        ProjectRecord standaloneProject = ProjectRecord({
          "Project Title": "General Activities",
          "type": "Project",
        });

        standaloneProject.activities.add(
          ActivityRecord(record),
        );

        standaloneProgram.projects.add(
          standaloneProject,
        );

        RecordStorage.programs.add(
          standaloneProgram,
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: kSuccess, size: 32),
        title: Text("${widget.recordLabel} Saved"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.fields.length; i++)
                if (_controllers[i].text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: kTextSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: '${widget.fields[i].label}: ',
                            style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: _controllers[i].text),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clear();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    showSnack(context, "${widget.recordLabel} record submitted!", success: true);
  }

  Widget _buildField(int i) {
    final f = widget.fields[i];

    InputDecoration deco({Widget? suffixIcon}) => InputDecoration(
      hintText: "Enter ${f.label}",
      labelText: f.label,
      prefixIcon: Icon(f.icon, color: kPrimary),
      suffixIcon: suffixIcon,
    );

    if (f.type == FieldType.facultyList) {
      return _buildFacultyField(i);
    }

    // Read-only, auto-filled ID fields (Parent Program ID / Parent Project ID)
    if (f.type == FieldType.readonly) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: _controllers[i],
          enabled: false,
          style: const TextStyle(color: kTextSecondary, fontStyle: FontStyle.italic),
          decoration: InputDecoration(
            labelText: f.label,
            hintText: "Auto-filled from selection above",
            prefixIcon: Icon(f.icon, color: kMuted),
            filled: true,
            fillColor: kCard,
          ),
        ),
      );
    }

    if (f.type == FieldType.dropdown) {
      final isParentProgram = f.label == "Parent Program";
      final isParentProject = f.label == "Parent Project";

      final options = isParentProgram
          ? _getProgramTitles()
          : isParentProject
              ? _getProjectTitles()
              : f.options;

      final hasNoParents = (isParentProgram || isParentProject) && options.isEmpty;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          initialValue: _controllers[i].text.isEmpty ? null : _controllers[i].text,
          dropdownColor: kCard,
          style: const TextStyle(color: kTextPrimary),
          icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
          decoration: deco(
            suffixIcon: hasNoParents
                ? Tooltip(
                    message: isParentProgram
                        ? "No programs yet — this will be saved as a standalone project"
                        : "No projects yet — this will be saved as a standalone activity",
                    child: const Icon(Icons.info_outline, color: kMuted),
                  )
                : null,
          ),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(
                    o,
                    style: const TextStyle(color: kTextPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _controllers[i].text = v ?? '';
            if (isParentProgram) {
              _syncIdField("Parent Program ID", _idForProgramTitle(v ?? ''));
            } else if (isParentProject) {
              _syncIdField("Parent Project ID", _idForProjectTitle(v ?? ''));
            }
          }),
          validator: (v) {
            if (f.optional) return null;
            return (v == null || v.isEmpty) ? '${f.label} must be selected' : null;
          },
        ),
      );
    }

    if (f.type == FieldType.date) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: _controllers[i],
          readOnly: true,
          style: const TextStyle(color: kTextPrimary),
          onTap: () => _pickDate(i),
          decoration: deco(suffixIcon: const Icon(Icons.calendar_month_outlined, color: kMuted)),
          validator: (v) {
            if (f.optional) return null;
            return (v == null || v.trim().isEmpty) ? '${f.label} must not be empty' : null;
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[i],
        style: const TextStyle(color: kTextPrimary),
        maxLines: f.type == FieldType.multiline ? f.maxLines : 1,
        keyboardType: f.type == FieldType.number ? TextInputType.number : TextInputType.text,
        decoration: deco(),
        validator: (v) {
          if (f.optional) return null;
          if (v == null || v.trim().isEmpty) return '${f.label} must not be empty';
          if (f.type == FieldType.number && int.tryParse(v.trim()) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildFacultyField(int i) {
    final f = widget.fields[i];
    final rows = _facultyRows[i]!;

    void syncController() {
      _controllers[i].text = rows
          .where((r) => r['name']!.trim().isNotEmpty)
          .map((r) => r['role']!.trim().isEmpty
              ? r['name']!.trim()
              : '${r['name']!.trim()} (${r['role']!.trim()})')
          .join('; ');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(f.icon, color: kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(f.label,
                  style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          for (final row in List<Map<String, String>>.from(rows))
            Padding(
              key: ValueKey(row['id']),
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: row['name'],
                      style: const TextStyle(color: kTextPrimary),
                      decoration: const InputDecoration(labelText: 'Faculty Name', isDense: true),
                      onChanged: (v) {
                        row['name'] = v;
                        syncController();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: row['role'],
                      style: const TextStyle(color: kTextPrimary),
                      decoration: const InputDecoration(labelText: 'Role', isDense: true),
                      onChanged: (v) {
                        row['role'] = v;
                        syncController();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: kMuted),
                    onPressed: rows.length == 1
                        ? null
                        : () => setState(() {
                              rows.remove(row);
                              syncController();
                            }),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                rows.add({'id': (_facultyIdCounter++).toString(), 'name': '', 'role': ''});
              }),
              icon: const Icon(Icons.add, color: kPrimary),
              label: const Text('Add Faculty'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                gradient: kBrandGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.recordLabel == "Program"
                    ? Icons.event_note
                    : widget.recordLabel == "Project"
                        ? Icons.folder
                        : Icons.bolt,
                color: kWhite,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "${widget.recordLabel} Information",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Fields marked required must be completed before saving.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextSecondary, fontSize: 12.5),
          ),

          const SizedBox(height: 24),

          for (var i = 0; i < widget.fields.length; i++)
            _buildField(i),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: const Text("Save Record"),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text("Clear Form"),
            ),
          ),
        ],
      ),
    );
  }
}
