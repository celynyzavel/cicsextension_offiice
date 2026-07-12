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
                        width: 220,
                        height: 180,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => setState(() => _showForm = true),
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
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sync_alt_outlined,
                                    color: kGold,
                                    size: 40,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Add Technology Transfer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
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
    // Trigger field-level "Empty Fields" messages first.
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
          hintText: "Enter ${f.label}",
          hintStyle: const TextStyle(color: kTextSecondary),
          prefixIcon: Icon(f.icon, color: kPrimary),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: kBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: kCardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        );

    if (f.type == FieldType.dropdown) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kCardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          initialValue: _controllers[i].text.isEmpty ? null : _controllers[i].text,
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
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 35,
              backgroundColor: kPrimary,
              child: Icon(
                Icons.sync_alt_outlined,
                color: kWhite,
                size: 35,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Technology Transfer Information",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kGold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          for (var i = 0; i < technologyTransferFields.length; i++) _buildField(i),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('Save Record'),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: kWhite),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Form'),
              style: OutlinedButton.styleFrom(foregroundColor: kWhite, side: const BorderSide(color: kPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
