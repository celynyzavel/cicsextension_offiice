import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/form_fields.dart';
import '../models/records.dart';
import '../widgets/view_records.dart';
import '../services/firestore_services.dart';

class TechnologyTransferPage extends StatefulWidget {
  const TechnologyTransferPage({super.key});

  @override
  State<TechnologyTransferPage> createState() => _TechnologyTransferPageState();
}

class _TechnologyTransferPageState extends State<TechnologyTransferPage> {
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(_showForm ? 'Add Technology Transfer' : 'Technology Transfer'),
        centerTitle: true,
        backgroundColor: kSidebar,
        foregroundColor: kWhite,
        leading: _showForm ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showForm = false)) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _showForm
            ? const TechnologyTransferForm()
            : SingleChildScrollView(
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
                      'Record a new system, tool, or innovation transfer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: kTextSecondary),
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _showForm = true),
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
                                const IconBadge(icon: Icons.sync_alt_outlined, color: kGold, size: 46),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Add Technology Transfer',
                                        style: TextStyle(
                                          color: kTextPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Log usage status and trained users',
                                        style: TextStyle(color: kTextSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: kMuted),
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
  }
}
class TechnologyTransferForm extends StatefulWidget {
  const TechnologyTransferForm({super.key});

  @override
  State<TechnologyTransferForm> createState() => _TechnologyTransferFormState();
}


class _TechnologyTransferFormState extends State<TechnologyTransferForm> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers =
      technologyTransferFields.map((f) => TextEditingController(text: '')).toList();
  bool _isSaving = false;

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
      _controllers[i].text = '';
    }
    _formKey.currentState?.reset();
  }

  void _showEmptyFieldsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: kDanger, size: 30),
        title: const Text('Empty Fields'),
        content: const Text('Please fill in all fields before saving.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    // Trigger field-level "Empty Fields" messages first.
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      _showEmptyFieldsDialog();
      return;
    }

    final record = <String, dynamic>{
      'type': 'Technology Transfer',
      'dateSaved': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    for (int i = 0; i < technologyTransferFields.length; i++) {
      record[technologyTransferFields[i].label] = _controllers[i].text.trim();
    }

    setState(() => _isSaving = true);

    try {
      await FirestoreService.addTechnologyTransfer(record);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      showSnack(context, 'Failed to save: $e', success: false);
      return;
    }

    setState(() => _isSaving = false);
    if (!mounted) return;

    // Keep a local copy too, so the UI still works even without a live
    // Firestore stream wired up on View Records yet.
    RecordStorage.techTransfers.add(TechTransferRecord(record));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: kSuccess, size: 32),
        title: const Text('Technology Transfer Saved'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < technologyTransferFields.length; i++)
                if (_controllers[i].text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: kTextSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: '${technologyTransferFields[i].label}: ',
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
              Navigator.pop(context); // close dialog
              _clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ViewRecordsPage(
                    scope: ViewRecordsScope.all,
                    canDeletePrograms: false,
                    canDeleteTechTransfers: true,
                  ),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    showSnack(context, 'Technology Transfer record submitted!', success: true);
  }

  Widget _buildField(int i) {
    final f = technologyTransferFields[i];

    InputDecoration deco({Widget? suffixIcon}) => InputDecoration(
          hintText: "Enter ${f.label}",
          labelText: f.label,
          prefixIcon: Icon(f.icon, color: kPrimary),
          suffixIcon: suffixIcon,
        );

    if (f.type == FieldType.dropdown) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          initialValue: _controllers[i].text.isEmpty ? null : _controllers[i].text,
          dropdownColor: kCard,
          style: const TextStyle(color: kTextPrimary),
          icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
          decoration: deco(),
          items: f.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: kTextPrimary))))
              .toList(),
          onChanged: (v) => setState(() => _controllers[i].text = v ?? ''),
          validator: (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
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
          validator: (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null,
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
          if (v == null || v.trim().isEmpty) return 'This field is required';
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
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                gradient: kBrandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sync_alt_outlined,
                color: kWhite,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Technology Transfer Information",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "All fields are required before saving.",
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSecondary, fontSize: 12.5),
          ),

          const SizedBox(height: 24),

          for (var i = 0; i < technologyTransferFields.length; i++) _buildField(i),

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
    label: Text(_isSaving ? 'Saving...' : 'Save Record'),
  ),
),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Form'),
            ),
          ),
        ],
      ),
    );
  }
}