import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/form_fields.dart';
import '../models/records.dart';
import '../widgets/view_records.dart';

class TechnologyTransferPage extends StatefulWidget {
  const TechnologyTransferPage({super.key});

  @override
  State<TechnologyTransferPage> createState() => _TechnologyTransferPageState();
}

class _TechnologyTransferPageState extends State<TechnologyTransferPage> {
  bool _showForm = false;

  Widget _selectionBox(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _selectionBox(
                    'Add Technology Transfer',
                    'Record a new technology transfer entry',
                    Icons.sync_alt_outlined,
                    () => setState(() => _showForm = true),
                  ),
                ],
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
      _controllers[i].text = '';
    }
    _formKey.currentState?.reset();
  }

  void _showEmptyFieldsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: kOrange),
            SizedBox(width: 8),
            Text('Empty Fields', style: TextStyle(color: kWhite)),
          ],
        ),
        content: const Text(
          'Please fill in all fields before saving.',
          style: TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      _showEmptyFieldsDialog();
      return;
    }

    final record = <String, dynamic>{
      'type': 'Technology Transfer',
      'dateSaved': DateTime.now().toString(),
    };
    for (int i = 0; i < technologyTransferFields.length; i++) {
      record[technologyTransferFields[i].label] = _controllers[i].text.trim();
    }

    RecordStorage.techTransfers.add(TechTransferRecord(record));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: kPrimary),
            SizedBox(width: 8),
            Text('Technology Transfer Saved', style: TextStyle(color: kWhite)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < technologyTransferFields.length; i++)
              if (_controllers[i].text.isNotEmpty)
                Text(
                  '${technologyTransferFields[i].label}: ${_controllers[i].text}',
                  style: const TextStyle(color: kWhite),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ViewRecordsPage()),
              );
            },
            child: const Text('OK', style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );

    showSnack(context, 'Technology Transfer record submitted!');
  }

  Widget _buildField(int i) {
    final f = technologyTransferFields[i];

    InputDecoration deco({Widget? suffixIcon}) => InputDecoration(
          labelText: f.label,
          labelStyle: const TextStyle(color: kTextSecondary),
          prefixIcon: Icon(f.icon, color: kPrimary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          filled: true,
          fillColor: kCard,
        );

    if (f.type == FieldType.dropdown) {
      return cardBox(
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
          validator: (v) => (v == null || v.isEmpty) ? 'Empty Fields' : null,
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
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Empty Fields' : null,
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
          if (v == null || v.trim().isEmpty) return 'Empty Fields';
          if (f.type == FieldType.number && int.tryParse(v.trim()) == null) return 'Empty Fields';
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
        children: [
          for (var i = 0; i < technologyTransferFields.length; i++) _buildField(i),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: kWhite, padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.refresh, color: kWhite),
                  label: const Text('Clear', style: TextStyle(color: kWhite)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: kPrimary), padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
