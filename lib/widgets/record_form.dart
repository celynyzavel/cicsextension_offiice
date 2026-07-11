import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/form_fields.dart';
import '../models/records.dart';
import 'common_widgets.dart';

// ============================================================
// RECORD FORM — a single generic form widget that renders
// whichever FieldSpec list it's given (program / project /
// activity), then saves the result into RecordStorage.
// ============================================================

class RecordForm extends StatefulWidget {
  final List<FieldSpec> fields;
  final String recordLabel;
  const RecordForm({super.key, required this.fields, required this.recordLabel});

  @override
  State<RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers = widget.fields
      .map((f) => TextEditingController(
          text: f.type == FieldType.dropdown && f.options.isNotEmpty ? f.options.first : ''))
      .toList();

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kPrimary,
            surface: kCard,
            onSurface: kWhite,
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
      _controllers[i].text = (f.type == FieldType.dropdown && f.options.isNotEmpty) ? f.options.first : '';
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
      String parentProgram =
          record["Parent Program (leave blank for standalone project)"] ?? "";

      bool found = false;

      for (var program in RecordStorage.programs) {
        if (program.data["Program Title"] == parentProgram) {
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
      String parentProject =
          record["Parent Project (leave blank for standalone activity)"] ?? "";

      bool found = false;

      for (var program in RecordStorage.programs) {
        for (var project in program.projects) {
          if (project.data["Project Title"] == parentProject) {
            project.activities.add(
              ActivityRecord(record),
            );

            found = true;
            break;
          }
        }
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
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
  children: [
    const Icon(
      Icons.check_circle,
      color: kPrimary,
    ),
    const SizedBox(width: 8),
    Text(
      "${widget.recordLabel} Saved",
      style: const TextStyle(
        color: kWhite,
      ),
    ),
  ],
),

content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < widget.fields.length; i++)
              if (_controllers[i].text.isNotEmpty)
                Text(
                  '${widget.fields[i].label}: ${_controllers[i].text}',
                  style: const TextStyle(color: kWhite),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clear();
            },
            child: const Text(
              "OK",
              style: TextStyle(color: kPrimary),
            ),
          ),
        ],
      ),
    );

    showSnack(context, "${widget.recordLabel} record submitted!");
  }

  Widget _buildField(int i) {
    final f = widget.fields[i];

    InputDecoration deco({Widget? suffixIcon}) => InputDecoration(
      hintText: "Enter ${f.label}",
      hintStyle: const TextStyle(
        color: kTextSecondary,
      ),

      prefixIcon: Icon(
        f.icon,
        color: kPrimary,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: kBackground,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: kCardBorder,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: kPrimary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );

    if (f.type == FieldType.dropdown) {
      return AnimatedContainer(
  duration: const Duration(milliseconds: 250),
  margin: const EdgeInsets.only(bottom: 18),
  decoration: BoxDecoration(
    color: kCard,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: kCardBorder,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.18),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
        child: DropdownButtonFormField<String>(
          value: _controllers[i].text.isEmpty ? null : _controllers[i].text,
          dropdownColor: kCard,
          style: const TextStyle(color: kWhite),
          icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
          decoration: deco(),
          items: f.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: kWhite))))
              .toList(),
          onChanged: (v) => setState(() => _controllers[i].text = v ?? ''),
          validator: (v) {
            if (f.optional) return null;
            return (v == null || v.isEmpty) ? '${f.label} must be selected' : null;
          },
        ),
      );
    }

    if (f.type == FieldType.date) {
      return cardBox(
        child: TextFormField(
          controller: _controllers[i],
          readOnly: true,
          style: const TextStyle(color: kWhite),
          onTap: () => _pickDate(i),
          decoration: deco(suffixIcon: const Icon(Icons.calendar_month_outlined, color: kMuted)),
          validator: (v) {
            if (f.optional) return null;
            return (v == null || v.trim().isEmpty) ? '${f.label} must not be empty' : null;
          },
        ),
      );
    }

    return cardBox(
      child: TextFormField(
        controller: _controllers[i],
        style: const TextStyle(color: kWhite),
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

  @override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 35,
            backgroundColor: kPrimary,
            child: Icon(
              widget.recordLabel == "Program"
                  ? Icons.event_note
                  : widget.recordLabel == "Project"
                      ? Icons.folder
                      : Icons.bolt,
              color: kWhite,
              size: 35,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "${widget.recordLabel} Information",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kGold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        for (var i = 0; i < widget.fields.length; i++)
          _buildField(i),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save),
            label: const Text("Save Record"),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: kWhite,
            ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.refresh),
            label: const Text("Clear Form"),
            style: OutlinedButton.styleFrom(
              foregroundColor: kWhite,
              side: const BorderSide(color: kPrimary),
            ),
          ),
        ),
      ],
    ),
  );
}
}
