# Plan for Implementing GoRouter and Auth Improvements in quiGestor

This plan covers the complete refactoring of the navigation system and authentication logic in the `quiGestor` project, following the patterns used in `quiPede` and `quiManda`.

## User Review Required

> [!IMPORTANT]
> This refactoring will replace the current `Navigator`-based routing with `GoRouter`. All navigation calls in the app will need to be updated to use the new `NavigationCubit`.

> [!WARNING]
> The `RefreshToken` logic assumes the backend supports persistent refresh tokens (multi-device support).

## Proposed Changes

### Dependencies Layer

#### [MODIFY] [pubspec.yaml](file:///C:/Users/cassi/projetos/quigestor/pubspec.yaml)
- Add `go_router`, `url_strategy`, `flutter_secure_storage`.
- Add `shelf` and `shelf_router` to `dev_dependencies`.
- Update `firebase_core` and `firebase_messaging` versions.

---

### Navigation Component

#### [NEW] [app_router.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/routes/app_router.dart) (Overwrite/Refactor)
- Implement `GoRouter` with `ShellRoute` for nested navigation.
- Define public routes (`/splash`, `/login`) and protected routes (`/dashboard`, `/pedidos`, etc.).

#### [NEW] [MainShell](file:///C:/Users/cassi/projetos/quigestor/lib/app/widgets/main_shell.dart)
- Widget containing the `BottomNavigationBar` and the `child` from `ShellRoute`.

#### [NEW] [NavigationCubit](file:///C:/Users/cassi/projetos/quigestor/lib/app/navigation/navigation_cubit.dart) and [NavigationState](file:///C:/Users/cassi/projetos/quigestor/lib/app/navigation/navigation_state.dart)
- Handle global navigation state and actions.

#### [NEW] [AppRouterListener](file:///C:/Users/cassi/projetos/quigestor/lib/app/navigation/app_router_listener.dart)
- Listen to `NavigationCubit` and trigger `GoRouter` navigation.

---

### Authentication & API Component

#### [NEW] [TokenService](file:///C:/Users/cassi/projetos/quigestor/lib/shared/services/token_service.dart) (Refactor)
- Use `FlutterSecureStorage` for tokens.

#### [MODIFY] [RefreshInterceptor](file:///C:/Users/cassi/projetos/quigestor/lib/shared/api/interceptors/refresh_interceptor.dart) (or lib/shared/api/refresh_interceptor.dart)
- Update logic to handle 401 errors and trigger token refresh.

#### [MODIFY] [AuthCubit](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/auth/bloc/auth_cubit.dart)
- Update to include `refreshToken` and `checkAuthStatus` logic.

#### [NEW] [AppInitializer](file:///C:/Users/cassi/projetos/quigestor/lib/app/initialization/app_initializer.dart)
- Handle initial auth check and show splash screen during loading.

#### [NEW] [SplashScreen](file:///C:/Users/cassi/projetos/quigestor/lib/app/widgets/splash_screen.dart)
- Simple loading screen without `Scaffold` to avoid UI glitches.

---

### Main & Web Support

#### [MODIFY] [main.dart](file:///C:/Users/cassi/projetos/quigestor/lib/main.dart)
- Configure `GoRouter`, `url_strategy`, and global providers.

#### [NEW] [server.dart](file:///C:/Users/cassi/projetos/quigestor/build/web/server.dart)
- SPA server for web production.

---

### Cleanup

#### [MODIFY] Multiple Files
- Replace `Navigator.push`, `Navigator.pop`, etc., with `context.read<NavigationCubit>().push/go/pop`.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no regressions in existing logic (if any).
- Build check: `flutter build apk` and `flutter build web`.

### Manual Verification
- Verify splash to login flow.
- Verify login to dashboard flow.
- Verify tab navigation and URL updates.
- Verify token refresh by manually expiring the access token (or mocking 401).
- Verify deep linking in web build.
