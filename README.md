# Core

![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![Platform](https://img.shields.io/badge/platform-iOS%2013%2B-lightgrey)
![License](https://img.shields.io/badge/License-MIT-blue)

The UIKit components and extensions I reach for on every iOS project, collected into one
framework so I stop rewriting them. Input fields that validate and mask, a configurable image
cropper, a video asset timeline, paginated and self-sizing collection views, and the Foundation
and UIKit extensions that hold them together.

<!-- TODO: component gallery. A grid of screenshots or short GIFs captured from the Playground
     app: the button variants, the InputField family in each validation and focus state,
     ImageCropper, AssetTimelineView, PageSelector. This is the first thing anyone sees and
     the single highest-value addition to this file. -->

## What's inside

### Views

The input field family is the core of it. `InputField`, `InputTextField`, `InputTextView` and
`InsetTextField` share one validation and presentation model, so a field can carry a
placeholder, a focus style, an error state and a secure-entry mask without every screen
reimplementing them.

Beyond those: `ImageCropper` for interactive crop and scale, `AssetTimelineView` for scrubbing
video compositions, `PaginatedTableView` for pages loaded on demand, `IntrinsicTableView` and
`IntrinsicCollectionView` for scroll views that size to their content inside a stack view, and
`PageSelector`, `CameraPreview`, `ActivityButton`, `GradientButton`, `CaptureButton` and
`ClearButton`.

### Utilities

`Keychain` wraps secure storage. `Storage` is a `Codable`-backed `@propertyWrapper` over
`UserDefaults`, so a persisted setting is one annotation. `Validator` and its implementations
cover email, name, city, zip code, no-spaces, not-empty, regular expressions, and street
addresses in both German and US formats. Also `LocationManager`, `Log`, `Observers`,
`Vibration`, `Gradient`, a `Camera` capture wrapper, and a small video framework of
`Composition`, `Asset`, `Layer` and `TrackItem` built over VFCabbage.

### Extensions and view controllers

Around sixty extensions across Foundation and UIKit, plus view controllers including a
configurable `ActionSheetViewController`.

## Design notes

**Public by intent, not by default.** The framework exposes a deliberately narrow surface.
Anything `public` is something I wanted to depend on from an app; everything else stays
internal, which keeps the API small enough to hold in your head.

**Composition over configuration.** The input field family shares behaviour by composing small
pieces, validators and focus styles among them, rather than growing one class with a long
initialiser. Adding a validation rule means conforming to `Validator`, not editing a field.

**Extensions carry the boilerplate.** The awkward parts of UIKit, corner masking and layout
constants among them, are pushed into extensions so component code reads as intent.

## Testing

The `Playground` project has a test target, currently holding only the template stubs.
Snapshot coverage of the component matrix is the obvious next step and is not done yet.

## Installation

Swift Package Manager. Add to `Package.swift`:

```swift
.package(url: "https://github.com/joeypatino/core.git", from: "1.0.0")
```

Or in Xcode: File > Add Package Dependencies, then paste the URL.

Core depends on [joeypatino/Cabbage](https://github.com/joeypatino/Cabbage), a fork of
VideoFlint/Cabbage kept because upstream has been dormant since 2022 and its published release
is missing fixes the video components rely on. SPM resolves it automatically.

## Example

The `Playground` app renders the components in their states. Open `Playground/Core.xcodeproj`
and run; SPM resolves everything.

## Requirements

- iOS 13.0+
- Swift 5.0+

## License

MIT. See [LICENSE](LICENSE).

Joey Patino - joey.patino@pm.me
