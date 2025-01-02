class SalesInvoiceDetail {
  final String salesInvoiceID;
  final String productID;
  final String? productName;
  final String? category;
  final int quantity;
  final double sellingPrice;
  final double subtotal;

  SalesInvoiceDetail({
    required this.salesInvoiceID,
    required this.productID,
    this.productName,
    this.category,
    required this.quantity,
    required this.sellingPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'salesInvoiceID': salesInvoiceID,
      'productID': productID,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'subtotal': subtotal,
    };
  }

  factory SalesInvoiceDetail.fromMap(Map<String, dynamic> map) {
    return SalesInvoiceDetail(
      salesInvoiceID: map['salesInvoiceID'] as String,
      productID: map['productID'] as String,
      productName: map['productName'] as String?,
      category: map['category'] as String?,
      quantity: map['quantity'] as int,
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return toJson(); // For backward compatibility
  }
} 