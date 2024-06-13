//
//  SpriteComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import GameplayKit


class SpriteComponent: GKComponent {
    var node = SKSpriteNode()
    
    init(_ texture: SKTexture, size: CGSize) {
        super.init()
        self.node = SKSpriteNode(texture: texture)
        self.node.size = size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
