import '../../../../home/client/data/model/service_provider_model/service_provider_model.dart';

class ClientRatingsModel {
  ServiceProviderModel? serviceProviderModel;
  int? id;
  double? rating;
  String? comment;
  String? date;
  ClientRatingsModel({
    this.serviceProviderModel,
    this.rating,
    this.id,
    this.comment,
    this.date,
});

  ClientRatingsModel.fromJson(Map<String, dynamic> json) {
    serviceProviderModel = json['serviceProviderModel'] != null
        ? ServiceProviderModel.fromJson(json['serviceProviderModel'])
        : null;
    rating = json['rating'];
    comment = json['comment'];
    date = json['date'];
    id = json['id'];
  }
}