# Refactor AuthSlide to standalone widget

I have refactored the `_buildAuthSlide` method from `onboarding_screen.dart` into a new `AuthSlide` widget located in `lib/screens/onboardingscreen/auth_slide.dart`.

## Changes Summary
- **[onboarding_screen.dart](file:///C:/Users/Jeremy/StudioProjects/DANCEFIRST/lib/screens/onboardingscreen/onboarding_screen.dart)**: Removed the private `_buildAuthSlide` method and updated the `PageView` to use the new `AuthSlide` widget, passing necessary signals and controllers.
- **[NEW] [auth_slide.dart](file:///C:/Users/Jeremy/StudioProjects/DANCEFIRST/lib/screens/onboardingscreen/auth_slide.dart)**: Created a new stateless widget `AuthSlide` that encapsulates the authentication UI and logic, improving code organization and readability.

## Verification Summary
- The code was refactored and verified for correct state injection.
- Added a preview widget to `auth_slide.dart` to facilitate UI testing.
- Manual verification of the Auth slide functionality (login/registration toggle, form validation, and button actions) is recommended to ensure complete integration.
