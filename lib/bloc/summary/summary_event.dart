import 'package:equatable/equatable.dart';

abstract class SummaryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SummarizeText extends SummaryEvent {
  final String text;
  final String mode;

  SummarizeText(this.text, {required this.mode});

  @override
  List<Object> get props => [text, mode];
}
