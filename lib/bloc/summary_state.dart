import 'package:equatable/equatable.dart';

abstract class SummaryState extends Equatable {
  @override
  List<Object> get props => [];
}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final String summary;
  SummaryLoaded({required this.summary});

  @override
  List<Object> get props => [summary];
}

// ✅ Add this missing error state
class SummaryError extends SummaryState {
  final String error;
  SummaryError({required this.error});

  @override
  List<Object> get props => [error];
}
