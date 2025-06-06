
part of 'leads_bloc.dart';

abstract class LeadsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeadsLoading extends LeadsState {}

class LeadsLoaded extends LeadsState {
  final List<Lead> leads;
  LeadsLoaded(this.leads);

  @override
  List<Object?> get props => [leads];
}
