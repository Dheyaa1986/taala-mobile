import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';

class CreateServiceOrderArgs {
  const CreateServiceOrderArgs({
    this.provider,
    this.serviceTypeId,
  });

  final ServiceProviderModel? provider;
  final String? serviceTypeId;
}
