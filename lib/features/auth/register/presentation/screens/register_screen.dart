
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/countries/presentation/cubit/countries_cubit.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../cubit/register_cubit.dart';
import '../widgets/register_form.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<RegisterCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<CountriesCubit>()..getCountries(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return const Scaffold(
            body: RegisterForm(),
          );
        },
      ),
    );
  }
}
