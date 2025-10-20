class IOPort {
  String port;
  int quantity;

  IOPort({required this.port, required this.quantity});

  factory IOPort.fromJson(Map<String, dynamic> json) => IOPort(
    port: json['port']?.toString() ?? '',
    quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
  );
}