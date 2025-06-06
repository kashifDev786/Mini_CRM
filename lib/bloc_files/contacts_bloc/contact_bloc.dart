import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../models/contacts_model.dart';
import 'contacts_event.dart';
import 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final Box<Contact> contactBox;
  String _searchQuery = '';

  ContactsBloc(this.contactBox) : super(ContactsInitial()) {
    on<LoadContacts>((event, emit) {
      final contacts = contactBox.values.toList();
      emit(ContactsLoaded(contacts));
    });

    on<AddContact>((event, emit) async {
      await contactBox.put(event.contact.id, event.contact);
      add(LoadContacts());
    });

    on<UpdateContact>((event, emit) async {
      await contactBox.put(event.contact.key.toString(), event.contact);
      add(LoadContacts());
    });

    on<SearchContacts>((event, emit) {
      _searchQuery = event.query;
      final allcontacts = contactBox.values.toList();
      final filtered = allcontacts.where((c) {
        final matchesQuery = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery);
        return matchesQuery;
      }).toList();
      emit(ContactsLoaded(filtered));
    });

    on<DeleteContact>((event, emit) async {
      await contactBox.delete(event.contact.key);
      add(LoadContacts());
    });
  }
}
