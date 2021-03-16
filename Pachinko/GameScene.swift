//
//  GameScene.swift
//  Pachinko
//
//  Created by Egor Chernakov on 16.03.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    let balls = ["ballRed", "ballBlue", "ballCyan", "ballYellow", "ballGrey", "ballPurple"]
    var editingMode = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 100, y: 700)
        editLabel.text = "Edit"
        addChild(editLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        addSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        addSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        addSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        addSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        addBouncer(at: CGPoint(x: 0, y: 0))
        addBouncer(at: CGPoint(x: 256, y: 0))
        addBouncer(at: CGPoint(x: 512, y: 0))
        addBouncer(at: CGPoint(x: 768, y: 0))
        addBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let objects = nodes(at: position)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                addBox(at: position)
            } else {
                addBall(at: position)
            }
        }
    }
    
    func addBall(at position: CGPoint) {
        guard position.y >= 700 else { return }
        let ball = SKSpriteNode(imageNamed: balls.randomElement() ?? "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.physicsBody!.restitution = 0.4
        ball.position = position
        ball.name = "ball"
        addChild(ball)
    }
    
    func addBox(at position: CGPoint) {
        let size = CGSize(width: CGFloat.random(in: 16...128), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = position
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody!.isDynamic = false
        box.name = "box"
        addChild(box)
    }
    
    func addBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody!.isDynamic = false
        bouncer.name = "bouncer"
        addChild(bouncer)
    }
    
    func addSlot(at position: CGPoint, isGood: Bool) {
        var slot: SKSpriteNode
        var glow: SKSpriteNode
        
        if isGood {
            slot = SKSpriteNode(imageNamed: "slotBaseGood")
            glow = SKSpriteNode(imageNamed: "slotGlowGood")
            slot.name = "slotGood"
        } else {
            slot = SKSpriteNode(imageNamed: "slotBaseBad")
            glow = SKSpriteNode(imageNamed: "slotGlowBad")
            slot.name = "slotBad"
        }
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        
        slot.position = position
        slot.physicsBody = SKPhysicsBody(rectangleOf: slot.size)
        slot.physicsBody!.isDynamic = false
        glow.position = position
        glow.run(spinForever)
        
        addChild(slot)
        addChild(glow)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "slotGood" {
            destroy(ball: ball)
            score += 1
        }
        
        if object.name == "slotBad" {
            destroy(ball: ball)
            score -= 1
        }
        
        if object.name == "box" {
            object.removeFromParent()
        }
    }
    
    func destroy(ball: SKNode) {
        if let fire = SKEmitterNode(fileNamed: "FireParticles") {
            fire.position = ball.position
            addChild(fire)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
