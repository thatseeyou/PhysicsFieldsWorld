//
//  GameScene.swift
//  PhysicsFieldsWorld
//
//  Created by FloodSurge on 6/14/14.
//  Copyright (c) 2014 FloodSurge. All rights reserved.
//

import SpriteKit

enum FieldType:Int {
    case LinearGravityFieldDown = 0
    case LinearGravityFieldUp
    case RadialGravityField
    case DragField
    case VortexField
    case VelocityField
    case NoiseField
    case TurbulenceField
    case SpringField
    case ElectricField
    case MagneticField

    static let tagNames:[String] = [
        "LinearGravityFieldDownTag",
        "LinearGravityFieldUpTag",
        "RadialGravityFieldTag",
        "DragFieldTag",
        "VortexFieldTag",
        "VelocityFieldTag",
        "NoiseFieldTag",
        "TurbulenceFieldTag",
        "SpringFieldTag",
        "ElectricFieldTag",
        "MagneticField"
    ]

    static let nextFieldType:[FieldType] = [
        .LinearGravityFieldUp,
        .RadialGravityField,
        .DragField,
        .VortexField,
        .VelocityField,
        .NoiseField,
        .TurbulenceField,
        .SpringField,
        .LinearGravityFieldDown,
        .MagneticField,
        .LinearGravityFieldDown
    ]

    func tagName() -> String {
        return FieldType.tagNames[self.rawValue]
    }

    func next() -> FieldType {
        return FieldType.nextFieldType[self.rawValue]
    }
}

class GameScene: SKScene {
    
    var shooter:SKSpriteNode!
    var fieldType:FieldType!
    
    override func didMoveToView(view: SKView) {
        
        rotateShooter()
        shootBall()
        
        changeField(.LinearGravityFieldDown)
    }

    func changeField(fieldType: FieldType)
    {
        changeTagTo(fieldType.tagName())

        // remove previous field
        let fieldNode = childNodeWithName("FieldNode") as! SKFieldNode
        fieldNode.removeFromParent()


        let field:SKFieldNode!

        switch fieldType {
        case .LinearGravityFieldUp:
            field = SKFieldNode.linearGravityFieldWithVector(vector_float3(0, -9.8, 0))
            field.strength = -1

        case .LinearGravityFieldDown:
            field = SKFieldNode.linearGravityFieldWithVector(vector_float3(0, -9.8, 0))
            field.strength = 1

        case .RadialGravityField:
            field = SKFieldNode.radialGravityField()

        case .DragField:
            field = SKFieldNode.dragField()
            field.region = SKRegion(radius: 50)

        case .VortexField:
            field = SKFieldNode.vortexField()
            field.region = SKRegion(radius:40)
            field.strength = 5
            field.falloff = -1

        case .VelocityField:
            field = SKFieldNode.velocityFieldWithTexture(SKTexture(imageNamed:"VelocityFieldTag"))

        case .NoiseField:
            field = SKFieldNode.noiseFieldWithSmoothness(0.8, animationSpeed:1)
            field.strength = 0.1

        case .TurbulenceField:
            field = SKFieldNode.turbulenceFieldWithSmoothness(1, animationSpeed: 10)

        case .SpringField:
            field = SKFieldNode.springField()
            field.strength = 0.05
            field.falloff = -5

        case .ElectricField:
            field = SKFieldNode.electricField()
            field.strength = -10

        default:
            field = SKFieldNode.dragField()
        }

        let fieldCenter = childNodeWithName("PhysicsFieldCenter")?.position

        self.fieldType = fieldType
        field.position = fieldCenter!
        field.name = "FieldNode"
        addChild(field)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        changeField(self.fieldType.next())
    }
    
    func changeTagTo(tagName:String){
        let fieldTag = childNodeWithName("FieldTag")
        let texture = SKTexture(imageNamed:tagName)
        fieldTag!.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.2),
            SKAction.animateWithTextures([texture], timePerFrame: 0),
            SKAction.fadeInWithDuration(0.2)
            ]))
    }

    override func update(currentTime: CFTimeInterval) {
    }

    
    func rotateShooter()
    {
        let shooter = childNodeWithName("shooter")
        let rotateClockwiseAction = SKAction.rotateToAngle(CGFloat(M_PI_4), duration: 1)
        let rotateAntiClockwiseAction = SKAction.rotateToAngle(-CGFloat(M_PI_4), duration: 1)
        let rotateForeverAction = SKAction.repeatActionForever(SKAction.sequence([rotateAntiClockwiseAction,rotateClockwiseAction]))

        shooter!.runAction(rotateForeverAction)
    }
    
    func shootBall()
    {
        
        let creatBallAction = SKAction.runBlock {
            let shooter = self.childNodeWithName("shooter")
            
            let rotation = shooter!.zRotation
            
            let ball = SKSpriteNode(imageNamed: "ball")
            do {
                ball.position = CGPointMake(
                    shooter!.position.x + cos(rotation) * 25,
                    shooter!.position.y + sin(rotation) * 25)
                
                let velocity = CGFloat( arc4random() % 300 + 100)
                //let velocity = CGFloat(50)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: 5)
                ball.physicsBody!.velocity = CGVectorMake(velocity * cos(rotation), velocity * sin(rotation))
                ball.physicsBody!.charge = -10

                //                let ballTrail = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("BallTrail2", ofType: "sks")!) as! SKEmitterNode
                let ballTrail = SKEmitterNode(fileNamed: "BallTrail2.sks")!
                do {
                    ballTrail.position = CGPointMake(0, 0)
                    ballTrail.targetNode = self
                }
                ball.addChild(ballTrail)
            }

            // 3초 뒤에 제거
            ball.runAction(SKAction.sequence([SKAction.waitForDuration(3), SKAction.removeFromParent()]))

            self.addChild(ball)

        }
        
        let wait = SKAction.waitForDuration(NSTimeInterval(Float(arc4random() % 100) / 100.0 + 0.2))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([creatBallAction,wait])))
    }
}
