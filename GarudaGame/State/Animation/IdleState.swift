//
//  IdleState.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 23/06/24.
//

import Foundation
import GameplayKit

class IdleState: AnimationState {
    
    override func didEnter(from previousState: GKState?) {
        let frames = createAnimationFrame(self.name, state: .idle)
        let animation = SKAction.animate(with: frames,
                                         timePerFrame: TimeInterval(0.5))
        node.run(SKAction.repeatForever(animation))
    }
}
