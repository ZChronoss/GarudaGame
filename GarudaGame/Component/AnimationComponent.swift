//
//  AnimationComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 12/06/24.
//

import Foundation
import GameplayKit

enum AnimationState: String {
    case idle = "Idle"
    case walkRight = "Right"
    case walkLeft = "Left"
//    case idle = "Idle"
}

class AnimationComponent: GKComponent {
    var frames = [SKTexture]()
    
    init(name: String) {
        super.init()
        self.frames = createAnimationFrame(name, state: AnimationState.idle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience override init() {
        self.init()
    }
    
    func createAnimationFrame(_ name: String, state: AnimationState) -> [SKTexture]{
        let textureAtlas = SKTextureAtlas(named: name + "\(state.rawValue)")
        var frames = [SKTexture]()
        
//        print(name + "\(state.rawValue)")
        
        for i in 0...textureAtlas.textureNames.count - 1{
            frames.append(textureAtlas.textureNamed(textureAtlas.textureNames[i]))
        }
        
        
        return frames
    }
}
