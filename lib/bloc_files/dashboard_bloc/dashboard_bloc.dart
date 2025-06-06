
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/dashboard_data.dart';
import '../../repository/dashboard_repository.dart';


part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardLoading()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      final data = await repository.fetchDashboardData();
      emit(DashboardLoaded(data));
    });
  }
}
