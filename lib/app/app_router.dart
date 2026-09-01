import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:khetiq/features/authentication/views/auth_check_view.dart';
import 'package:khetiq/features/crop_diary/bindings/crop_diary_binding.dart';
import 'package:khetiq/features/crop_diary/views/add_diary_entry_view.dart';
import 'package:khetiq/features/crop_diary/views/crop_diary_view.dart';
import 'package:khetiq/features/crop_diary/views/diary_entry_details_view.dart';
import 'package:khetiq/features/crop_diary/views/edit_diary_entry_view.dart';
import 'package:khetiq/features/crop_planner/bindings/crop_planner_binding.dart';
import 'package:khetiq/features/crop_planner/views/add_crop_view.dart';
import 'package:khetiq/features/crop_planner/views/crop_details_view.dart';
import 'package:khetiq/features/crop_planner/views/crop_planner_view.dart';
import 'package:khetiq/features/crop_planner/views/edit_crop_view.dart';
import 'package:khetiq/features/farm/bindings/farm_binding.dart';
import 'package:khetiq/features/farm/views/edit_farm_view.dart';
import 'package:khetiq/features/farm/views/farm_details_view.dart';
import 'package:khetiq/features/farm/views/farm_setup_view.dart';
import 'package:khetiq/features/farm/views/my_farm_view.dart';
import 'package:khetiq/features/user_profile/bindings/user_profile_binding.dart';
import 'package:khetiq/features/user_profile/views/profile_setup_view.dart';

import '../features/authentication/views/forgot_password_view.dart';
import '../features/authentication/views/login_view.dart';
import '../features/authentication/views/register_view.dart';
import '../features/home/views/home_view.dart';
import 'app_routes.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: Get.key,
    initialLocation: AppRoutes.authCheck,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return LoginView();
        },
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          return RegisterView();
        },
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          return ForgotPasswordView();
        },
      ),

      GoRoute(
        path: AppRoutes.authCheck,
        builder: (context, state) => const AuthCheckView(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) {
          UserProfileBinding().dependencies();
          return ProfileSetupView();
        },
      ),

      GoRoute(
        path: AppRoutes.farmSetup,
        builder: (context, state) {
          FarmBinding().dependencies();

          return FarmSetupView();
        },
      ),

      GoRoute(
        path: AppRoutes.myFarm,
        builder: (context, state) {
          FarmBinding().dependencies();

          return const MyFarmView();
        },
      ),

      GoRoute(
        path: '${AppRoutes.farmDetails}/:farmId',
        builder: (context, state) {
          FarmBinding().dependencies();

          final farmId = state.pathParameters['farmId']!;

          return FarmDetailsView(farmId: farmId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.editFarm}/:farmId',
        builder: (context, state) {
          FarmBinding().dependencies();

          final farmId = state.pathParameters['farmId']!;

          return EditFarmView(farmId: farmId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.cropPlanner}/:farmId',
        builder: (context, state) {
          CropPlannerBinding().dependencies();

          final farmId = state.pathParameters['farmId']!;

          return CropPlannerView(farmId: farmId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.addCrop}/:farmId',
        builder: (context, state) {
          CropPlannerBinding().dependencies();

          final farmId = state.pathParameters['farmId']!;

          return AddCropView(farmId: farmId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.cropDetails}/:farmId/:cropId',
        builder: (context, state) {
          CropPlannerBinding().dependencies();

          final farmId = state.pathParameters['farmId']!;

          final cropId = state.pathParameters['cropId']!;

          return CropDetailsView(farmId: farmId, cropId: cropId);
        },
      ),

      GoRoute(
        path: '${AppRoutes.editCrop}/:farmId/:cropId',
        builder: (context, state) {
          CropPlannerBinding().dependencies();

          final farmId = state.pathParameters['farmId']!;

          final cropId = state.pathParameters['cropId']!;

          return EditCropView(farmId: farmId, cropId: cropId);
        },
      ),


      GoRoute(
  path: '${AppRoutes.cropDiary}/:farmId/:cropId',
  builder: (context, state) {
    CropDiaryBinding().dependencies();

    final farmId = state.pathParameters['farmId']!;
    final cropId = state.pathParameters['cropId']!;

    return CropDiaryView(
      farmId: farmId,
      cropId: cropId,
    );
  },
),

GoRoute(
  path: '${AppRoutes.addDiaryEntry}/:farmId/:cropId',
  builder: (context, state) {
    CropDiaryBinding().dependencies();

    final farmId = state.pathParameters['farmId']!;
    final cropId = state.pathParameters['cropId']!;

    return AddDiaryEntryView(
      farmId: farmId,
      cropId: cropId,  
    );
  },
),

GoRoute(
  path: '${AppRoutes.diaryEntryDetails}/:farmId/:cropId/:entryId',
  builder: (context, state) {
    CropDiaryBinding().dependencies();

    final farmId = state.pathParameters['farmId']!;
    final cropId = state.pathParameters['cropId']!;
    final entryId = state.pathParameters['entryId']!;

    return DiaryEntryDetailsView(
      farmId: farmId,
      cropId: cropId,
      entryId: entryId,
    );
  },
),

GoRoute(
  path: '${AppRoutes.editDiaryEntry}/:farmId/:cropId/:entryId',
  builder: (context, state) {
    CropDiaryBinding().dependencies();

    final farmId = state.pathParameters['farmId']!;
    final cropId = state.pathParameters['cropId']!;
    final entryId = state.pathParameters['entryId']!;

    return EditDiaryEntryView(
      farmId: farmId,
      cropId: cropId,
      entryId: entryId,
    );
  },
),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return const HomeView();
        },
      ),
    ],
  );
}
