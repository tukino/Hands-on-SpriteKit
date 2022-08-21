//
//  GameScene.swift
//  MatchingGame
//
//  Created by tukino_salva on 2022/08/21.
//

import SpriteKit

class GameScene: SKScene {
    // 状態管理
    enum State {
        case Wating
        case Playing
        case Finish
    }
    var state = State.Wating
    
    let fontName = "HiraginoSans-W3"
    
    let startLabelName = "startLabelName"
    let playLabelName = "playLabelName"
    let finishLabelName = "finishLabelName"
    
    var targetShapeCount = 0
    let targetShapeNamePrefix = "targetShapelName_"
    
    var actionFadeIn: SKAction?
    
    override func didMove(to view: SKView) {
        // Hello, World!
//        let label = SKLabelNode(fontNamed: "HiraginoSans-W3")
//        label.text = "Hello, World!"
//        label.fontSize = 40
//        label.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
//        self.addChild(label)
        
        actionFadeIn = SKAction.fadeIn(withDuration: 1)
        
        let startLabel = SKLabelNode(fontNamed: fontName)
        startLabel.name = startLabelName
        startLabel.text = "Start"
        startLabel.fontSize = 40
        startLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        startLabel.run(actionFadeIn!)
        self.addChild(startLabel)
        
        let playLabel = SKLabelNode(fontNamed: fontName)
        playLabel.name = playLabelName
        playLabel.text = "Playing"
        playLabel.fontSize = 40
        playLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        playLabel.alpha = 0
        self.addChild(playLabel)
        
        let finishLabel = SKLabelNode(fontNamed: fontName)
        finishLabel.name = finishLabelName
        finishLabel.text = "Finish"
        finishLabel.fontSize = 40
        finishLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        finishLabel.alpha = 0
        self.addChild(finishLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if state == .Playing {
            if Int.random(in: 0...100) == 0 {
                targetShapeCount += 1
                let circleOfRadius: CGFloat = 50.0
                let x: CGFloat = CGFloat.random(in: (self.frame.minX + circleOfRadius)...(self.frame.maxX - circleOfRadius))
                let y: CGFloat = CGFloat.random(in: (self.frame.minY + circleOfRadius)...(self.frame.maxY - circleOfRadius))
                
                let circle = SKShapeNode(circleOfRadius: circleOfRadius)
                circle.name = targetShapeNamePrefix + String(targetShapeCount)
                circle.position = CGPoint(x: x, y: y)
                circle.fillColor = .green
                self.addChild(circle)
                
                circle.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3),
                    SKAction.colorizeShapefillColor(fromColor: .green, toColor: .red, duration: 5)
                ]))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startLabel = self.childNode(withName: startLabelName) as? SKLabelNode else { return }
        guard let playLabel = self.childNode(withName: playLabelName) as? SKLabelNode else { return }
        guard let finishLabel = self.childNode(withName: finishLabelName) as? SKLabelNode else { return }
        
        switch state {
        case .Wating:
            startLabel.alpha = 0
//            playLabel.alpha = 1
            playLabel.run(actionFadeIn!)
            
            state = .Playing
        case .Playing:
            if let touch = touches.first {
                let locatin = touch.location(in: self)
                if let name = self.atPoint(locatin).name {
                    if let node = self.childNode(withName: name) as? SKShapeNode {
                        if name.hasPrefix(targetShapeNamePrefix) {
                            node.alpha = 0
                            return
                        }
                    }
                }
            }
            
            playLabel.alpha = 0
//            finishLabel.alpha = 1
            finishLabel.run(actionFadeIn!)
            
            state = .Finish
        case .Finish:
            finishLabel.alpha = 0
//            startLabel.alpha = 1
            startLabel.run(actionFadeIn!)
            
            state = .Wating
        }
    }
}


extension SKAction {
    static func colorizeShapefillColor(fromColor : UIColor, toColor : UIColor, duration : Double = 0.4) -> SKAction {
        func lerp(_ a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat { return (b-a) * fraction + a }
        var fred: CGFloat = 0, fgreen: CGFloat = 0, fblue: CGFloat = 0, falpha: CGFloat = 0
        var tred: CGFloat = 0, tgreen: CGFloat = 0, tblue: CGFloat = 0, talpha: CGFloat = 0
        fromColor.getRed(&fred, green: &fgreen, blue: &fblue, alpha: &falpha)
        toColor.getRed(&tred, green: &tgreen, blue: &tblue, alpha: &talpha)

        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let transColor = UIColor(red:   lerp(fred, b: tred, fraction: fraction),
                                     green: lerp(fgreen, b: tgreen, fraction: fraction),
                                     blue:  lerp(fblue, b: tblue, fraction: fraction),
                                     alpha: lerp(falpha, b: talpha, fraction: fraction))
            (node as! SKShapeNode).fillColor = transColor
        })
    }
}
