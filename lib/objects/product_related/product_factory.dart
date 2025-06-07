import '../../enums/product_related/category_enum.dart';
import 'product.dart';
import 'ram.dart';
import 'psu.dart';
import 'cpu.dart';
import 'drive.dart';
import 'gpu.dart';
import 'mainboard.dart';

class ProductFactory {
  static Product createProduct(
      CategoryEnum category, Map<String, dynamic> properties) {
    switch (category) {
      case CategoryEnum.ram:
        return RAM(
          productName: properties['productName'],
          manufacturer: properties['manufacturer'],
          category: category,
          importPrice: properties['importPrice'],
          sellingPrice: properties['sellingPrice'],
          discount: properties['discount'],
          release: properties['release'],
          stock: properties['stock'],
          sales: properties['sales'],
          status: properties['status'],
          bus: properties['bus'],
          capacity: properties['capacity'],
          ramType: properties['ramType'],
          imageUrl: properties['imageUrl'],
        )..productID = properties['productID'];
      case CategoryEnum.cpu:
        return CPU(
          productName: properties['productName'],
          manufacturer: properties['manufacturer'],
          category: category,
          importPrice: properties['importPrice'],
          sellingPrice: properties['sellingPrice'],
          discount: properties['discount'],
          release: properties['release'],
          family: properties['family'],
          core: properties['core'],
          thread: properties['thread'],
          clockSpeed: properties['clockSpeed'],
          stock: properties['stock'],
          sales: properties['sales'],
          status: properties['status'],
          imageUrl: properties['imageUrl'],
        )..productID = properties['productID'];
      case CategoryEnum.psu:
        return PSU(
          productName: properties['productName'],
          manufacturer: properties['manufacturer'],
          category: category,
          importPrice: properties['importPrice'],
          sellingPrice: properties['sellingPrice'],
          discount: properties['discount'],
          release: properties['release'],
          wattage: properties['wattage'],
          efficiency: properties['efficiency'],
          modular: properties['modular'],
          stock: properties['stock'],
          sales: properties['sales'],
          status: properties['status'],
          imageUrl: properties['imageUrl'],
        )..productID = properties['productID'];
      case CategoryEnum.gpu:
        return GPU(
          productName: properties['productName'],
          manufacturer: properties['manufacturer'],
          category: category,
          importPrice: properties['importPrice'],
          sellingPrice: properties['sellingPrice'],
          discount: properties['discount'],
          release: properties['release'],
          series: properties['series'],
          capacity: properties['capacity'],
          bus: properties['busWidth'],
          clockSpeed: properties['clockSpeed'],
          stock: properties['stock'],
          sales: properties['sales'],
          status: properties['status'],
          imageUrl: properties['imageUrl'],
        )..productID = properties['productID'];
      case CategoryEnum.mainboard:
        return Mainboard(
          productName: properties['productName'],
          manufacturer: properties['manufacturer'],
          category: category,
          importPrice: properties['importPrice'],
          sellingPrice: properties['sellingPrice'],
          discount: properties['discount'],
          release: properties['release'],
          formFactor: properties['formFactor'],
          series: properties['series'],
          compatibility: properties['compatibility'],
          stock: properties['stock'],
          sales: properties['sales'],
          status: properties['status'],
          imageUrl: properties['imageUrl'],
        )..productID = properties['productID'];
      case CategoryEnum.drive:
        return Drive(
          productName: properties['productName'],
          manufacturer: properties['manufacturer'],
          category: category,
          importPrice: properties['importPrice'],
          sellingPrice: properties['sellingPrice'],
          discount: properties['discount'],
          release: properties['release'],
          type: properties['type'],
          capacity: properties['capacity'],
          stock: properties['stock'],
          sales: properties['sales'],
          status: properties['status'],
          imageUrl: properties['imageUrl'],
        )..productID = properties['productID'];
      default:
        throw Exception('Invalid product category');
    }
  }
}
