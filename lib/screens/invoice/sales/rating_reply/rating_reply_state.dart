import 'package:equatable/equatable.dart';
import '../../../../objects/invoice_related/rating.dart';

abstract class RatingReplyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RatingReplyInitial extends RatingReplyState {}

class RatingReplyLoading extends RatingReplyState {}

class RatingReplyLoaded extends RatingReplyState {
  final List<Rating> newRatings;
  final List<Rating> repliedRatings;
  final bool hasMoreNew;
  final bool hasMoreReplied;

  RatingReplyLoaded(
      {required this.newRatings,
      required this.repliedRatings,
      this.hasMoreNew = false,
      this.hasMoreReplied = false});

  @override
  List<Object?> get props => [newRatings, repliedRatings, hasMoreNew, hasMoreReplied];
}

class RatingReplyError extends RatingReplyState {
  final String message;
  RatingReplyError(this.message);

  @override
  List<Object?> get props => [message];
}
