

import '../../models/contacts_model.dart';

abstract class ContactsEvent {}

class LoadContacts extends ContactsEvent {}

class AddContact extends ContactsEvent {
  final Contact contact;
  AddContact(this.contact);
}
class SearchContacts extends ContactsEvent {
  final String query;
  SearchContacts(this.query);
}
class UpdateContact extends ContactsEvent {
  final Contact contact;
  UpdateContact(this.contact);
}

class DeleteContact extends ContactsEvent {
  final Contact contact;
  DeleteContact(this.contact);
}
