
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/contacts_model.dart';
import '../../models/lead.dart';

part 'leads_event.dart';
part 'leads_state.dart';

class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final Box<Lead> leadsBox;
  String _searchQuery = '';

  LeadsBloc(this.leadsBox) : super(LeadsLoading()) {
    on<LoadLeads>((event, emit) {
      final leads = leadsBox.values.toList();
      emit(LeadsLoaded(leads));
    });

    on<AddLead>((event, emit) async {
      await leadsBox.put(event.lead.id, event.lead);
      add(LoadLeads());
    });

    on<DeleteLead>((event, emit) async {
      await leadsBox.delete(event.lead.key);
      add(LoadLeads());
    });

    on<UpdateLead>((event, emit) async {
      await leadsBox.put(event.lead.key.toString(), event.lead);
      add(LoadLeads());
    });

    on<SearchLeads>((event, emit) {
      _searchQuery = event.query;
      final allLeads = leadsBox.values.toList();
      final searched = allLeads.where((lead) {
        final matchesQuery = lead.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            lead.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            lead.phone.contains(_searchQuery);
        return matchesQuery;
      }).toList();

      emit(LeadsLoaded(searched));
    });

    on<FilterLeads>((event, emit) {
      final allLeads = leadsBox.values.toList();
      final filtered = event.status == 'All'
          ? allLeads
          : allLeads.where((l) => l.status == event.status).toList();
      emit(LeadsLoaded(filtered));
    });

    on<ConvertLeadToContact>((event, emit) async {
      final contactBox = Hive.box<Contact>('contacts');
      final lead = event.lead;

      final contact = Contact(
        id: const Uuid().v4(),
        name: lead.name,
        email: lead.email,
        phone: lead.phone,
      );

      await contactBox.add(contact);
      await lead.delete();

      add(LoadLeads());
    });
  }
}

