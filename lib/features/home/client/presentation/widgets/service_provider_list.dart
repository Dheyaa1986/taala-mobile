import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_card.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/home/provider/presentation/widgets/location_card.dart';

class ProvidersList extends StatefulWidget {
  const ProvidersList({
    super.key,
  });

  @override
  State<ProvidersList> createState() => _ProvidersListState();
}

class _ProvidersListState extends State<ProvidersList> {
  @override
  void initState() {
    context.read<ServiceProvidersCubit>().getProviders(reset: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        BlocBuilder<ServiceProvidersCubit, ServiceProvidersState>(
          builder: (context, state) {
            if (state is ServiceProvidersLoaded) {
              List<ServiceProviderModel> providers = state.serviceProviders;

              return SliverList.separated(
                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return ServiceProviderCard(model: providers[index]);
                },
                itemCount: providers.length,
              );
            } else if (state is ServiceProvidersLoading) {
              return SliverList.separated(
                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return const SizedBox();
                },
                itemCount: 10,
              );
            } else if (state is ServiceProvidersError) {
              return SliverToBoxAdapter(
                child: Text(state.error),
              );
            } else {
              return const SliverToBoxAdapter(child: SizedBox());
            }
          },
        ),
        SliverToBoxAdapter(child: 20.height),
      ],
    );
  }
}
