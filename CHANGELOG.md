## [1.0.1] - 2025-02-23

* Updated REAME.md.

## [1.0.0] - 2025-02-23

* Added full multi-platform support (Android, iOS, Web, macOS, Windows, Linux).
* Added pure vector programmatic puzzle styles (`PuzzleStyle.puzzle`, `PuzzleStyle.square`, `PuzzleStyle.circle`) - zero asset dependencies required.
* Added custom `imageProvider` support for background puzzle verification.
* Added puzzle piece stroke customization (`puzzleStrokeColor`, `puzzleStrokeWidth`) and 3D drop shadow.
* Optimized text captcha disturbance lines with smooth Bézier watermark curves (`CaptchaMaskPainter`) and stabilized rendering to prevent jumping on hover/rebuilds.
* Added comprehensive Chinese documentation (`README_ZH.md`) and English/Chinese language toggle links.

## [0.2.0] - 2025-02-23

* Added `SlideVerifyView.show(context)` static helper for showing puzzle captchas in a dialog modal.
* Added customizable strings and localization options to `SlideVerifyView` (`title`, `sliderText`, `successTextBuilder`).
* Added `onSuccess`, `onFail`, and `onClose` callbacks to `SlideVerifyView`.
* Added `onTap` refresh callback to `CaptchaView`.
* Added `excludeSimilar` option to `CaptchaView.generateText` to omit easily confused characters (`0`, `O`, `1`, `I`, `l`).
* Added `customAllowedCharacters` option to `CaptchaView.generateText`.
* Optimized `CaptchaMaskPainter` rendering performance by removing repeated allocations inside `paint()`.
* Updated LICENSE to standard MIT License.
* Added comprehensive English documentation in README.md.

## [0.1.0] - 2026-08-20

* Migrated to Dart 3 and the latest Flutter with sound null safety.
* Replaced the removed `Theme.of(context).accentColor` with `colorScheme.secondary`.
* Replaced `@required` with the `required` keyword.
* Replaced the deprecated `Color.withOpacity` with `Color.withValues`.
* Fixed the asset declarations to match the actual asset paths.
* Replaced the missing `ic_checked.png` asset with a Material icon.
* Moved the implementation files to `lib/src` and added a barrel file.
* Added an `example` app.
* Added unit and widget tests.
* Improved the API documentation.

## [0.0.1] - 2021-01-22

* Initial release.
