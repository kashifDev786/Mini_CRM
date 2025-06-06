
part of 'leads_bloc.dart';

abstract class LeadsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLeads extends LeadsEvent {}

class AddLead extends LeadsEvent {
  final Lead lead;
  AddLead(this.lead);
}

class DeleteLead extends LeadsEvent {
  final Lead lead;
  DeleteLead(this.lead);
}

class UpdateLead extends LeadsEvent {
  final Lead lead;
  UpdateLead(this.lead);
}

class FilterLeads extends LeadsEvent {
  final String status;
  FilterLeads(this.status);
}
class SearchLeads extends LeadsEvent {
  final String query;
  SearchLeads(this.query);
}

class ConvertLeadToContact extends LeadsEvent {
  final Lead lead;
  ConvertLeadToContact(this.lead);
}

