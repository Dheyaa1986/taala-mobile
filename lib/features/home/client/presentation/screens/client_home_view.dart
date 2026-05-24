import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/home/client/presentation/widgets/lang_search_providers_bar.dart';

import '../../../../../core/options/pagination_options.dart';
import '../cubit/service_providers_cubit.dart';
import '../widgets/filter_button.dart';
import '../widgets/service_provider_list.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ServiceProvidersCubit>(),
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: LangSearchProvidersWidget(controller: controller)),
        body:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            children: [
               FilterServiceButton(),
              16.height,
              const Expanded(child: ProvidersList()),
            ],
          ),
        ),
      ),
    );
  }
}
