import 'package:equatable/equatable.dart';


class HomeScreenState extends Equatable {
  final String username;
  final String searchText;

  const HomeScreenState({
    this.username = '',
    this.searchText = '',
  });

  @override
  List<Object?> get props => [username, searchText];

  HomeScreenState copyWith({
    String? username,
    String? searchText,
  }) {
    return HomeScreenState(
      username: username ?? this.username,
      searchText: searchText ?? this.searchText,
    );
  }
}