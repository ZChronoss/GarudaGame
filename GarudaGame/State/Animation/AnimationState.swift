//
//  AnimationState.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 24/06/24.
//

import Foundation
import GameplayKit

class AnimationState: GKState {
    var node: SKSpriteNode
    var name: String
    
    init(node: SKSpriteNode, name: String) {
        self.node = node
        self.name = name
        super.init()
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
