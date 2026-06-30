import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_list.dart';

class ClientProjectsGalleryScreen extends StatelessWidget {
  const ClientProjectsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServiceProvidersCubit>(),
      child: Scaffold(
        appBar: CustomAppBar.langAppBar(
          showProfileIcon: true,
          title: AppStrings.projectsGallery.tr(),
          centerTitle: true,
        ),
        body: Padding(
          padding: REdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.projectsGallerySubtitle.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.commentColor,
                  height: 1.5,
                ),
              ),
              16.height,
              const Expanded(
                child: ProvidersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
