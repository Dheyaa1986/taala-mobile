import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../cubit/login_cubit/login_cubit.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  final bool? initialIsProvider;
  const LoginScreen({super.key, this.initialIsProvider});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: Builder(builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LoginForm(initialIsProvider: widget.initialIsProvider),
          ),
        );
      }),
    );
  }
}
