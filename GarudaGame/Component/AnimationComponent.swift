//
//  AnimationComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 12/06/24.
//

import Foundation
import GameplayKit

enum AnimationStateName: String {
    case idle = "Idle"
    case walk = "Walk"
    case jump = "Jump"
    case attack = "Attack"
    case dash = "Dash"
}

class AnimationComponent: GKComponent {
    var frames = [SKTexture]()
    
    init(name: String) {
        super.init()
        self.frames = createAnimationFrame(name, state: AnimationStateName.idle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience override init() {
        self.init()
    }
    
    func createAnimationFrame(_ name: String, state: AnimationStateName) -> [SKTexture]{
        let textureAtlas = SKTextureAtlas(named: name + "\(state.rawValue)")
        var frames = [SKTexture]()
        
        
        for i in 0...textureAtlas.textureNames.count - 1{
            frames.append(textureAtlas.textureNamed(textureAtlas.textureNames[i]))
        }
        
        
        return frames
    }
}
