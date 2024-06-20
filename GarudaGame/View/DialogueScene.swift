//
//  DialogueScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 19/06/24.
//

import Foundation
import SpriteKit

class DialogueScene: SKScene {
    var dialogueBox = SKShapeNode()
    var speaking = SKLabelNode(fontNamed: "Helvetica-Bold")
    var dialogue = SKLabelNode(fontNamed: "Helvetica")
    
    override func didMove(to view: SKView) {
        dialogueBox = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height / 3))
        dialogueBox.position = CGPoint(x: frame.midX, y: frame.minY + 67)
        dialogueBox.fillColor = .brown
        
        speaking.position = CGPoint(x: (-dialogueBox.frame.width / 2) + 10, y: (dialogueBox.frame.height / 2) - 30)
        speaking.horizontalAlignmentMode = .left
        speaking.fontSize = 24
        dialogueBox.addChild(speaking)
        
        dialogue.position = CGPoint(x: -dialogueBox.frame.width / 2 + 10, y: dialogueBox.frame.height / 2 - 40)
        dialogue.fontSize = 20
        dialogue.fontColor = .white
        dialogue.horizontalAlignmentMode = .left
        dialogue.verticalAlignmentMode = .top
        dialogue.numberOfLines = 0
        dialogue.preferredMaxLayoutWidth = dialogueBox.frame.width - 20
        dialogueBox.addChild(dialogue)
        
        addChild(dialogueBox)
        
        setDialogue(speaker: "Garuda",
                    dialogue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        )
    }
    
    func setDialogue(speaker: String, dialogue: String){
        self.speaking.text = speaker
        self.dialogue.text = dialogue
    }
}
