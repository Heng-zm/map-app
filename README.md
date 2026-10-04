# Map Viewer (iOS) — Production Map Application

[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0%2B-indigo.svg)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/SwiftData-Supported-green.svg)](https://developer.apple.com/documentation/swiftdata)
[![MapKit](https://img.shields.io/badge/MapKit-Native-red.svg)](https://developer.apple.com/documentation/mapkit)
[![CoreLocation](https://img.shields.io/badge/CoreLocation-Native-purple.svg)](https://developer.apple.com/documentation/corelocation)

A complete, production-ready iOS application built strictly with Apple native frameworks: **Swift**, **SwiftUI**, **MapKit**, **Core Location**, **SwiftData**, **Observation**, and **Swift Concurrency**.

Designed for both **iPhone** and **iPad** (with native `NavigationSplitView`), supporting **Portrait**, **Landscape**, **Light Mode**, **Dark Mode**, **Dynamic Type**, **VoiceOver**, and **Accessibility**.

---

## Table of Contents

1. [Features Overview](#features-overview)
2. [Technical Specifications & Requirements](#technical-specifications--requirements)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Directory & Project Organization](#directory--project-organization)
5. [Getting Started (Opening & Building)](#getting-started-opening--building)
6. [Running on Simulator](#running-on-simulator)
7. [Running on a Physical Device](#running-on-a-physical-device)
8. [Location Permissions & Privacy Setup](#location-permissions--privacy-setup)
9. [Automated Testing Suite (Unit, Integration, UI)](#automated-testing-suite)
10. [Geodesic Algorithms & Math](#geodesic-algorithms--math)
11. [Known MapKit Limitations](#known-mapkit-limitations)
12. [App Store Distribution Checklist](#app-store-distribution-checklist)
13. [GitHub Actions CI/CD & Automated IPA Build](#github-actions-cicd--automated-ipa-build)

---

## 1. Features Overview

### Full-Screen Interactive Map
- **Map Styles**: Standard, Satellite Imagery, and Hybrid with real-time toggle.
- **Perspective**: 2D Flat vs. 3D Realistic Terrain with 3D buildings and pitch.
- **Layers**: Live real-time traffic conditions, points of interest filtering, compass, and scale view.
- **User Location & Tracking**: Follow User mode, high-accuracy single fix, heading updates, and battery-conscious distance filters.
- **Camera Controls**: Fluid programmatic zoom in/out, re-center on GPS coordinate, spring animations.

### Real Search & Autocomplete
- Powered by `MKLocalSearchCompleter` and `MKLocalSearch`.
- Sub-second debounced autocomplete suggestions for cities, addresses, businesses, and landmarks.
- Nearby Category Search: Instant access to Restaurants, Coffee, Gas Stations, Groceries, Hospitals, Parks, and Hotels.
- Result Details: Place name, formatted address, category badge, phone number (tappable call), website URL (Safari link), coordinates, and distance from user.

### Search History Persistence
- Stored on-device via **SwiftData**.
- Deduplication of identical queries, recency sorting, individual item deletion, and single-tap history clearing.

### Saved Locations & Bookmarks
- SwiftData entity `@Model final class SavedLocation` storing UUID, name, custom notes, coordinates, address, category, and favorite status.
- Category filtering (`All`, `Personal`, `Work`, `Landmark`, custom categories).
- Multi-criteria sorting: Date Added, Name (A-Z), Distance from user.
- Swipe actions: Swipe to favorite, swipe to delete, swipe to edit.

### Custom Pins (Long Press Map)
- Long press anywhere on the map to trigger native `MapReader` coordinate conversion.
- Automatic asynchronous reverse-geocoding via `CLGeocoder`.
- Color customization (palette of 8 distinct tones), custom name, notes, and favorite toggle.
- Persisted locally across app terminations and relaunches.

### Route Planning & Directions
- Real route calculations via Apple's `MKDirections`.
- Supports **Driving**, **Walking**, and **Transit**.
- Route alternatives selection with travel duration, distance, and advisory notices.
- Full turn-by-turn navigation steps inspection.
- Swap origin and destination with a single tap.
- Live floating route overview card with one-tap clear action.

### Map Measurement Tool (Distance & Area)
- Interactive waypoints placed directly on the geographic canvas.
- **Distance Path Mode**: Great-circle geodesic distance calculation across multi-point routes ($A \rightarrow B \rightarrow C$), plus individual segment breakdowns.
- **Polygon Area Mode**: Geodesic spherical polygon area calculation using the Chamberlain-Duquette algorithm ($m^2$, $km^2$, $ft^2$, acres) and perimeter calculation.
- Waypoint undo, clear all, and interactive metric/imperial unit formatting.

### Coordinates & Units
- **Formats**: Decimal Degrees (`DD`: `37.774929° N, 122.419416° W`) and Degrees Minutes Seconds (`DMS`: `37° 46' 29.74" N, 122° 25' 09.90" W`).
- Floating center-coordinate badge with single-tap clipboard copy and haptic confirmation.
- One-tap "Open in Apple Maps" and share sheet integration.

### Adaptive iPad Interface
- `NavigationSplitView` architecture on iPad:
  - Sidebar: Quick access to Map Explorer, Search, Saved Places, Directions, Measurement, and Settings.
  - Detail: Unobstructed high-performance MapKit canvas.

---

## 2. Technical Specifications & Requirements

| Property | Requirement |
|---|---|
| **Language** | Swift 5.9+ / Swift 6 compatible |
| **Minimum iOS Target** | iOS 17.0 |
| **Supported Devices** | iPhone, iPad |
| **Supported Orientations** | Portrait, Landscape Left, Landscape Right |
| **Frameworks** | SwiftUI, MapKit, Core Location, SwiftData, Observation, XCTest, XCUITest |
| **Third-Party Dependencies** | None (Zero 3rd-party dependencies) |
| **Xcode Version** | Xcode 15.0 or later (Recommended: Xcode 15.4 / 16.0+) |
| **macOS Host** | macOS Sonoma 14.0+ or macOS Sequoia 15.0+ |

---

## 3. Architecture & Design Patterns

The project follows a strict **MVVM + Service Layer + Repository Layer + Dependency Injection** architecture:

```
┌────────────────────────────────────────────────────────┐
│                      SwiftUI Views                     │
│  MainMapView, SearchSheetView, SavedLocationsListView  │
└───────────────────────────▲────────────────────────────┘
                            │ Observation (@Observable)
┌───────────────────────────┴────────────────────────────┐
│                       ViewModels                       │
│  MapViewModel, SearchViewModel, RouteViewModel, etc.   │
└───────────────────────────▲────────────────────────────┘
                            │ Async/Await / Protocols
┌───────────────────────────┴────────────────────────────┐
│                     Service Layer                      │
│ LocationService, SearchService, GeocodingService, etc. │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────┴────────────────────────────┐
│                    Repository Layer                    │
│   SwiftDataSavedLocationRepo, UserDefaultsSettingsRepo │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────┴────────────────────────────┐
│                   Storage / OS Layer                   │
│   SwiftData ModelContainer, Core Location, MapKit API  │
└────────────────────────────────────────────────────────┘
```

- **Dependency Injection**: Orchestrated via `AppDependencies` and `AppEnvironment`. ViewModels receive protocols, making them 100% unit-testable without live GPS hardware or network calls.
- **Observation Framework**: All ViewModels utilize `@Observable` and `@MainActor` (modern iOS 17 baseline), eliminating legacy Combine boilerplate and preventing UI thread synchronization issues.
- **Structured Concurrency**: Clean async/await pipelines with explicit `Task.checkCancellation()` checks, debounced search streams, and no arbitrary `Task.sleep` workarounds.

---

## 4. Directory & Project Organization

```
map-app/
├── MapViewer.xcodeproj/
│   └── project.pbxproj               # Complete native Xcode project file
├── Package.swift                     # Swift Package Manager manifest
├── README.md                         # Product documentation
│
└── MapViewer/
    ├── App/
    │   ├── MapViewerApp.swift        # App entry point (@main)
    │   ├── AppEnvironment.swift      # Bootstraps SwiftData container & services
    │   └── AppDependencies.swift     # Dependency injection container
    │
    ├── Core/
    │   ├── Models/
    │   │   ├── CoordinateFormat.swift
    │   │   ├── UnitSystem.swift
    │   │   ├── MapStyleOption.swift
    │   │   ├── TransportationMode.swift
    │   │   ├── LocationPin.swift
    │   │   ├── RouteInfo.swift
    │   │   ├── MeasurementItem.swift
    │   │   └── PlaceSearchResult.swift
    │   ├── Services/
    │   │   ├── LocationService.swift
    │   │   ├── SearchService.swift
    │   │   ├── GeocodingService.swift
    │   │   ├── RoutingService.swift
    │   │   └── MeasurementService.swift
    │   ├── Repositories/
    │   │   ├── SavedLocationRepository.swift
    │   │   ├── SearchHistoryRepository.swift
    │   │   └── SettingsRepository.swift
    │   ├── Errors/
    │   │   └── MapViewerError.swift
    │   ├── Extensions/
    │   │   ├── CLLocationCoordinate2D+Extensions.swift
    │   │   ├── MKCoordinateRegion+Extensions.swift
    │   │   ├── Double+Formatting.swift
    │   │   └── View+Extensions.swift
    │   └── Utilities/
    │       ├── CoordinateFormatter.swift
    │       ├── UnitFormatter.swift
    │       └── GeodesicCalculator.swift
    │
    ├── Features/
    │   ├── Map/
    │   │   ├── Views/
    │   │   │   ├── MainMapView.swift
    │   │   │   └── AdaptiveRootView.swift
    │   │   ├── ViewModels/
    │   │   │   └── MapViewModel.swift
    │   │   └── Components/
    │   │       ├── FloatingMapControls.swift
    │   │       ├── MapStylePickerSheet.swift
    │   │       ├── CoordinateDisplayBadge.swift
    │   │       └── CustomPinAnnotationView.swift
    │   ├── Search/
    │   │   ├── Views/
    │   │   │   ├── SearchSheetView.swift
    │   │   │   ├── SearchResultsListView.swift
    │   │   │   └── PlaceDetailSheetView.swift
    │   │   ├── ViewModels/
    │   │   │   └── SearchViewModel.swift
    │   │   └── Components/
    │   │       ├── SearchBarField.swift
    │   │       ├── CategoryChipsView.swift
    │   │       └── SearchHistoryView.swift
    │   ├── Locations/
    │   │   ├── Views/
    │   │   │   ├── SavedLocationsListView.swift
    │   │   │   ├── LocationDetailEditView.swift
    │   │   │   └── PinEditSheetView.swift
    │   │   ├── ViewModels/
    │   │   │   └── SavedLocationsViewModel.swift
    │   │   └── Components/
    │   │       ├── LocationCardRow.swift
    │   │       └── CategoryFilterBar.swift
    │   ├── Routes/
    │   │   ├── Views/
    │   │   │   ├── RoutePlanningSheetView.swift
    │   │   │   ├── RouteStepDetailView.swift
    │   │   │   └── RouteOverviewCard.swift
    │   │   ├── ViewModels/
    │   │   │   └── RouteViewModel.swift
    │   │   └── Components/
    │   │       └── TransportModePicker.swift
    │   ├── Measurement/
    │   │   ├── Views/
    │   │   │   └── MeasurementSummaryCard.swift
    │   │   ├── ViewModels/
    │   │   │   └── MeasurementViewModel.swift
    │   │   └── Components/
    │   │       └── MeasurementControlBar.swift
    │   └── Settings/
    │       ├── Views/
    │       │   ├── SettingsView.swift
    │       │   ├── AboutAppView.swift
    │       │   └── PrivacyInfoView.swift
    │       ├── ViewModels/
    │       │   └── SettingsViewModel.swift
    │       └── Components/
    │           └── SettingsRowView.swift
    │
    ├── Persistence/
    │   ├── Models/
    │   │   ├── SavedLocation.swift
    │   │   ├── SearchHistoryItem.swift
    │   │   └── CustomPin.swift
    │   └── Repositories/
    │       ├── SwiftDataSavedLocationRepository.swift
    │       └── SwiftDataSearchHistoryRepository.swift
    │
    └── Resources/
        ├── Info.plist
        ├── MapViewer.entitlements
        └── Assets.xcassets/
            ├── AccentColor.colorset/
            └── AppIcon.appiconset/

MapViewerTests/
├── UnitTests/
│   ├── CoordinateFormatterTests.swift
│   ├── UnitFormatterTests.swift
│   ├── GeodesicMathTests.swift
│   └── SettingsRepositoryTests.swift
└── IntegrationTests/
    ├── SwiftDataPersistenceIntegrationTests.swift
    └── AppWorkflowIntegrationTests.swift

MapViewerUITests/
├── MapViewerUITests.swift
└── MapViewerUITestsLaunchTests.swift
```

---

## 5. Getting Started (Opening & Building)

### Using Xcode (Recommended)
1. Clone or copy the repository to your Mac.
2. Double-click `MapViewer.xcodeproj` to launch Xcode.
3. Select the `MapViewer` scheme and your desired target device (iPhone 15/16 Simulator or connected hardware).
4. Press `Cmd + B` to build, or `Cmd + R` to run.

### Using Command Line (`xcodebuild`)
To compile the Debug build from Terminal:
```bash
xcodebuild -project MapViewer.xcodeproj \
           -scheme MapViewer \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
           build
```

---

## 6. Running on Simulator

1. In Xcode, choose any **iOS 17+ Simulator** (e.g. iPhone 15 Pro, iPad Air 11-inch).
2. Press `Cmd + R`.
3. In Simulator Menu, configure simulated location:
   - **Features > Location > Apple**: Simulates 1 Apple Park Way, Cupertino.
   - **Features > Location > City Run / Freeway Drive**: Simulates dynamic movement for heading/speed testing.

---

## 7. Running on a Physical Device

1. Connect your iPhone or iPad via USB-C or Lightning.
2. In Xcode, navigate to `MapViewer` target > **Signing & Capabilities**.
3. Select your **Apple Developer Team** under "Signing Certificate".
4. Ensure the Bundle Identifier is unique (e.g. `com.yourname.MapViewer`).
5. Select your physical device in the device dropdown and press `Cmd + R`.
6. On your iOS device, go to **Settings > General > VPN & Device Management** and trust your Developer profile if prompted.

---

## 8. Location Permissions & Privacy Setup

The app requires standard When-in-Use location access. The following description is included in `MapViewer/Resources/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Map Viewer requires access to your location to display your position on the map, calculate turn-by-turn directions, and measure geographic distances.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Map Viewer requires access to your location to display your position on the map, calculate turn-by-turn directions, and measure geographic distances.</string>
```

### Privacy Guarantees
- Zero third-party trackers, telemetry, or advertising SDKs.
- GPS coordinates are processed exclusively on-device.
- SwiftData stores saved locations and searches in local SQLite sandboxes.

---

## 9. Automated Testing Suite

### Running Unit & Integration Tests
Execute in Xcode using `Cmd + U` or via terminal:
```bash
xcodebuild test \
           -project MapViewer.xcodeproj \
           -scheme MapViewer \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest'
```

### Test Coverage Highlights
- **`CoordinateFormatterTests`**: Verifies Decimal Degrees formatting with custom precision, Degrees Minutes Seconds conversion, negative cardinal indicators (S/W), and Apple Maps URL formation.
- **`UnitFormatterTests`**: Tests threshold transitions ($< 1000\text{ m} \rightarrow \text{m}$, $\ge 1000\text{ m} \rightarrow \text{km}$, $\text{ft} \rightarrow \text{mi}$, $m^2 \rightarrow \text{ha} \rightarrow km^2$, $\text{sq ft} \rightarrow \text{acres}$).
- **`GeodesicMathTests`**: Validates the great-circle Haversine formula against known city benchmarks (SF to NYC), polyline summation, and spherical polygon areas.
- **`SettingsRepositoryTests`**: Tests persistent UserDefaults reads/writes across distinct repository instances.
- **`SwiftDataPersistenceIntegrationTests`**: Runs on an in-memory SwiftData container to verify CRUD operations, entity updates, and history deduplication.
- **`AppWorkflowIntegrationTests`**: Tests multi-step workflows (pin drop $\rightarrow$ reverse geocode $\rightarrow$ save $\rightarrow$ retrieve).
- **`MapViewerUITests`**: Automates full UI interaction, verifying search sheet invocation, settings modal presentation, and map control responsiveness.

---

## 10. Geodesic Algorithms & Math

### Great-Circle Distance (Haversine Formula)
Used for accurate geographic distance between points:
$$\Delta\phi = \phi_2 - \phi_1, \quad \Delta\lambda = \lambda_2 - \lambda_1$$
$$a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta\lambda}{2}\right)$$
$$c = 2 \cdot \operatorname{atan2}\left(\sqrt{a}, \sqrt{1-a}\right), \quad d = R \cdot c$$
Where $R = 6,371,008.8\text{ meters}$ (WGS-84 mean authalic radius).

### Spherical Polygon Area (Chamberlain-Duquette Algorithm)
Used for measuring arbitrary polygon surface areas on the Earth's sphere:
$$A = \frac{R^2}{2} \cdot \left| \sum_{i=0}^{n-1} (\lambda_{i+1} - \lambda_i) \cdot (2 + \sin \phi_i + \sin \phi_{i+1}) \right|$$
Normalizing longitude differences $\Delta\lambda$ to $[-\pi, \pi]$ ensures correct measurement across the anti-meridian.

---

## 11. Known MapKit Limitations

1. **Transit Directions**: Apple's `MKDirections` provides transit routes only in regions where municipal transit agencies provide GTFS feeds to Apple Maps. If transit is unavailable, `MapViewer` displays a clean localized error suggesting Driving or Walking.
2. **Offline Caching**: MapKit tile caching is managed directly by the operating system. Manual offline tile downloads for third-party raster servers are not part of Apple's public MapKit API.
3. **Geocoding Rate Limits**: `CLGeocoder` enforces client-side rate limits. `MapViewer` mitigates this with an in-memory cache keyed to 4 decimal places (~11 meters) to prevent duplicate lookups.

---

## 12. App Store Distribution Checklist

Before submitting to App Store Connect:
1. **App Icons**: Replace placeholder template images in `Assets.xcassets/AppIcon.appiconset` with your 1024x1024 App Store icon.
2. **Bundle Identifier**: Update `PRODUCT_BUNDLE_IDENTIFIER` in Build Settings to match your registered App ID.
3. **Provisioning Profile**: In Xcode Signing & Capabilities, select your team distribution certificate.
4. **App Privacy Questions**: Under App Store Connect, report that Location is used for "App Functionality" and is **not linked to user identity**.
5. **Archive**: In Xcode menu, choose **Product > Archive**, validate your archive, and upload to App Store Connect.

---


---

## 13. GitHub Actions CI/CD & Automated IPA Build

This repository is equipped with an automated, production-grade GitHub Actions CI/CD pipeline that compiles, tests, archives, and packages the application into a signed or distributable `MapViewer.ipa` artifact.

### Pipeline Flow

```
GitHub Repository (Push / PR / Manual / Tag)
       ↓
GitHub Actions (macOS 14 Runner - Apple Silicon M2)
       ↓
Checkout Source Code (actions/checkout@v4)
       ↓
Select & Verify Xcode (Xcode 15.4 / 16.0+)
       ↓
Resolve Swift Package Dependencies (xcodebuild -resolvePackageDependencies)
       ↓
Run Automated Unit & Integration Tests (iOS Simulator)
       ↓
Configure Ephemeral Keychain & Import Certificates (scripts/setup-signing.sh)
       ↓
Clean & Create Device Archive (xcodebuild archive generic/platform=iOS)
       ↓
Export IPA with ExportOptions.plist (xcodebuild -exportArchive)
       ↓
Verify IPA Structure (unzip -l Payload/MapViewer.app)
       ↓
Upload MapViewer.ipa Artifact (actions/upload-artifact@v4)
       ↓
Secure Cleanup (Tears down ephemeral keychain & profiles)
```

### Configured Workflows

1. **`ios-build.yml` (`.github/workflows/ios-build.yml`)**:
   - Primary build pipeline triggered on `push` to `main`/`develop`, pull requests, and manual triggers (`workflow_dispatch`).
   - Runs tests on an iPhone simulator, creates the device archive, exports `MapViewer.ipa`, and uploads it as the `MapViewer-IPA` artifact.
2. **`ios-ci.yml` (`.github/workflows/ios-ci.yml`)**:
   - Fast PR verification running unit and integration test suites on an iOS Simulator.
3. **`ios-release.yml` (`.github/workflows/ios-release.yml`)**:
   - Triggered on Git tags (`v*`). Builds a production App Store / Ad-Hoc archive, exports the `.ipa`, uploads the artifact, and automatically publishes a GitHub Release with the attached binary.

---

### Required GitHub Secrets for Code Signing

To produce an Apple-signed IPA for physical device installation or App Store submission, configure the following secrets in your repository settings (**Settings > Secrets and variables > Actions**):

| Secret Name | Description | Example / Notes |
|---|---|---|
| `BUILD_CERTIFICATE_BASE64` | Base64-encoded Apple Distribution or Apple Development certificate (`.p12`) | Generated from Keychain Access on macOS |
| `P12_PASSWORD` | Password protecting the exported `.p12` certificate file | Strong passphrase |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded Apple Provisioning Profile (`.mobileprovision`) | Downloaded from Apple Developer Portal |
| `KEYCHAIN_PASSWORD` | Ephemeral password for the temporary keychain generated on the runner | Any random secure string |
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID | e.g. `ABC1234567` |

#### How to Generate Base64 Secrets on macOS

```bash
# 1. Base64-encode your certificate (.p12)
base64 -i YourDistributionCertificate.p12 -o cert_base64.txt
cat cert_base64.txt | pbcopy
# Paste directly into GitHub Secret: BUILD_CERTIFICATE_BASE64

# 2. Base64-encode your provisioning profile (.mobileprovision)
base64 -i YourApp_AdHoc.mobileprovision -o profile_base64.txt
cat profile_base64.txt | pbcopy
# Paste directly into GitHub Secret: PROVISIONING_PROFILE_BASE64
```

> [!NOTE]
> **No Secrets Configured?**
> If you run the pipeline before adding signing secrets, the workflow will automatically run all simulator unit/integration tests and create a development/device container `.ipa` for structure inspection, clearly noting in the logs that code signing secrets need to be added for distribution.

---

### How to Manually Trigger an IPA Build

1. Open your repository on GitHub.
2. Click the **Actions** tab.
3. In the left sidebar, click **iOS Build & Export IPA**.
4. Click **Run workflow** dropdown on the right:
   - Select branch (e.g. `main`).
   - Select Export Method: `ad-hoc`, `development`, or `app-store`.
   - Select Configuration: `Release` or `Debug`.
   - Check or uncheck **Run automated tests before archiving**.
5. Click **Run workflow**.

---

### Where to Download the Built IPA

1. Navigate to **Actions** > Select the completed workflow run.
2. Scroll to the **Artifacts** section at the bottom of the summary page.
3. Click **`MapViewer-IPA`** to download `MapViewer.zip`.
4. Extract the zip to obtain **`MapViewer.ipa`**.

---

### How to Install the IPA on Real Hardware

- **Using Apple Configurator (macOS)**: Connect your iPhone/iPad via USB, open Apple Configurator, select your device, and drag `MapViewer.ipa` onto it.
- **Using Xcode Devices & Simulators**: Open Xcode (`Cmd + Shift + 2`), select your connected iPhone, and drag `MapViewer.ipa` into the **Installed Apps** section.
- **Over-The-Air (OTA) Distribution**: Upload `MapViewer.ipa` to TestFlight (for `app-store` builds) or services like Diawi or Firebase App Distribution (for `ad-hoc` builds).

---

### Running the Local Build Script on macOS

You can also build the archive and export the IPA locally on your Mac:

```bash
chmod +x scripts/build-ipa.sh
./scripts/build-ipa.sh
```

---

## License

Copyright © 2026. Built with modern Swift and SwiftUI. Distributed under the MIT License.

