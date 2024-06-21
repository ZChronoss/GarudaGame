//
//  ButtonPressedState.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 21/06/24.
//

import Foundation
import GameplayKit

class ButtonPressedState: GKState {
    let button: SKSpriteNode
    let action: String
    
    init(button: SKSpriteNode, action: String) {
        self.button = button
        self.action = action
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        button.texture = SKTexture(imageNamed: action + "Pressed")
    }
}
