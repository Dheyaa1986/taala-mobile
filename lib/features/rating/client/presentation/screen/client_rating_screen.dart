import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/rating/client/presentation/cubit/client_ratings_cubit.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/di/service_locator.dart';
import '../widget/client_ratings_list.dart';

class ClientRatingsScreen extends StatelessWidget {
  const ClientRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientRatingsCubit>(),
      child: Scaffold(
        appBar: CustomAppBar.langAppBar(
          showProfileIcon: true,
          title: AppStrings.rateProvider.tr(),
          centerTitle: true,
        ),
        body: Padding(
          padding: REdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClientRatingsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
