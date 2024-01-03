//
//  WrappingHStack.swift
//  Movie DB
//
//  Created by Jonas Frey on 19.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

// TODO: Add alignment (leading, center, trailing, block)
struct WrappingHStack: Layout {
    enum ContentAlignment: CaseIterable {
        case leading
        case trailing
        case center
        case stretched
    }
    
    let alignment: ContentAlignment
    let horizontalSpacing: CGFloat?
    let verticalSpacing: CGFloat?
    
    init(alignment: ContentAlignment = .leading, horizontalSpacing: CGFloat? = nil, verticalSpacing: CGFloat? = nil) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // We have been proposed a view size. Now we need to find out the preferred sizes of all subviews
        let subviewSizes = subviewSizes(for: subviews)
        let horizontalSpacings = self.horizontalSpacings(subviews: subviews)
        let rows = self.rows(for: subviewSizes, proposal: proposal, horizontalSpacings: horizontalSpacings)
        let verticalSpacings = self.verticalSpacings(subviews: subviews, rows: rows)
        
        // Take the widest row
        let maxRowWidth = rows.map { row in
            // Calculate row width
            row.map { index -> CGFloat in
                let isLastItemInRow = (index >= row.count - 1)
                let spacing = isLastItemInRow ? 0 : horizontalSpacings[index]
                return subviewSizes[index].width + spacing
            }
            .reduce(0, +)
        }
            .max() ?? 0
        
        // Sum up the tallest element in each row
        // swiftlint:disable:next multiline_function_chains
        let height = rows.enumerated().map { rowIndex, row in
            // Calculate row height
            row.map { index in
                subviewSizes[index].height + verticalSpacings[rowIndex]
            }
            .max() ?? 0
        }
            .reduce(0, +)
        
        return .init(width: maxRowWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Get the distribution of the views
        let subviewSizes = subviewSizes(for: subviews)
        let horizontalSpacings = self.horizontalSpacings(subviews: subviews)
        let rows = self.rows(for: subviewSizes, proposal: proposal, horizontalSpacings: horizontalSpacings)
        let verticalSpacings = self.verticalSpacings(subviews: subviews, rows: rows)
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var currentPoint: CGPoint {
            CGPoint(x: bounds.origin.x + xOffset, y: bounds.origin.y + yOffset)
        }
        
        // Place the subviews at the calculated positions
        for (i, row) in rows.enumerated() {
            let rowWidth = row
                .enumerated()
                .map { i, index -> CGFloat in
                    // i is the index in the current row
                    // index is the index of the subview
                    guard i < row.count - 1 else {
                        return subviewSizes[index].width
                    }
                    return subviewSizes[index].width + horizontalSpacings[index]
                }
                .reduce(0, +)
            
            // An extra horizontal spacing that is added between all items
            let extraSpacing: CGFloat = {
                switch alignment {
                case .leading, .trailing, .center:
                    // Normal spacing
                    return 0
                case .stretched:
                    // Spacing stretches to fill container (row is always full width)
                    return (bounds.width - rowWidth) / CGFloat(row.count)
                }
            }()
            
            // Add the extra spacing to the width when calculating the alignment offset
            let alignmentOffset = alignmentOffset(
                rowWidth: rowWidth + extraSpacing * CGFloat(row.count),
                in: bounds,
                with: alignment
            )
            
            // Start at the calculated alignment offset
            xOffset = alignmentOffset
            for index in row {
                let subview = subviews[index]
                subview.place(at: currentPoint, anchor: .topLeading, proposal: proposal)
                xOffset += subviewSizes[index].width + horizontalSpacings[index] + extraSpacing
            }
            // Add the height of the tallest object to the yOffset
            yOffset += row.map { subviewSizes[$0].height }
                .max() ?? 0
            yOffset += verticalSpacings[i]
        }
    }
    
