import 'package:bloc/bloc.dart';

import '../services/api_service.dart';
import 'summary_event.dart';
import 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final ApiService apiService;

  SummaryBloc({required this.apiService}) : super(SummaryInitial()) {
    on<SummarizeText>(_onSummarizeText);
  }

  Future<void> _onSummarizeText(
      SummarizeText event, Emitter<SummaryState> emit) async {
    emit(SummaryLoading());
    try {
      final summary = await apiService.getSummary(event.text);
      emit(SummaryLoaded(summary: summary));
    } catch (e) {
      emit(SummaryError(error: e.toString()));
    }
  }
}
