import '../manufacturer.dart';
import '../../enums/product_related/category_enum.dart';
import 'cpu_related/cpu.dart';
import 'drive_related/drive.dart';
import 'gpu_related/gpu.dart';
import 'mainboard_related/mainboard.dart';
import 'product.dart';
import 'psu_related/psu.dart';
import 'ram_related/ram.dart';

String _enumName(dynamic e) {
  if (e == null) return '';
  try {
    return (e as dynamic).getName();
  } catch (_) {
    return e.toString();
  }
}

dynamic _manufacturerToJson(Manufacturer? m) {
  if (m == null) return null;
  return m.manufacturerID;
}

dynamic _maybeToJson(dynamic o) {
  if (o == null) return null;
  try {
    return (o as dynamic).toJson();
  } catch (_) {
    return o;
  }
}

List _listToJson(Iterable? it) {
  if (it == null) return <dynamic>[];
  return it.map((e) => _maybeToJson(e)).toList();
}

Map<String, dynamic> productToJson(Product p) {
  final base = <String, dynamic>{
    'productID': p.productID,
    'productName': p.productName,
    'manufacturer': _manufacturerToJson(p.manufacturer),
    'category': _enumName(p.category),
    'importPrice': p.importPrice,
    'sellingPrice': p.sellingPrice,
    'discount': p.discount,
    'release': (p.release.millisecondsSinceEpoch ~/ 1000),
    'stock': p.stock,
    'sales': p.sales,
    'status': _enumName(p.status),
    // imageUrl removed - images now stored in subcollection
    'enDescription': p.enDescription,
    'viDescription': p.viDescription,
  };

  Map<String, dynamic> attributes = {};

  switch (p.category) {
    case CategoryEnum.ram:
      final r = p as RAM;
      attributes = {
        'type': _enumName(r.type),
        'bus': r.bus,
        'clLatency': r.clLatency,
        'kitConfiguration': {
          'stickCount': r.kitStickCount,
          'capacityPerStickGb': r.capacityPerStickGb,
        },
      };
      break;
    case CategoryEnum.cpu:
      final c = p as CPU;
      attributes = {
        'series': _enumName(c.series),
        'socket': _enumName(c.socket),
        'core': c.core,
        'thread': c.thread,
        'baseClock': c.baseClock,
        'turboClock': c.turboClock,
        'tdp': c.tdp,
      };
      break;
    case CategoryEnum.psu:
      final s = p as PSU;
      attributes = {
        'maxWattage': s.maxWattage,
        'efficiency': _enumName(s.efficiency),
        'modular': _enumName(s.modularity),
        'connectors': _listToJson(s.connectors),
      };
      break;
    case CategoryEnum.gpu:
      final g = p as GPU;
      attributes = {
        'series': _enumName(g.series),
        'vramVersion': _enumName(g.version),
        'memory': g.memory,
        'boostClock': g.boostClock,
        'tdp': g.tdp,
        'ports': _listToJson(g.ports),
      };
      break;
    case CategoryEnum.mainboard:
      final m = p as Mainboard;
      attributes = {
        'chipsetCode': m.chipsetCode,
        'socket': _enumName(m.socket),
        'formFactor': _enumName(m.formFactor),
        'ramSpec': _maybeToJson(m.ramSpec),
        'pcieSlots': _listToJson(m.pcieSlots),
        'storageSlots': _maybeToJson(m.storageSlot),
        'ioPorts': _listToJson(m.ioPorts),
      };
      break;
    case CategoryEnum.drive:
      final d = p as Drive;
      attributes = {
        'gen': _enumName(d.gen),
        'memoryGb': d.memoryGb,
        'interfaceType': _enumName(d.interfaceType),
        'speed': {
          'readMbps': d.speed.readMbps,
          'writeMbps': d.speed.writeMbps,
        },
        'formFactor': _enumName(d.formFactor),
        'driveType': _enumName(d.driveType),
      };
      break;
    default:
      attributes = {};
  }

  base['attributes'] = attributes;
  return base;
}
