import 'package:bloc/bloc.dart';
import 'package:smart_summariser/bloc/summary/summary_event.dart';
import 'package:smart_summariser/bloc/summary/summary_state.dart';

import '../../services/api_service.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final ApiService apiService;

  SummaryBloc({required this.apiService}) : super(SummaryInitial()) {
    on<SummarizeText>(_onSummarizeText);
  }

  Future<void> _onSummarizeText(
      SummarizeText event, Emitter<SummaryState> emit) async {
    emit(SummaryLoading());
    try {
      final summary = await apiService.getSummary(
        event.text,
        event.mode,
      );
      emit(SummaryLoaded(summary: summary));
    } catch (e) {
      emit(SummaryError(error: e.toString()));
    }
  }
}
