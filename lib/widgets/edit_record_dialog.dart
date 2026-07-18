import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/form_fields.dart';

class EditRecordDialog extends StatefulWidget {
  final String title;
  final List<FieldSpec> fields;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> updated) onSave;

  const EditRecordDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.data,
    required this.onSave,
  });

  @override
  State<EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<EditRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields
        .map((f) => TextEditingController(text: (widget.data[f.label] ?? '').toString()))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
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

  Widget _buildField(int i) {
    final f = widget.fields[i];
    final statusIdx = _indexOfLabel('Status');

    // Hide End Date entirely unless the record's Status is "Completed".
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

    if (f.type == FieldType.dropdown) {
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
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o, style: const TextStyle(color: kTextPrimary)),
                  ))
              .toList(),
          onChanged: (v) => setState(() {
            _controllers[i].text = v ?? '';
       
            if (f.label == 'Status' && v != 'Completed') {
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final statusIdx = _indexOfLabel('Status');
    final updated = Map<String, dynamic>.from(widget.data);

    for (int i = 0; i < widget.fields.length; i++) {
      final f = widget.fields[i];
      if (f.label == 'End Date' && !_endDateVisible(statusIdx)) {
        updated[f.label] = '';
        continue;
      }
      updated[f.label] = _controllers[i].text;
    }

    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: kMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Update the information below and save your changes.",
                style: TextStyle(color: kTextSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < widget.fields.length; i++) _buildField(i),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<void> showEditRecordSheet(
  BuildContext context, {
  required String title,
  required List<FieldSpec> fields,
  required Map<String, dynamic> data,
  required void Function(Map<String, dynamic> updated) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => EditRecordDialog(
      title: title,
      fields: fields,
      data: data,
      onSave: onSave,
    ),
  );
}
