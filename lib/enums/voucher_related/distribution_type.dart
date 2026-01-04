import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

enum DistributionType {
  public('Public'),
  rewards('Rewards'),
  staffIssued('Staff-Issued'),
  ;

  final String description;

  const DistributionType(this.description);

  String getName() {
    return name;
  }

  /// Returns the localized name of this distribution type
  String getLocalizedName(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case DistributionType.public:
        return s.distributionPublic;
      case DistributionType.rewards:
        return s.distributionRewards;
      case DistributionType.staffIssued:
        return s.distributionStaffIssued;
    }
  }

  @override
  String toString() {
    return description;
  }
}

extension DistributionTypeExtension on DistributionType {
  static DistributionType fromName(String name) {
    return DistributionType.values.firstWhere((e) => e.getName() == name);
  }
}
