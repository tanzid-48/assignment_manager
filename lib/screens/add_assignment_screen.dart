import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';

class AddAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  final bool fromNav;
  const AddAssignmentScreen({
    super.key,
    this.assignment,
    this.fromNav = false,
  });

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _subjectCtrl;
  late TextEditingController _descCtrl;
  String _priority = 'Medium';
  String _status = 'Pending';
  DateTime _deadline = DateTime.now();

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    final a = widget.assignment;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _subjectCtrl = TextEditingController(text: a?.subject ?? '');
    _descCtrl = TextEditingController(text: a?.description ?? '');
    if (a != null) {
      _priority = a.priority;
      _status = a.status;
      _deadline = a.deadline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<AssignmentProvider>();

    final assignment = Assignment(
      id: widget.assignment?.id ?? '',  
      title: _titleCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      deadline: _deadline,
      priority: _priority,
      status: _status,
      createdAt: widget.assignment?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await p.update(assignment);
    } else {
      await p.add(assignment);
    }

    if (mounted) {
      _titleCtrl.clear();
      _subjectCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _priority = 'Medium';
        _status = 'Pending';
        _deadline = DateTime.now();
      });
      if (widget.fromNav) {
        context.read<AssignmentProvider>().setCurrentTab(0);
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Assignment' : 'New Assignment'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.fromNav,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Assignment Details', [
              _field('Title *', _titleCtrl, 'e.g. Database ER Diagram',
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Title required' : null),
              const SizedBox(height: 14),
              _field('Subject *', _subjectCtrl, 'e.g. CSE 3102',
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Subject required' : null),
              const SizedBox(height: 14),
              _field('Description', _descCtrl, 'Optional notes...',
                  maxLines: 3),
            ]),
            const SizedBox(height: 12),
            _section('Settings', [
              _dropdown('Priority', _priority, ['High', 'Medium', 'Low'],
                  (v) => setState(() => _priority = v!)),
              const SizedBox(height: 14),
              _dropdown(
                  'Status',
                  _status,
                  ['Pending', 'In Progress', 'Completed'],
                  (v) => setState(() => _status = v!)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Deadline',
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withOpacity(0.6))),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(_deadline),
                          style: TextStyle(
                              fontSize: 13,
                              color: scheme.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isEditing ? 'Update Assignment' : 'Save Assignment',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.15)),
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.primary)),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }

  Widget _field(
      String label, TextEditingController ctrl, String hint,
      {String? Function(String?)? validator, int maxLines = 1}) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withOpacity(0.3)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: scheme.outline.withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: scheme.outline.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: scheme.primary)),
            ),
          ),
        ]);
  }

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: scheme.outline.withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: scheme.outline.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: scheme.primary)),
            ),
            items: items
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(fontSize: 14))))
                .toList(),
          ),
        ]);
  }
}