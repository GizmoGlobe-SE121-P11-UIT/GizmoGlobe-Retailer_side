class StorageSlot {
  int m2Slots;
  int sataPorts;

  StorageSlot({required this.m2Slots, required this.sataPorts});

  factory StorageSlot.fromJson(Map<String, dynamic> json) => StorageSlot(
    m2Slots: (json['m2Slots'] is num) ? (json['m2Slots'] as num).toInt() : int.tryParse(json['m2Slots']?.toString() ?? '') ?? 0,
    sataPorts: (json['sataPorts'] is num) ? (json['sataPorts'] as num).toInt() : int.tryParse(json['sataPorts']?.toString() ?? '') ?? 0,
  );
}