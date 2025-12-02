import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class HomeScreenState extends Equatable {
  final String username;
  final int totalProducts;
  final int totalCustomers;
  final double totalRevenue;
  final int totalOrders;
  final Map<String, double> salesByCategory;
  final List<SalesData> monthlySales;
  final int unreadChats;
  final List<SalesInvoice> recentOrders;
  final List<TopProduct> topProducts;
  final bool isLoadingUsername;
  final bool isLoadingOverview;
  final bool isLoadingChart;

  const HomeScreenState({
    this.username = '',
    this.totalProducts = 0,
    this.totalCustomers = 0,
    this.totalRevenue = 0.0,
    this.totalOrders = 0,
    this.salesByCategory = const {},
    this.monthlySales = const [],
    this.unreadChats = 0,
    this.recentOrders = const [],
    this.topProducts = const [],
    this.isLoadingUsername = true,
    this.isLoadingOverview = true,
    this.isLoadingChart = true,
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
        recentOrders,
        topProducts,
        isLoadingUsername,
        isLoadingOverview,
        isLoadingChart,
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
    List<SalesInvoice>? recentOrders,
    List<TopProduct>? topProducts,
    bool? isLoadingUsername,
    bool? isLoadingOverview,
    bool? isLoadingChart,
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
      recentOrders: recentOrders ?? this.recentOrders,
      topProducts: topProducts ?? this.topProducts,
      isLoadingUsername: isLoadingUsername ?? this.isLoadingUsername,
      isLoadingOverview: isLoadingOverview ?? this.isLoadingOverview,
      isLoadingChart: isLoadingChart ?? this.isLoadingChart,
    );
  }
}

class SalesData {
  final DateTime date;
  final double amount;

  SalesData(this.date, this.amount);
}

class TopProduct {
  final String productID;
  final String productName;
  final int totalSales;
  final double totalRevenue;

  TopProduct({
    required this.productID,
    required this.productName,
    required this.totalSales,
    required this.totalRevenue,
  });
}
