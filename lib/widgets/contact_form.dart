import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/contacts_model.dart';

class ContactForm extends StatefulWidget {
  final Contact? contact;
  const ContactForm({super.key, this.contact});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _email, _phone;

  @override
  void initState() {
    super.initState();
    _name = widget.contact?.name ?? '';
    _email = widget.contact?.email ?? '';
    _phone = widget.contact?.phone ?? '';
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon,color: Colors.black,),
      filled: true,
      fillColor: Colors.deepPurple[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Contact" : "Add Contact",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (isEditing)
                      Hero(
                        tag: 'contact-${widget.contact!.name}',
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            widget.contact!.name.isNotEmpty ? widget.contact!.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _name,
                      decoration: _buildInputDecoration("Name", Icons.person),
                      onSaved: (val) => _name = val!.trim(),
                      style: TextStyle(color: Colors.black),
                      validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _email,
                      decoration: _buildInputDecoration("Email", Icons.email),
                      style: TextStyle(color: Colors.black),
                      onSaved: (val) => _email = val!.trim(),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _phone,
                      style: TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration("Phone", Icons.phone),
                      onSaved: (val) => _phone = val!.trim(),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.length < 8 ? 'Enter valid phone number' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final contact = Contact(
                              id: widget.contact?.id ?? const Uuid().v4(),
                              name: _name,
                              email: _email,
                              phone: _phone,
                            );
                            Navigator.pop(context, contact);
                          }
                        },
                        icon: Icon(isEditing ? Icons.update : Icons.save,color: Colors.black,),
                        label: Text(isEditing ? "Update Contact" : "Save Contact",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
