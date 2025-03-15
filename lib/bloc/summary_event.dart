import 'package:equatable/equatable.dart';

abstract class SummaryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SummarizeText extends SummaryEvent {
  final String text;

  SummarizeText(this.text);

  @override
  List<Object> get props => [text];
}
