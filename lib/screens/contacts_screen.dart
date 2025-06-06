import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_crm/utils/helper.dart';

import '../bloc_files/dashboard_bloc/dashboard_bloc.dart';
import '../bloc_files/contacts_bloc/contact_bloc.dart';
import '../bloc_files/contacts_bloc/contacts_event.dart';
import '../bloc_files/contacts_bloc/contacts_state.dart';
import '../widgets/contact_form.dart';
import '../utils/logactivity.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Contacts",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          if (state is ContactsLoaded) {
            if (state.contacts.isEmpty) {
              return const Center(child: Text("No contacts available."));
            }
            return Column(
              children: [
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => context.read<ContactsBloc>().add(SearchContacts(value)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.contacts.length,
                    itemBuilder: (context, index) {
                      final contact = state.contacts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Dismissible(
                          key: Key(contact.key.toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (_) {
                            context.read<ContactsBloc>().add(DeleteContact(contact));
                            context.read<DashboardBloc>().add(LoadDashboardData());
                          },
                          child: ListTile(
                            leading: Hero(
                              tag: 'contact-${contact.name}', // Unique tag using contact ID
                              child: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(contact.phone),
                            trailing: const Icon(Icons.edit, color: Colors.deepPurple),
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContactForm(contact: contact),
                                ),
                              );
                              if (updated != null) {
                                context.read<ContactsBloc>().add(UpdateContact(updated));
                                await Helper().logActivity("Contact ${updated.name} Updated");
                                context.read<DashboardBloc>().add(LoadDashboardData());
                              }
                            },
                          ),

                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newContact = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactForm()),
          );
          if (newContact != null) {
            context.read<ContactsBloc>().add(AddContact(newContact));
            await Helper().logActivity("New Contact ${newContact.name} Added");
            context.read<DashboardBloc>().add(LoadDashboardData());

          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
