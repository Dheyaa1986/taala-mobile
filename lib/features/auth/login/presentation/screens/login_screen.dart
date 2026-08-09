import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import 'package:taal/core/widgets/svg_image/lang_popup.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: LangPopup(),
                ),
                Expanded(
                  child: LoginForm(
                    initialIsProvider: widget.initialIsProvider,
                    hideHeaderLanguage: true,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
