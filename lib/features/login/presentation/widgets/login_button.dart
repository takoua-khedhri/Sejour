import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/login_bloc.dart';
import '../blocs/login_event.dart';
import '../blocs/login_state.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController codeSejourController;
  final TextEditingController passwordController;

  const LoginButton({
    super.key,
    required this.codeSejourController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginLoading) {
          return CircularProgressIndicator();
        }
        return ElevatedButton(
          onPressed: () {
            BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(
              username: codeSejourController.text,
              password: passwordController.text,
            ));
          },
          child: Text("Je me connecte"),

        );
      },
    );
  }
}