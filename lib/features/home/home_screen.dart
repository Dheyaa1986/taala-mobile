import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/features/home/provider/presentation/screens/provider_view.dart';

import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../rating/client/presentation/screen/client_rating_screen.dart';
import 'client/presentation/screens/client_home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key });

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child:context.read<BottomNavigationCubit>().isProvider? const LocationsScreen(): const ClientHomeView(),
      ),
    );
  }
}
