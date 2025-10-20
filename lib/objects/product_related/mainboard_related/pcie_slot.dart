import 'package:flutter/material.dart';

class PCIeSlot {
  int physicalSize;
  int electricalSpeed;
  int gen;
  int quantity;

  PCIeSlot({required this.physicalSize, required this.electricalSpeed, required this.gen, required this.quantity});

  factory PCIeSlot.fromJson(Map<String, dynamic> json) => PCIeSlot(
    physicalSize: (json['physicalSize'] is num) ? (json['physicalSize'] as num).toInt() : int.tryParse(json['physicalSize']?.toString() ?? '') ?? 0,
    electricalSpeed: (json['electricalSpeed'] is num) ? (json['electricalSpeed'] as num).toInt() : int.tryParse(json['electricalSpeed']?.toString() ?? '') ?? 0,
    gen: (json['gen'] is num) ? (json['gen'] as num).toInt() : int.tryParse(json['gen']?.toString() ?? '') ?? 0,
    quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
  );
}

class PCIeSlotControllers {
  final TextEditingController physicalSizeController;
  final TextEditingController electricalSpeedController;
  final TextEditingController genController;
  final TextEditingController quantityController;

  PCIeSlotControllers({
    String? physicalSize,
    String? electricalSpeed,
    String? gen,
    String? quantity,
  })  : physicalSizeController = TextEditingController(text: physicalSize),
        electricalSpeedController = TextEditingController(text: electricalSpeed),
        genController = TextEditingController(text: gen),
        quantityController = TextEditingController(text: quantity);

  void dispose() {
    physicalSizeController.dispose();
    electricalSpeedController.dispose();
    genController.dispose();
    quantityController.dispose();
  }
}