import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../models/form_fields.dart';
import '../models/records.dart';
import '../services/firestore_services.dart';
import '../services/session.dart';
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
      if (f.label == "Parent Program" || f.label == "Parent Project") {
        // Populated in initState() from the current user's own records.
        return TextEditingController();
      } else {
        return TextEditingController(text: f.options.isNotEmpty ? f.options.first : '');
      }
    }
    return TextEditingController();
  }).toList();

  final Map<int, List<Map<String, String>>> _facultyRows = {};
  int _facultyIdCounter = 0;

  // Tracks the selected record ID (not title) for the "Parent Program" /
  // "Parent Project" dropdowns, since titles can collide but IDs cannot.
  final Map<int, String?> _dropdownSelectedId = {};

  bool _submitAttempted = false;
  bool _isSaving = false;

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

    for (int i = 0; i < widget.fields.length; i++) {
      final f = widget.fields[i];
      if (f.type == FieldType.dropdown) {
        if (f.label == "Parent Program") {
          final options = _getProgramOptions();
          final id = options.isNotEmpty ? options.first.key : null;
          _dropdownSelectedId[i] = id;
          _controllers[i].text = options.isNotEmpty ? options.first.value : '';
          _syncIdField("Parent Program ID", id);
        } else if (f.label == "Parent Project") {
          final options = _getProjectOptions();
          final id = options.isNotEmpty ? options.first.key : null;
          _dropdownSelectedId[i] = id;
          _controllers[i].text = options.isNotEmpty ? options.first.value : '';
          _syncIdField("Parent Project ID", id);
        }
      }
    }
  }


  // ID-based option lists for dropdowns. Titles aren't guaranteed unique
  // (two projects can share the same title), but IDs always are, so these
  // must be used as the DropdownMenuItem `value` to avoid Flutter's
  // "exactly one item with this value" assertion.
  //
  // These are also scoped to records created by the currently logged-in
  // user, so a faculty member can only attach a new Project/Activity under
  // a Program/Project they themselves created.
  List<MapEntry<String, String>> _getProgramOptions() {
    final userId = Session.currentUserId;
    return RecordStorage.programs
        .where((p) => userId == null || (p.data["User ID"] ?? '') == userId)
        .map((p) => MapEntry(p.id, (p.data["Program Title"] as String?) ?? p.id))
        .toList();
  }

  List<MapEntry<String, String>> _getProjectOptions() {
    final userId = Session.currentUserId;
    final list = <MapEntry<String, String>>[];
    for (final program in RecordStorage.programs) {
      for (final project in program.projects) {
        if (userId != null && (project.data["User ID"] ?? '') != userId) continue;
        list.add(MapEntry(project.id, (project.data["Project Title"] as String?) ?? project.id));
      }
    }
    return list;
  }


  void _syncIdField(String idLabel, String? value) {
    final idx = widget.fields.indexWhere((f) => f.label == idLabel);
    if (idx != -1) {
      _controllers[idx].text = value ?? '';
    }
  }

  int _indexOfLabel(String label) => widget.fields.indexWhere((f) => f.label == label);

  bool _endDateVisible(int statusIdx) {
    if (statusIdx == -1) return true;
    return _controllers[statusIdx].text.trim() == 'Completed';
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
          final options = _getProgramOptions();
          final id = options.isNotEmpty ? options.first.key : null;
          _dropdownSelectedId[i] = id;
          _controllers[i].text = id != null ? options.first.value : "";
          _syncIdField("Parent Program ID", id);
        } else if (f.label == "Parent Project") {
          final options = _getProjectOptions();
          final id = options.isNotEmpty ? options.first.key : null;
          _dropdownSelectedId[i] = id;
          _controllers[i].text = id != null ? options.first.value : "";
          _syncIdField("Parent Project ID", id);
        } else {
          _controllers[i].text = f.options.isNotEmpty ? f.options.first : "";
        }
      } else {
        _controllers[i].clear();
      }
    }
    _formKey.currentState?.reset();
    setState(() => _submitAttempted = false);
  }

  bool _facultyMissing(int i) {
    final f = widget.fields[i];
    if (f.type != FieldType.facultyList || f.optional) return false;
    return _controllers[i].text.trim().isEmpty;
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    final facultyValid =
        !List.generate(widget.fields.length, (i) => i).any(_facultyMissing);

    if (!formValid || !facultyValid) {
      setState(() => _submitAttempted = true);
      return;
    }

    // Save the record
    Map<String, dynamic> record = {
      "type": widget.recordLabel,
      "dateSaved": DateTime.now().toString(),
      "createdAt": FieldValue.serverTimestamp(),
      "Created By": Session.currentUserEmail ?? '',
      "User ID": Session.currentUserId ?? '',
    };

    final statusIdx = _indexOfLabel('Status');
    for (int i = 0; i < widget.fields.length; i++) {
      final f = widget.fields[i];
      if (f.label == 'End Date' && !_endDateVisible(statusIdx)) {
        record[f.label] = '';
        continue;
      }
      record[f.label] = _controllers[i].text;
    }

    late final String generatedId;
    switch (widget.recordLabel) {
      case "Program":
        generatedId = RecordStorage.nextProgramId();
        record['Program ID'] = generatedId;
        break;
      case "Project":
        generatedId = RecordStorage.nextProjectId();
        record['Project ID'] = generatedId;
        break;
      case "Activity":
        generatedId = RecordStorage.nextActivityId();
        record['Activity ID'] = generatedId;
        break;
      default:
        generatedId = '';
    }

    setState(() => _isSaving = true);

    String? docId;
    try {
      switch (widget.recordLabel) {
        case "Program":
          final ref = await FirestoreService.addProgram(record);
          docId = ref.id;
          break;
        case "Project":
          final ref = await FirestoreService.addProject(record);
          docId = ref.id;
          break;
        case "Activity":
          final ref = await FirestoreService.addActivity(record);
          docId = ref.id;
          break;
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      showSnack(context, "Failed to save ${widget.recordLabel}: $e", success: false);
      return;
    }

    setState(() => _isSaving = false);
    if (!mounted) return;

    if (widget.recordLabel == "Program") {
      RecordStorage.programs.add(
        ProgramRecord(record, id: generatedId, docId: docId),
      );
    }

    else if (widget.recordLabel == "Project") {
      String parentProgramId = record["Parent Program ID"] ?? "";

      bool found = false;

      for (var program in RecordStorage.programs) {
        if (program.id == parentProgramId) {
          program.projects.add(
            ProjectRecord(record, id: generatedId, docId: docId),
          );

          found = true;
          break;
        }
      }

      if (!found) {
        ProgramRecord standalone = ProgramRecord({
          "Program Title": "Standalone Projects",
          "type": "Program",
        });

        standalone.projects.add(
          ProjectRecord(record, id: generatedId, docId: docId),
        );

        RecordStorage.programs.add(standalone);
      }
    }


    else if (widget.recordLabel == "Activity") {
      String parentProjectId = record["Parent Project ID"] ?? "";

      bool found = false;

      for (var program in RecordStorage.programs) {
        for (var project in program.projects) {
          if (project.id == parentProjectId) {
            project.activities.add(
              ActivityRecord(record, id: generatedId, docId: docId),
            );

            found = true;
            break;
          }
        }
        if (found) break;
      }


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
          ActivityRecord(record, id: generatedId, docId: docId),
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
    final statusIdx = _indexOfLabel('Status');

    if (f.label == 'End Date' && !_endDateVisible(statusIdx)) {
      return const SizedBox.shrink();
    }

    bool requiredNow = !f.optional;
    if (f.label == 'End Date') {
      requiredNow = _endDateVisible(statusIdx);
    }

    InputDecoration deco({Widget? suffixIcon}) => InputDecoration(
      hintText: "Enter ${f.label}",
      labelText: requiredNow ? f.label : '${f.label} (optional)',
      prefixIcon: Icon(f.icon, color: kPrimary),
      suffixIcon: suffixIcon,
    );

    if (f.type == FieldType.facultyList) {
      return _buildFacultyField(i);
    }

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

      if (isParentProgram || isParentProject) {
        final idOptions = isParentProgram ? _getProgramOptions() : _getProjectOptions();
        final hasNoParents = idOptions.isEmpty;

        // Only pass a value if it still exists among the current options,
        // otherwise Flutter's dropdown assertion fails (e.g. after a
        // refresh removed/renamed the previously selected record).
        final currentId = _dropdownSelectedId[i];
        final validCurrentId =
            idOptions.any((e) => e.key == currentId) ? currentId : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            initialValue: validCurrentId,
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
            items: idOptions
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      e.value,
                      style: const TextStyle(color: kTextPrimary),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() {
              _dropdownSelectedId[i] = v;
              final title = idOptions
                  .firstWhere((e) => e.key == v, orElse: () => const MapEntry('', ''))
                  .value;
              _controllers[i].text = title;
              if (isParentProgram) {
                _syncIdField("Parent Program ID", v);
              } else {
                _syncIdField("Parent Project ID", v);
              }
            }),
            validator: (v) {
              if (!requiredNow) return null;
              return (v == null || v.isEmpty) ? '${f.label} must be selected' : null;
            },
          ),
        );
      }

      final options = f.options;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          initialValue: _controllers[i].text.isEmpty ? null : _controllers[i].text,
          dropdownColor: kCard,
          style: const TextStyle(color: kTextPrimary),
          icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
          decoration: deco(),
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
            if (f.label == "Status" && v != 'Completed') {
              final endIdx = _indexOfLabel('End Date');
              if (endIdx != -1) _controllers[endIdx].clear();
            }
          }),
          validator: (v) {
            if (!requiredNow) return null;
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
            if (!requiredNow) return null;
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
        keyboardType: f.type == FieldType.number
            ? TextInputType.numberWithOptions(decimal: f.allowDecimal)
            : TextInputType.text,
        decoration: deco(),
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return requiredNow ? '${f.label} must not be empty' : null;
          }
          if (f.type == FieldType.number) {
            final trimmed = v.trim();
            final numVal = f.allowDecimal ? double.tryParse(trimmed) : int.tryParse(trimmed);
            if (numVal == null) return 'Enter a valid number';
            if (f.min != null && numVal < f.min!) return '${f.label} must be at least ${f.min}';
            if (f.max != null && numVal > f.max!) return '${f.label} must be at most ${f.max}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFacultyField(int i) {
    final f = widget.fields[i];
    final rows = _facultyRows[i]!;
    final showError = _submitAttempted && !f.optional && _controllers[i].text.trim().isEmpty;

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
                      onChanged: (v) => setState(() {
                        row['name'] = v;
                        syncController();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: row['role'],
                      style: const TextStyle(color: kTextPrimary),
                      decoration: const InputDecoration(labelText: 'Role', isDense: true),
                      onChanged: (v) => setState(() {
                        row['role'] = v;
                        syncController();
                      }),
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
          if (showError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                '${f.label}: add at least one faculty member',
                style: const TextStyle(color: kDanger, fontSize: 12.5),
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

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              initialValue: Session.currentUserId ?? 'Unknown',
              enabled: false,
              style: const TextStyle(color: kTextSecondary, fontStyle: FontStyle.italic),
              decoration: InputDecoration(
                labelText: "User ID",
                hintText: "Logged-in user's ID",
                prefixIcon: const Icon(Icons.badge_outlined, color: kMuted),
                filled: true,
                fillColor: kCard,
              ),
            ),
          ),

          for (var i = 0; i < widget.fields.length; i++)
            _buildField(i),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: kWhite),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? "Saving..." : "Save Record"),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _clear,
              icon: const Icon(Icons.refresh),
              label: const Text("Clear Form"),
            ),
          ),
        ],
      ),
    );
  }
}
