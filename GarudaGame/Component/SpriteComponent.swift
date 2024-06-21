//
//  SpriteComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import SpriteKit
import GameplayKit
import Metal

class SpriteComponent: GKComponent {
    var node = SKSpriteNode()
    
    init(_ texture: SKTexture, size: CGSize, zPos: CGFloat) {
        super.init()
        self.node = SKSpriteNode(texture: texture)
        self.node.size = size
        self.node.zPosition = zPos
        
        let shader = SKShader(fileNamed: "ColorChange.metal")
        
        // Set the color change uniform (RGBA)
        let colorChange = vector_float4(1.0, 1.0, 1.0, 1.0) // Change to desired color
        let uniforms = SKUniform(name: "colorChange", vectorFloat4: colorChange)
        shader.uniforms = [uniforms]
        
        // Apply the shader to the sprite
        self.node.shader = shader
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
