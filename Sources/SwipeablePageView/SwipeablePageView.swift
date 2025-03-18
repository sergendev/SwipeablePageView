//
//  VerticalPageView.swift
//  VerticalScrollContainer
//
//  Created by Asaf Sergen Gönenç on 16.03.2025.
//

import SwiftUI

/// An enumeration that defines the swipe direction for the page view.
public enum SwipeDirection {
    /// Swipe pages left or right.
    case horizontal
    /// Swipe pages up or down.
    case vertical
}

/// A container view that provides a swipeable paging mechanism for its child views.
///
/// `SwipeablePageView` allows you to arrange multiple child views in either a horizontal or vertical
/// stack, enabling smooth swipe transitions between pages. The currently visible page is controlled
/// by a binding to an integer value, while dynamic offsets and visual effects during drag transitions
/// enhance the user experience.
///
/// Example usage:
/// ```swift
/// @State private var currentPage = 0
///
/// var body: some View {
///     SwipeablePageView(currentPage: $currentPage, direction: .horizontal) {
///         ForEach(0..<numberOfPages, id: \.self) { index in
///             Text("Page \(index + 1)")
///         }
///     }
/// }
/// ```
///
public struct SwipeablePageView<Content: View>: View {
    // MARK: - Properties
    /// A binding to the index of the currently visible page.
    @Binding var currentPage: Int
    
    /// The swipe direction: either horizontal or vertical.
    public let direction: SwipeDirection
    
    /// A view builder that produces the paged child views.
    @ViewBuilder var content: Content
    
    /// The current drag translation used to animate page transitions.
    @State private var dragTranslation: CGFloat = 0
    
    /// A computed property indicating if the view is being dragged.
    private var isDragging: Bool { dragTranslation != 0 }
    
    /// Creates a new swipeable page view.
    ///
    /// - Parameters:
    ///   - currentPage: A binding to the index of the current page.
    ///   - direction: The swipe direction, either horizontal or vertical.
    ///   - content: A view builder that produces the paged child views.
    public init(currentPage: Binding<Int>, direction: SwipeDirection, @ViewBuilder content: () -> Content) {
        self._currentPage = currentPage
        self.direction = direction
        self.content = content()
    }
    
    /// The body of the `SwipeablePageView`, laying out the pages and handling drag gestures.
    public var body: some View {
        GeometryReader { fullGeometry in
            let safeAreaInsets = fullGeometry.safeAreaInsets
            Group(subviews: content) { subviews in
                GeometryReader { geometry in
                    // Determine the primary dimension (width or height) based on the swipe direction.
                    let pageDimension = (direction == .vertical) ? geometry.size.height : geometry.size.width
                    ZStack {
                        ForEach(0..<subviews.count, id: \.self) { index in
                            subviews[index]
                                .safeAreaPadding(safeAreaInsets)
                                .background(Color(UIColor.systemBackground))
                                .overlay(overlay(for: index, pageDimension: pageDimension))
                                .contentShape(Rectangle())
                                .shadow(radius: isDragging ? 25 : 0)
                                .clipShape(RoundedRectangle(cornerRadius: isDragging ? 25 : 0))
                            // Apply the computed offset on the appropriate axis.
                                .offset(x: direction == .horizontal ? computedOffset(for: index, pageDimension: pageDimension) : 0,
                                        y: direction == .vertical ? computedOffset(for: index, pageDimension: pageDimension) : 0)
                                .gesture(dragGesture(pageDimension: pageDimension, index: index, total: subviews.count))
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .onChange(of: currentPage) {
                        // Clamp the page index to ensure it stays within valid bounds.
                        currentPage = currentPage.clamped(0, subviews.count - 1)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Computes the offset for a page by combining its base position and the drag translation.
    ///
    /// This method calculates the base offset using the page's index relative to the current page,
    /// and then adjusts it with a drag component to provide a smooth paging effect.
    ///
    /// - Parameters:
    ///   - index: The index of the page.
    ///   - pageDimension: The dimension (height or width) of one page.
    /// - Returns: The computed offset for the page.
    private func computedOffset(for index: Int, pageDimension: CGFloat) -> CGFloat {
        let relativeIndex = CGFloat(index - currentPage)
        let baseOffset = relativeIndex * pageDimension
        
        let dragComponent: CGFloat = {
            if relativeIndex < 0 { return dragTranslation / 3 }
            else if index == currentPage && dragTranslation < 0 { return dragTranslation / 3 }
            else { return dragTranslation }
        }()
        
        return relativeIndex >= 0 ? baseOffset + dragComponent : baseOffset / 3 + dragComponent
    }
    
    /// Creates an overlay view with dynamic opacity based on the drag translation.
    ///
    /// The overlay darkens the current page during drags, providing a visual cue that the page is transitioning.
    ///
    /// - Parameters:
    ///   - index: The index of the page.
    ///   - pageDimension: The dimension (height or width) of one page.
    /// - Returns: A view that overlays a translucent black color.
    private func overlay(for index: Int, pageDimension: CGFloat) -> some View {
        let relativeIndex = CGFloat(index - currentPage)
        let partialRelativeIndex = relativeIndex + (dragTranslation / pageDimension)
        let opacity = partialRelativeIndex < 0 ? Double(-partialRelativeIndex / 2) : 0.0
        return Color.black.opacity(opacity)
    }
    
    /// Creates and returns a drag gesture that handles swipe paging interactions.
    ///
    /// This gesture updates the drag translation during the swipe and, upon ending, calculates the new
    /// page index based on the predicted end translation.
    ///
    /// - Parameters:
    ///   - pageDimension: The dimension (height or width) of one page.
    ///   - index: The index of the page on which the gesture is applied.
    ///   - total: The total number of pages.
    /// - Returns: A drag gesture for handling page transitions.
    private func dragGesture(pageDimension: CGFloat, index: Int, total: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Only the current page should respond to the drag.
                guard index == currentPage else { return }
                // Use the appropriate translation based on direction.
                let translationValue = (direction == .vertical) ? value.translation.height : value.translation.width
                // Prevent dragging beyond the first and last pages.
                if index == 0 && translationValue > 0 { return }
                if index == total - 1 && translationValue < 0 { return }
                dragTranslation = translationValue
            }
            .onEnded { value in
                withAnimation {
                    // Use the appropriate predicted translation based on direction.
                    let predictedTranslation = (direction == .vertical) ? value.predictedEndTranslation.height : value.predictedEndTranslation.width
                    dragTranslation = 0
                    let offset = (predictedTranslation / pageDimension).clamped(-1, 1)
                    let newPage = (CGFloat(currentPage) - offset).rounded()
                    currentPage = min(max(Int(newPage), 0), total - 1)
                }
            }
    }
}
