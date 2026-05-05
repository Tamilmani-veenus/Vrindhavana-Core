// To parse this JSON data, do
//
//     final onItemSelectMrnList = onItemSelectMrnListFromJson(jsonString);

import 'dart:convert';

OnItemSelectMrnList onItemSelectMrnListFromJson(String str) => OnItemSelectMrnList.fromJson(json.decode(str));

String onItemSelectMrnListToJson(OnItemSelectMrnList data) => json.encode(data.toJson());

class OnItemSelectMrnList {
  bool? success;
  String? message;
  List<Result>? result;

  OnItemSelectMrnList({
    this.success,
    this.message,
    this.result,
  });

  factory OnItemSelectMrnList.fromJson(Map<String, dynamic> json) => OnItemSelectMrnList(
    success: json["success"],
    message: json["message"],
    result: json["result"]==null?null:List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": result == null? null :List<dynamic>.from(result!.map((x) => x.toJson())),
  };
}

class Result {
  String? projectName;
  String? siteName;
  String? scaleName;
  String? materialName;
  int? reqOrdDetId;
  int? reqOrdMasId;
  double? reqQty;
  double? qty;
  String? approveType;
  String? remarks;

  Result({
    this.projectName,
    this.siteName,
    this.scaleName,
    this.materialName,
    this.reqOrdDetId,
    this.reqOrdMasId,
    this.reqQty,
    this.qty,
    this.approveType,
    this.remarks,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    projectName: json["projectName"],
    siteName: json["siteName"],
    scaleName: json["scaleName"],
    materialName: json["materialName"],
    reqOrdDetId: json["reqOrdDetId"],
    reqOrdMasId: json["reqOrdMasId"],
    reqQty: json["reqQty"],
    qty: json["qty"],
    approveType: json["approveType"],
    remarks: json["remarks"],
  );

  Map<String, dynamic> toJson() => {
    "projectName": projectName,
    "siteName": siteName,
    "scaleName": scaleName,
    "materialName": materialName,
    "reqOrdDetId": reqOrdDetId,
    "reqOrdMasId": reqOrdMasId,
    "reqQty": reqQty,
    "qty": qty,
    "approveType": approveType,
    "remarks": remarks,
  };
}