    /// Calculates the x offset that is required to place a row with the given width using the given content alignment
    /// - Returns: The calculated x offset
    private func alignmentOffset(rowWidth: CGFloat, in bounds: CGRect, with alignment: ContentAlignment) -> CGFloat {
        switch alignment {
        case .leading:
            return 0
        case .trailing:
            return bounds.width - rowWidth
        case .center:
            return (bounds.width - rowWidth) / 2
        case .stretched:
            return 0
        }
    }
    
    /// Asks the subviews for their size
    private func subviewSizes(for subviews: Subviews) -> [CGSize] {
        subviews.map { subview in
            // Ask for the ideal view size
            subview.sizeThatFits(.unspecified)
        }
    }
    
    /// Calculates the horizontal spacings between the subviews
    /// - Returns:The horzontal spacings between the different subviews
    private func horizontalSpacings(subviews: Subviews) -> [CGFloat] {
        // If we have a fixed spacing, return it
        if let horizontalSpacing {
            return [CGFloat](repeating: horizontalSpacing, count: subviews.count)
        }
        return subviews.indices.map { index in
            // The very last item gets a spacing of 0
            guard index < subviews.count - 1 else {
                return 0
            }
            return subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal)
        }
    }
    
    /// Calculates the vertical spacings between the subviews
    /// - Returns:The vertical spacings between the different rows
    private func verticalSpacings(subviews: Subviews, rows: [[Int]]) -> [CGFloat] {
        // If we have a fixed spacing, return it
        if let verticalSpacing {
            return [CGFloat](repeating: verticalSpacing, count: rows.count)
        }
        
        func spacing(from subview: Subviews.Element, to others: [Subviews.Element]) -> CGFloat {
            others.map { otherSubview in
                subview.spacing.distance(to: otherSubview.spacing, along: .vertical)
            }
            // We take the biggest spacing requested
            .max() ?? 0
        }
        
        func spacing(from subviews: [Subviews.Element], to others: [Subviews.Element]) -> CGFloat {
            subviews.map { subview in
                spacing(from: subview, to: others)
            }
            // We take the biggest spacing requested
            .max() ?? 0
        }
        
        let rows = rows.map { row in
            row.map { index in
                subviews[index]
            }
        }
        
        return rows.indices.map { rowIndex in
            // The last row gets spacing 0
            guard rowIndex < rows.count - 1 else {
                return 0
            }
            let row = rows[rowIndex]
            let nextRow = rows[rowIndex + 1]
            return spacing(from: row, to: nextRow)
        }
    }
    
    /// Calculates how many views are to be fit in each row for the layout to not overflow horizontally
    /// - Returns: A two-dimensional array of indices that represent the subviews and their position in the rows
    private func rows(
        for subviewSizes: [CGSize],
        proposal: ProposedViewSize,
        horizontalSpacings: [CGFloat]
    ) -> [[Int]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[Int]] = []
        
        // The number of items in the current row
        var currentRow: [Int] = []
        // The total width of the current row
        var currentWidth: CGFloat = 0
        
        /// Commits the current row and creates a new one
        func lineBreak() {
            rows.append(currentRow)
            currentRow = []
            currentWidth = 0
        }
        
        /// Adds the given size to the current row
        func add(_ index: Int) {
            currentRow.append(index)
            currentWidth += subviewSizes[index].width + horizontalSpacings[index]
        }
        
        for (i, size) in subviewSizes.enumerated() {
            // If adding the new view would overflow the maxWidth, create a new row
            if currentWidth + size.width > maxWidth, !currentRow.isEmpty {
                lineBreak()
            }
            add(i)
        }
        lineBreak()
        
        assert(rows.map(\.count).reduce(0, +) == subviewSizes.count, "Row calculation has missed some subviews")
        return rows
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach(WrappingHStack.ContentAlignment.allCases, id: \.self) { alignment in
            Text(String(describing: alignment).capitalized)
            WrappingHStack(alignment: alignment) {
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
                CapsuleLabelView(text: "Watchlist")
            }
            Spacer()
        }
    }
}
