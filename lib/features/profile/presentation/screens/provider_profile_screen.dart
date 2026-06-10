import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/profile/data/models/portfolio_model.dart';
import 'package:taal/features/profile/presentation/screens/add_portfolio_screen.dart';
import 'package:taal/features/profile/presentation/widgets/portfolio_card.dart';
import 'package:taal/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:taal/features/profile/presentation/widgets/provider_profile_client_widgets.dart';
import 'package:taal/features/profile/presentation/widgets/service_chip.dart';

import '../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class ProviderProfileScreen extends StatelessWidget {
  final String? id;
  const ProviderProfileScreen({super.key, this.id});

  bool get _isActive => true;
  List<String> get _services => [
        "Plumbing",
        "Electrical",
        "Carpentry",
        "Cleaning",
        "Gardening",
      ];

  @override
  Widget build(BuildContext context) {
    bool isProvider = context.read<BottomNavigationCubit>().isProvider ?? true;
    return Scaffold(
      appBar: CustomAppBar.langAppBar(
        title: "Profile",
        actions: [
          IconButton(
            icon: const SvgImageWidget(
              image: AppIcons.share,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
        child: CustomScrollView(
          slivers: [
            SliverList.list(
              children: [
                20.height,
                Align(
                  child: ProfileAvatar(
                    isActive: isProvider ? _isActive : false,
                    url:
                        "https://cdn-icons-png.flaticon.com/512/219/219983.png",
                  ),
                ),
                20.height,
                Text(
                  "John Doe",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                8.height,
                if (!isProvider)
                  Column(
                    children: [
                      ProviderProfileClientWidgets(services: _services)
                    ],
                  ),
                if (isProvider) ...[
                  if (_services.isNotEmpty) ...[
                    16.height,
                    SizedBox(
                      height: 32.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) => ServiceChip(
                          service: _services[index],
                        ),
                        separatorBuilder: (_, __) => 10.width,
                        itemCount: _services.length,
                      ),
                    )
                  ],
                  24.height,
                  Align(
                    child: CustomButton.filled(
                      onTap: () => context.pushNamed(Routes.editProfile),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      radius: const Radius.circular(12).r,
                      width: 161.w,
                      text: "Edit Profile",
                    ),
                  ),
                  32.height,
                  GestureDetector(
                    onTap: () => getIt<DioService>().logout(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Colors.red),
                          8.width,
                          Text(
                            AppStrings.logout.tr(),
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  16.height,
                ],
              ],
            ),
            if (isProvider) ...[
              SliverPinnedHeader(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Portfolio",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: CustomButton.text(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddPortfolioScreen(),
                            ),
                          ),
                          prefix: const Icon(
                            Icons.add,
                            color: AppColors.primaryColor,
                          ),
                          text: "Add New",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: 24.height),
              SliverList.separated(
                itemCount: 8,
                itemBuilder: (_, index) => PortfolioCard(
                  portfolio: PortfolioModel(
                    id: "$index",
                    name: "Portfolio Item $index",
                    description:
                        "Etiam eu lorem lectus. Cras blandit at elit id blandit. Morbi fibus euismod tincidunt blandit at elit id.Etiam eu lorem lect.",
                    images: [
                      "https://picsum.photos/200/300?random=$index",
                    ],
                  ),
                ),
                separatorBuilder: (_, __) => 8.height,
              ),
              SliverToBoxAdapter(child: 24.height),
            ],
          ],
        ),
      ),
    );
  }
}
