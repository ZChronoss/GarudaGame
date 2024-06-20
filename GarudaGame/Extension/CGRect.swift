//
//  CGRect.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 20/06/24.
//

import Foundation

extension CGRect {
    static func minimalRect(containing points: [CGPoint]) -> CGPoint? {
        if points.isEmpty { return nil }

        let minX = points.min(by: { $0.x < $1.x })!.x
        let minY = points.min(by: { $0.y < $1.y })!.y

        return CGPoint(
            x: minX,
            y: minY
        )
    }
}
