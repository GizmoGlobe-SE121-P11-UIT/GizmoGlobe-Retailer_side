import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/objects/address_related/district.dart';
import 'package:gizmoglobe_client/objects/address_related/province.dart';
import 'package:gizmoglobe_client/objects/address_related/ward.dart';

class Address {
  final String? addressID;
  final String customerID;
  final String receiverName;
  final String receiverPhone;
  final Province? province;
  final District? district;
  final Ward? ward;
  final String? street;
  final bool isDefault;

  Address({
    this.addressID,
    required this.customerID,
    required this.receiverName,
    required this.receiverPhone,
    this.province,
    this.district,
    this.ward,
    this.street,
    required this.isDefault,
  });

  @override
  String toString() {
    return '$receiverName - $receiverPhone'
          '${street != null ? ', $street' : ''}'
          '${ward != null ? ', $ward' : ''}'
          '${district != null ? ', $district' : ''}'
          '${province != null ? ', $province' : ''}';
  }

  Map<String, dynamic> toMap() {
    return {
      'AddressID': addressID,
      'CustomerID': customerID,
      'ReceiverName': receiverName,
      'ReceiverPhone': receiverPhone,
      'ProvinceCode': province?.code,
      'DistrictCode': district?.code,
      'WardCode': ward?.code,
      'Street': street,
      'IsDefault': isDefault,
    };
  }

  static Address fromMap(Map<String, dynamic> map) {
    final province = Database().provinceList.firstWhere((p) => p.code == map['ProvinceCode'], orElse: () => Province.nullProvince);
    final district = province.districts?.firstWhere((d) => d.code == map['DistrictCode'], orElse: () => District.nullDistrict) ?? District.nullDistrict;
    final ward = district.wards?.firstWhere((w) => w.code == map['WardCode'], orElse: () => Ward.nullWard) ?? Ward.nullWard;

    return Address(
      addressID: map['AddressID'],
      customerID: map['CustomerID'],
      receiverName: map['ReceiverName'],
      receiverPhone: map['ReceiverPhone'],
      province: province,
      district: district,
      ward: ward,
      street: map['Street'],
      isDefault: map['IsDefault'],
    );
  }
}