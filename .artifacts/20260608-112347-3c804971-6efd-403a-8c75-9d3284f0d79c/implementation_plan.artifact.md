# Refactor AuthSlide to separate widget

Refactor `_buildAuthSlide` from `onboarding_screen.dart` into a standalone widget `AuthSlide` in `lib/screens/onboardingscreen/auth_slide.dart`.

## User Review Required

- None.

## Proposed Changes

### lib/screens/onboardingscreen

#### [onboarding_screen.dart](file:///C:/Users/Jeremy/StudioProjects/DANCEFIRST/lib/screens/onboardingscreen/onboarding_screen.dart)
- Remove `_buildAuthSlide` method.
- Update `PageView` to use the new `AuthSlide` widget.
- Pass required signals and controllers to `AuthSlide`.

#### [NEW] [auth_slide.dart](file:///C:/Users/Jeremy/StudioProjects/DANCEFIRST/lib/screens/onboardingscreen/auth_slide.dart)
- Create `AuthSlide` `StatelessWidget`.
- Move the UI and logic from `_buildAuthSlide` here.

## Verification Plan

### Manual Verification
- Run the app, navigate to the Auth slide.
- Verify that login/registration toggling works correctly.
- Verify that text fields and buttons (Inloggen, Registreren, Wachtwoord vergeten) work as expected.
- Verify that the loading state is handled correctly.
