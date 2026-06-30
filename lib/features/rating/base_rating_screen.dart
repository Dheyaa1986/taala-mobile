import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/features/home/provider/presentation/screens/provider_view.dart';
import 'package:taal/features/rating/presentation/screens/rating_screen.dart';

import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'package:taal/features/home/client/presentation/screens/client_projects_gallery_screen.dart';

class BaseRatingScreen extends StatelessWidget {
  const BaseRatingScreen({super.key });

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child:context.read<BottomNavigationCubit>().isProvider? const RatingScreen(): const ClientProjectsGalleryScreen(),
      ),
    );
  }
}
