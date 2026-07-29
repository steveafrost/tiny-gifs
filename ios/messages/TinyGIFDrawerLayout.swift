import UIKit

enum TinyGIFDrawerLayout {
    static let visibleRows: CGFloat = 1.5
    static let columnCount: CGFloat = 3
    static let lineSpacing: CGFloat = 10
    static let interitemSpacing: CGFloat = 8
    static let sectionInsets = UIEdgeInsets(top: 4, left: 10, bottom: 10, right: 10)

    static func itemSize(containerWidth: CGFloat) -> CGSize {
        let totalInteritemSpacing = interitemSpacing * (columnCount - 1)
        let availableWidth = containerWidth
            - sectionInsets.left
            - sectionInsets.right
            - totalInteritemSpacing
        let width = floor(availableWidth / columnCount)
        return CGSize(width: max(80, width), height: max(72, width * 0.78))
    }

    static func viewportHeight(containerWidth: CGFloat) -> CGFloat {
        let rowHeight = itemSize(containerWidth: containerWidth).height
        return sectionInsets.top + lineSpacing + (rowHeight * visibleRows)
    }
}

struct TinyGIFRequestGeneration {
    private(set) var current: UInt = 0

    mutating func begin() -> UInt {
        current &+= 1
        return current
    }

    func isCurrent(_ request: UInt) -> Bool {
        request == current
    }
}
