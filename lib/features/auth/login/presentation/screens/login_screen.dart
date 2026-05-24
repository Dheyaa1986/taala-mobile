import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../cubit/login_cubit/login_cubit.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  final bool isProvider;
  const LoginScreen({super.key, this.isProvider = false});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: Builder(builder: (context) {
        return  Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.only(bottom: 0),
           child: LoginForm(isProvider: widget.isProvider),
          ),
        );
      }),
    );
  }
}
