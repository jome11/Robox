import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';

class RoboxApp extends StatelessWidget {
  const RoboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(),
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            return MaterialApp.router(
              title: 'ROBOX',
              theme: AppTheme.lightTheme,
              routerConfig: AppRouter.router(user),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
