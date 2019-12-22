//
//  MainMenuScene.swift
//  sensiblecar
//
//  Created by Omer Cohen on 12/9/19.
//  Copyright © 2019 Omer Cohen. All rights reserved.
//


import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
//        let title:SKLabelNode = SKLabelNode()
//
//        title.fontName = "AvenirNext-Regular"
//        title.fontSize = 116
//        title.numberOfLines = 2
//        title.text = Constant.firstMainTitle
//        title.alpha = 1
//        title.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.70)
//
//        self.addChild(title)
        
        let logo:SKSpriteNode = SKSpriteNode(imageNamed: "logo_SensiEDGE")
        logo.size = CGSize(width: 500, height: 500/4.246)
        logo.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.75)
        self.addChild(logo)
        
        let title1:SKLabelNode = SKLabelNode()
        
        title1.fontName = "AvenirNext-Regular"
        title1.fontSize = 120
        title1.numberOfLines = 2
        title1.text = Constant.secondMainTitle
        title1.alpha = 1
        title1.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.60)
        
        self.addChild(title1)
        
        let text:SKLabelNode = SKLabelNode()
        text.fontName = "AvenirNext-UltraLight"
        text.fontSize = 60
        text.text = "Tap to play!"
        text.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        self.addChild(text)
        
        let car:SKSpriteNode = SKSpriteNode(imageNamed: "CarStart")
        car.size = CGSize(width: 60, height: 100)
        car.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.3)
        self.addChild(car)
        
        let appearCar = SKAction.scale(to: 4.0, duration: 1.0)
        let reduceCar = SKAction.scale(by: 0.8, duration: 0.5)
        
        let continuousScale = SKAction.repeatForever(SKAction.sequence([reduceCar, reduceCar.reversed()]))
        
        let animateCar = SKAction.sequence([appearCar, continuousScale])
        car.run(animateCar)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFit
        
        let transition = SKTransition.reveal(with: .right, duration: 1.0)
        self.removeAllActions()
        self.removeAllChildren()
        self.view?.presentScene(gameScene, transition: transition)
    }
}
