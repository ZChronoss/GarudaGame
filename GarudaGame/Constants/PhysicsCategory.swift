//
//  PhysicsCategory.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 19/06/24.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let enemy: UInt32 = 0x1 << 0
    static let player: UInt32 = 0x1 << 1
    static let platform: UInt32 = 0x1 << 2
    static let hitbox: UInt32 = 0x1 << 3
    static let bullet: UInt32 = 0x1 << 4
    static let groundChecker: UInt32 = 0x1 << 5
    static let softPlatform: UInt32 = 0x1 << 6
    static let platformChecker: UInt32 = 0x1 << 7
    static let enemyGroundChecker: UInt32 = 0x1 << 8
    static let spike: UInt32 = 0x1 << 9
}
