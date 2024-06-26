//
//  DashState.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 26/06/24.
//

import Foundation
import GameplayKit

class DashState: AnimationState {
    override func didEnter(from previousState: GKState?) {
        let frames = createAnimationFrame(self.name, state: .dash)
        let animation = SKAction.animate(with: frames,
                                         timePerFrame: TimeInterval(0.05))
        node.run(animation)
    }
}
