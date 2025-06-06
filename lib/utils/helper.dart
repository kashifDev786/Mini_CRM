import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mini_crm/models/contacts_model.dart';

import '../models/activity.dart';
import '../models/lead.dart';

class Helper {
  Future<void> clearAllCache(BuildContext context) async {
    // Safely clear the boxes without reopening
    if (Hive.isBoxOpen('leads')) {
      await Hive.box<Lead>('leads').clear();
    }

    if (Hive.isBoxOpen('contacts')) {
      await Hive.box<Contact>('contacts').clear();
    }

    if (Hive.isBoxOpen('activityBox')) {
      await Hive.box<Activity>('activityBox').clear();
    }

    if (Hive.isBoxOpen('sessionBox')) {
      await Hive.box('sessionBox').clear();
    }

    // Optionally, close them if you're done using them
    // await Hive.box('leadsBox').close();
    // await Hive.box('contactsBox').close();
    // await Hive.box('activityBox').close();
    // await Hive.box('sessionBox').close();

    // Navigate to login screen and remove all routes
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
    // Add any other boxes you're using

  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }


  Future<void> saveSession(String email) async {
    var box = await Hive.openBox('sessionBox');
    await box.put('userEmail', email);
  }

  Future<String?> getSession() async {
    var box = await Hive.openBox('sessionBox');
    return box.get('userEmail');
  }

  Future<void> clearSession() async {
    var box = await Hive.openBox('sessionBox');
    await box.clear();
  }

  Future<void> logActivity(String message) async {
    final box = await Hive.openBox<Activity>('activityBox');
    final activity = Activity(message: message, timestamp: DateTime.now());
    await box.add(activity);
  }

  Widget buildEmailField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: inputDecoration('Email'),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Email required';
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        return emailRegex.hasMatch(val) ? null : 'Enter valid email';
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: inputDecoration(label),
      validator: (val) => val == null || val.isEmpty ? '$label required' : null,
    );
  }

  Widget buildPhoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: inputDecoration('Phone'),
      validator: (val) =>
      val == null || val.length < 8 ? 'Valid phone required' : null,
    );
  }



  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.deepPurple[60],
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
