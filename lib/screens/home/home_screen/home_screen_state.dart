import 'package:equatable/equatable.dart';

class HomeScreenState extends Equatable {
  final String username;
  final int totalProducts;
  final int totalCustomers;
  final double totalRevenue;
  final int totalOrders;
  final Map<String, double> salesByCategory;
  final List<SalesData> monthlySales;
  final int unreadChats;

  const HomeScreenState({
    this.username = '',
    this.totalProducts = 0,
    this.totalCustomers = 0,
    this.totalRevenue = 0.0,
    this.totalOrders = 0,
    this.salesByCategory = const {},
    this.monthlySales = const [],
    this.unreadChats = 0,
  });

  @override
  List<Object?> get props => [
        username,
        totalProducts,
        totalCustomers,
        totalRevenue,
        totalOrders,
        salesByCategory,
        monthlySales,
        unreadChats,
      ];

  HomeScreenState copyWith({
    String? username,
    int? totalProducts,
    int? totalCustomers,
    double? totalRevenue,
    int? totalOrders,
    Map<String, double>? salesByCategory,
    List<SalesData>? monthlySales,
    int? unreadChats,
  }) {
    return HomeScreenState(
      username: username ?? this.username,
      totalProducts: totalProducts ?? this.totalProducts,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      salesByCategory: salesByCategory ?? this.salesByCategory,
      monthlySales: monthlySales ?? this.monthlySales,
      unreadChats: unreadChats ?? this.unreadChats,
    );
  }
}

class SalesData {
  final DateTime date;
  final double amount;

  SalesData(this.date, this.amount);
}
