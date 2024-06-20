//
//  CombatComponent.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 19/06/24.
//

import Foundation

//
//  PlayerMovementComponent.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 14/06/24.
//

import Foundation
import GameplayKit

class CombatComponent: GKComponent {
    var health: Int = 0
    
    init(_ health: Int) {
        super.init()
        self.health = health
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
