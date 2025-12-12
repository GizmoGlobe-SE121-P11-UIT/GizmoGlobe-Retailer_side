import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class HomeScreenState extends Equatable {
  final String username;
  final int totalProducts;
  final int totalCustomers;
  final int totalManufacturers;
  final int totalEmployees;
  final double totalRevenue;
  final int totalOrders;
  final Map<String, double> salesByCategory;
  final List<SalesData> monthlySales;
  final List<SalesData> dailySales;
  final List<CategorySalesData> monthlyCategorySales;
  final List<CategorySalesData> dailyCategorySales;
  final int unreadChats;
  final List<SalesInvoice> recentOrders;
  final List<TopProduct> topProducts;
  final bool isLoadingUsername;
  final bool isLoadingOverview;
  final bool isLoadingChart;
  final Map<String, int>
      productCountsByCategory; // { "RAM": 10, "CPU": 5, ... }
  final bool isLoadingProductCounts;

  const HomeScreenState({
    this.username = '',
    this.totalProducts = 0,
    this.totalCustomers = 0,
    this.totalManufacturers = 0,
    this.totalEmployees = 0,
    this.totalRevenue = 0.0,
    this.totalOrders = 0,
    this.salesByCategory = const {},
    this.monthlySales = const [],
    this.dailySales = const [],
    this.monthlyCategorySales = const [],
    this.dailyCategorySales = const [],
    this.unreadChats = 0,
    this.recentOrders = const [],
    this.topProducts = const [],
    this.isLoadingUsername = true,
    this.isLoadingOverview = true,
    this.isLoadingChart = true,
    this.productCountsByCategory = const {},
    this.isLoadingProductCounts = true,
  });

  @override
  List<Object?> get props => [
        username,
        totalProducts,
        totalCustomers,
        totalManufacturers,
        totalEmployees,
        totalRevenue,
        totalOrders,
        salesByCategory,
        monthlySales,
        dailySales,
        monthlyCategorySales,
        dailyCategorySales,
        unreadChats,
        recentOrders,
        topProducts,
        isLoadingUsername,
        isLoadingOverview,
        isLoadingChart,
        productCountsByCategory,
        isLoadingProductCounts,
      ];

  HomeScreenState copyWith({
    String? username,
    int? totalProducts,
    int? totalCustomers,
    int? totalManufacturers,
    int? totalEmployees,
    double? totalRevenue,
    int? totalOrders,
    Map<String, double>? salesByCategory,
    List<SalesData>? monthlySales,
    List<SalesData>? dailySales,
    List<CategorySalesData>? monthlyCategorySales,
    List<CategorySalesData>? dailyCategorySales,
    int? unreadChats,
    List<SalesInvoice>? recentOrders,
    List<TopProduct>? topProducts,
    bool? isLoadingUsername,
    bool? isLoadingOverview,
    bool? isLoadingChart,
    Map<String, int>? productCountsByCategory,
    bool? isLoadingProductCounts,
  }) {
    return HomeScreenState(
      username: username ?? this.username,
      totalProducts: totalProducts ?? this.totalProducts,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalManufacturers: totalManufacturers ?? this.totalManufacturers,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      salesByCategory: salesByCategory ?? this.salesByCategory,
      monthlySales: monthlySales ?? this.monthlySales,
      dailySales: dailySales ?? this.dailySales,
      monthlyCategorySales: monthlyCategorySales ?? this.monthlyCategorySales,
      dailyCategorySales: dailyCategorySales ?? this.dailyCategorySales,
      unreadChats: unreadChats ?? this.unreadChats,
      recentOrders: recentOrders ?? this.recentOrders,
      topProducts: topProducts ?? this.topProducts,
      isLoadingUsername: isLoadingUsername ?? this.isLoadingUsername,
      isLoadingOverview: isLoadingOverview ?? this.isLoadingOverview,
      isLoadingChart: isLoadingChart ?? this.isLoadingChart,
      productCountsByCategory:
          productCountsByCategory ?? this.productCountsByCategory,
      isLoadingProductCounts:
          isLoadingProductCounts ?? this.isLoadingProductCounts,
    );
  }
}

class SalesData {
  final DateTime date;
  final double amount;

  SalesData(this.date, this.amount);
}

class CategorySalesData {
  final DateTime date;
  final Map<String, double>
      categoryAmounts; // { "RAM": 1000, "CPU": 2000, ... }

  CategorySalesData(this.date, this.categoryAmounts);
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
