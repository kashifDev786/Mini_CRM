import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc_files/dashboard_bloc/dashboard_bloc.dart';
import '../bloc_files/leads_bloc/leads_bloc.dart';
import '../models/lead.dart';
import '../utils/helper.dart';

class LeadDialog extends StatefulWidget {
  final Lead? lead;

  const LeadDialog({super.key, this.lead});

  @override
  State<LeadDialog> createState() => _LeadDialogState();
}

class _LeadDialogState extends State<LeadDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.lead?.name ?? '';
    emailController.text = widget.lead?.email ?? '';
    phoneController.text = widget.lead?.phone ?? '';
    currentStatus = widget.lead?.status ?? 'New';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lead != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Lead' : 'Add Lead'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Helper().buildTextField(nameController, 'Name'),
              const SizedBox(height: 12),
              Helper().buildEmailField(emailController),
              const SizedBox(height: 12),
              Helper().buildPhoneField(phoneController),
              const SizedBox(height: 12),
              _buildStatusDropdown(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }


  Widget _buildStatusDropdown() {
    final statuses = ['New', 'Contacted', 'Converted', 'Dropped'];
    return DropdownButtonFormField<String>(
      value: currentStatus,
      decoration: Helper().inputDecoration('Status'),
      isExpanded: true,
      onChanged: (val) => setState(() => currentStatus = val!),
      items: statuses
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }



  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.lead != null;
      final leadData = Lead(
        id: isEdit ? widget.lead!.id : const Uuid().v4(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        status: currentStatus,
      );

      if (isEdit) {
        final oldStatus = widget.lead!.status;

        widget.lead!
          ..name = leadData.name
          ..email = leadData.email
          ..phone = leadData.phone
          ..status = leadData.status;

        context.read<LeadsBloc>().add(UpdateLead(widget.lead!));
        context.read<LeadsBloc>().add(LoadLeads());
        await _logActivity(isEdit, oldStatus, leadData.status);
      } else {
        context.read<LeadsBloc>().add(AddLead(leadData));
        await Helper().logActivity("New Lead ${leadData.name} added");
      }
      context.read<LeadsBloc>().add(LoadLeads());
      context.read<DashboardBloc>().add(LoadDashboardData());

      Navigator.of(context).pop();
    }
  }

  Future<void> _logActivity(bool isEdit, String oldStatus, String newStatus) async {
    if (oldStatus != newStatus) {
      await Helper().logActivity(
          "Lead ${widget.lead!.name} status changed from $oldStatus to $newStatus");
    } else {
      await Helper().logActivity("Lead ${widget.lead!.name} updated");
    }
  }
}
