import 'package:taal/core/provider_offering/provider_offering_mode.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';

class CreateServiceOrderArgs {
  const CreateServiceOrderArgs({
    this.provider,
    this.serviceTypeId,
    this.visitType = ServiceOrderVisitType.mobileOnSite,
  });

  final ServiceProviderModel? provider;
  final String? serviceTypeId;
  final ServiceOrderVisitType visitType;
}
