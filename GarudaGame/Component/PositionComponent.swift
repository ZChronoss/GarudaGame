//
//  PositionComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 20/06/24.
//

import Foundation
import GameplayKit

class PositionComponent: GKComponent {
    let position: CGPoint
    
    init(position: CGPoint) {
        self.position = position
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
