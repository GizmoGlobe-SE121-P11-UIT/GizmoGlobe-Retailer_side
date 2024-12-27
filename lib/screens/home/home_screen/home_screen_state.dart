import 'package:equatable/equatable.dart';

import '../../../objects/product_related/product.dart';

class HomeScreenState extends Equatable {
  final String username;

  const HomeScreenState({
    this.username = '',
  });

  @override
  List<Object?> get props => [username];

  HomeScreenState copyWith({
    String? username,
  }) {
    return HomeScreenState(
      username: username ?? this.username,
    );
  }
}