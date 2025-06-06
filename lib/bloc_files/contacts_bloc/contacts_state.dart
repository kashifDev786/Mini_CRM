
import '../../models/contacts_model.dart';

abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Contact> contacts;
  ContactsLoaded(this.contacts);
}
