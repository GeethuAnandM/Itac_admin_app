List<dynamic> normalizeVehicleListResponse(dynamic responseData) {
  final dynamic rawItems;

  if (responseData is List) {
    rawItems = responseData;
  } else if (responseData is Map) {
    rawItems = responseData['list'] ?? responseData['data'] ?? const [];
  } else {
    rawItems = const [];
  }

  if (rawItems is! List) {
    return [];
  }

  return rawItems.map((item) {
    final source =
        item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};

    source['vehicleId'] ??= source['id'] ?? source['vehicle_id'];
    source['id'] ??= source['vehicleId'];

    source['deviceId'] ??= source['device_id'];
    source['deviceImei'] ??= source['imei'] ?? source['deviceIMEI'];
    source['deviceName'] ??= source['trackingDevice'] ?? source['device_name'];

    source['vehicleName'] ??= source['name'] ??
        source['licensePlate'] ??
        source['registrationNumber'];
    source['name'] ??= source['vehicleName'];

    source['vehicleTypeName'] ??= source['vehicleType'] ??
        source['typeName'] ??
        source['vehicle_type_name'];
    source['vehicleSubtypeName'] ??= source['vehicleSubtype'] ??
        source['subtypeName'] ??
        source['vehicle_subtype_name'];
    source['vehicleTypeId'] ??= source['typeId'] ?? source['vehicle_type_id'];

    source['manufacturerName'] ??=
        source['manufacturer'] ?? source['manufacturer_name'];
    source['manufacturerId'] ??= source['manufacturer_id'];

    source['model'] ??= source['modelName'] ?? source['vehicleModel'];
    source['modelId'] ??= source['model_id'];

    source['vin'] ??= source['VIN'];
    source['licensePlate'] ??= source['registrationNumber'] ??
        source['regNo'] ??
        source['plateNumber'];

    if (source['insurances'] == null) {
      source['insurances'] = [];
    }

    return source;
  }).toList();
}
