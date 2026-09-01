import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khetiq/features/user_profile/services/user_profile_service.dart';
import 'package:khetiq/features/farm/services/farm_service.dart';

import '../../../app/app_routes.dart';

class AuthCheckView extends StatelessWidget {
  const AuthCheckView({super.key});

  Future<Map<String, dynamic>> _checkUserStatus(String uid) async {
    final profile = await UserProfileService().getProfile(uid);
    if (profile == null) {
      return {'hasProfile': false, 'hasFarm': false};
    }
    final farms = await FarmService().getFarms(uid);
    return {
      'hasProfile': true,
      'hasFarm': farms.isNotEmpty,
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is checking authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is already logged in.
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<Map<String, dynamic>>(
            future: _checkUserStatus(user.uid),
            builder: (context, statusSnapshot) {
              if (statusSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (statusSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error loading status: ${statusSnapshot.error}'),
                  ),
                );
              }

              final data = statusSnapshot.data;
              if (data != null) {
                final hasProfile = data['hasProfile'] as bool;
                final hasFarm = data['hasFarm'] as bool;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    if (!hasProfile) {
                      context.go(AppRoutes.profileSetup);
                    } else if (!hasFarm) {
                      context.go(AppRoutes.farmSetup);
                    } else {
                      context.go(AppRoutes.myFarm);
                    }
                  }
                });
              }

              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        // User is not logged in.
        else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          });
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
