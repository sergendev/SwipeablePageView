# SwipeablePageView

SwipeablePageView is a Swift package that provides a flexible, swipeable container view designed to enable users to quickly and intuitively switch between different parts of an app. This component creates a full-screen paging experience—either horizontally or vertically—to let your app’s content flow seamlessly.

## Features

- **Unlimited Pages:** Supports an arbitrary number of pages.
- **Dual Direction Support:** Swipe pages either horizontally or vertically.
- **Smooth Transitions:** Built-in drag gesture handling with animated transitions for an intuitive user experience.
- **Full-Screen Paging:** Optimized for full-screen presentation to help users navigate between major sections of your app.

## Requirements

- **iOS:** 18.0 and up (leverages the new `Group(subviews:)` initializer).
- **Swift:** 6.0 or later.
- **SwiftUI**

## Installation

Add the package via Swift Package Manager. In Xcode:

- Go to **File > Add Package Dependencies...** 
- Copy-paste the repository URL `github.com/sergendev/SwipeablePageView` in the search bar at the top right of the popup.
- Click **Add Package**, and `import SwipablePageView` to use the library's components in your app.

Alternatively, add the following in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sergendev/SwipeablePageView", from: "1.0.0")
]
```

## Usage

To integrate `SwipeablePageView` into your app, simply import SwiftUI and initialize it with a binding for the current page, the desired swipe direction, and the content to display. For example:

```swift
import SwiftUI
import SwipeablePageView

struct ContentView: View {
    @State private var currentPage = 0

    var body: some View {
        SwipeablePageView(currentPage: $currentPage, direction: .horizontal) {
            ForEach(0..<5, id: \.self) { index in
                VStack {
                    Text("Section \(index + 1)")
                        .font(.largeTitle)
                }
            }
        }
    }
}
```

> **Note:** The container should fill the entire screen. Other forms of usage are unsupported.

## Assumptions

- The container is assumed to fill the entire screen, as the intended usage is to enable quick switching between different parts of an app.
- Usage of the view in smaller containers may result in undefined behavior.

## Known Limitations

- **iOS Compatibility:** Only supports iOS 18 and up due to the use of the new `Group(subviews:)` initializer.
- **View Sizing:** Some views—particularly those adapted from UIKit (e.g., `NavigationView`)—may display with incorrect sizing immediately after swiping. The layout corrects itself once the SwiftUI layout engine refreshes.

## Future Improvements

- **Backward Compatibility:** Explore options to support iOS 17 and earlier by providing fallback implementations.
- **Layout Consistency:** Investigate and improve the initial sizing behavior for UIKit-adapted views to ensure consistent layouts immediately after swiping.
- **Customization Options:** Add parameters for customizing animations, shadows, and gesture sensitivities.
- **Enhanced Accessibility:** Incorporate additional accessibility features and modifiers to improve usability.
- **Expanded Testing:** Develop a broader testing suite and documentation to cover more use cases and edge scenarios.

## Contributing

Contributions are welcome! If you encounter issues or have ideas for improvements, please open an issue or submit a pull request.
