class Connector {
  String type;
  int quantity;

  Connector({required this.type, required this.quantity});

  factory Connector.fromJson(Map<String, dynamic> json) => Connector(
    type: json['type']?.toString() ?? '',
    quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
  );

}