//
//  SpriteKitContainer.swift
//  Triangle
//
//  Created by João Vitor Dall Agnol Fernandes on 13/04/22.
//

import SpriteKit
import SwiftUI

enum nodeTouched {
case fillButton, emptyButton, rotateClockwiseButton, rotateCounterclockButton, none
}

class SpriteKitScene: SKScene {
    
    // MARK: - Color Scheme
    var currentColorScheme: UIUserInterfaceStyle = .light
    
    // MARK: - Nodes
    var display = SKSpriteNode()
    var zAxis = SKNode()
    var water: [SKShapeNode] = []
    var triangle: [SKShapeNode] = []
    var hud = SKNode()
    var gravityNodes = [SKFieldNode](repeating: SKFieldNode(), count: 5)
                    // [c1BottomGravity, c1RightGravity, c2BottomGrvity, c2LeftGravity, hypGravity]
    var triangleShape = SKSpriteNode()
    var c1Box: [SKSpriteNode] = []
    var c2Box: [SKSpriteNode] = []
    var hypBox: [SKSpriteNode] = []
    
    // MARK: - Button Nodes
    var fillButton: SKSpriteNode = SKSpriteNode()
    var emptyButton: SKSpriteNode = SKSpriteNode()
    var counterclockButton: SKSpriteNode = SKSpriteNode()
    var clockWiseButton: SKSpriteNode = SKSpriteNode()
    
    // MARK: - Screen Size
    var screenSize: CGSize = UIScreen.main.bounds.size
    
    override func didMove(to view: SKView) {
        initialSettings()
        
        zAxis.position.y = screenSize.height/12
        zAxis.zPosition = -1
        
        setHUD()
        createTriangleAndHypBox()
        createCathetusBoxes()
        createGravitationalFields()
    }
    
    func initialSettings() {
        self.view?.showsPhysics = false
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.showsFPS = false
        self.view?.showsFields = false
        self.view?.showsNodeCount = false
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        self.backgroundColor = UIColor(named: colorScheme == .dark ? "bgColorDark" : "bgColorLight") ?? .black
    }
    
    func setHUD() {
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        if colorScheme == .light {
            currentColorScheme = .light
        } else {
            currentColorScheme = .dark
        }
        
        display = SKSpriteNode(imageNamed: colorScheme == .dark ? "displayDark" : "displayLight")
        display.zPosition = 10
        display.size = screenSize
        addChild(display)
        
        hud.position = CGPoint(x: 0, y: (-screenSize.height/2 + screenSize.height/12))
        addChild(hud)
        
        fillButton = SKSpriteNode(imageNamed: colorScheme == .dark ? "fillButtonDark" : "fillButtonLight" )
        fillButton.name = "fillButton"
        fillButton.size = CGSize(width: screenSize.width/6.96, height: screenSize.width/12.8)
        fillButton.position = CGPoint(x: -screenSize.width/2.6, y: screenSize.height/26)
        fillButton.zPosition = 11
        hud.addChild(fillButton)
        
        emptyButton = SKSpriteNode(imageNamed: colorScheme == .dark ? "emptyButtonDark" : "emptyButtonLight")
        emptyButton.name = "emptyButton"
        emptyButton.size = CGSize(width: screenSize.width/6.96, height: screenSize.width/12.8)
        emptyButton.position = CGPoint(x: -screenSize.width/2.6 + emptyButton.frame.size.width, y: emptyButton.frame.height/24)
        emptyButton.zPosition = 11
        hud.addChild(emptyButton)
        
        counterclockButton = SKSpriteNode(imageNamed: colorScheme == .dark ? "counterclockwiseButtonDark" : "counterclockwiseButtonLight")
        counterclockButton.name = "rotateCounterclockButton"
        counterclockButton.size = CGSize(width: screenSize.width/8.75, height: screenSize.width/8.75)
        counterclockButton.position = CGPoint(x: screenSize.width/2.5, y: screenSize.height/30)
        counterclockButton.zPosition = 11
        hud.addChild(counterclockButton)
        
        clockWiseButton = SKSpriteNode(imageNamed: colorScheme == .dark ? "clockwiseButtonDark" : "clockwiseButtonLight")
        clockWiseButton.name = "rotateClocwiseButton"
        clockWiseButton.size = CGSize(width: screenSize.width/8.75, height: screenSize.width/8.75)
        clockWiseButton.position = CGPoint(x: screenSize.width/3.6, y: 0)
        clockWiseButton.zPosition = 11
        hud.addChild(clockWiseButton)
        
    }
    
    func checkIfTouchIsInside(touchLocation: CGPoint, frame: CGRect) -> Bool {
        if touchLocation.x > frame.minX && touchLocation.x < frame.maxX {
            if touchLocation.y > frame.minY && touchLocation.y < frame.maxY {
                return true
            }
        }
        return false
    }
    
    func checkTouch(touchLocation: CGPoint) -> nodeTouched {
        guard let touchLocationInHUD = scene?.convert(touchLocation, to: hud) else { return .none }
        
        if checkIfTouchIsInside(touchLocation: touchLocationInHUD, frame: fillButton.frame) {
            return .fillButton
        } else if checkIfTouchIsInside(touchLocation: touchLocationInHUD, frame: counterclockButton.frame) {
            return .rotateCounterclockButton
        } else if checkIfTouchIsInside(touchLocation: touchLocationInHUD, frame: clockWiseButton.frame) {
            return .rotateClockwiseButton
        } else if checkIfTouchIsInside(touchLocation: touchLocationInHUD, frame: fillButton.frame) {
            return .fillButton
        } else if checkIfTouchIsInside(touchLocation: touchLocationInHUD, frame: emptyButton.frame) {
            return .emptyButton
        }
        return .none
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        switch checkTouch(touchLocation: location) {
            
        case .fillButton:
            if zAxis.childNode(withName: "waterDrop") == nil {
                createWaterWOAsset()
            } else {
                zAxis.removeAction(forKey: "fillWater")
                removeWater()
                createWaterWOAsset()
            }
            break
        case .emptyButton:
            if zAxis.childNode(withName: "waterDrop") == nil {
                break
            } else {
                zAxis.removeAction(forKey: "fillWater")
                removeWater()
                break
            }
        case .rotateClockwiseButton:
            if zAxis.action(forKey: "counterclockRotation") != nil {
                zAxis.removeAction(forKey: "counterclockRotation")
                counterclockButton.removeAction(forKey: "counterclockRotation")
            }
            if zAxis.action(forKey: "clockwiseRotation") != nil {
                zAxis.removeAction(forKey: "clockwiseRotation")
                clockWiseButton.removeAction(forKey: "clockwiseRotation")
            } else {
                let clockwiseRotate = SKAction.rotate(byAngle: -0.06, duration: 0.1)
                let infiniteClockwiseRotation = SKAction.repeatForever(clockwiseRotate)
                zAxis.run(infiniteClockwiseRotation, withKey: "clockwiseRotation")
                clockWiseButton.run(infiniteClockwiseRotation, withKey: "clockwiseRotation")
            }
            break
        case .rotateCounterclockButton:
            if zAxis.action(forKey: "clockwiseRotation") != nil {
                zAxis.removeAction(forKey: "clockwiseRotation")
                clockWiseButton.removeAction(forKey: "clockwiseRotation")
            }
            if zAxis.action(forKey: "counterclockRotation") != nil {
                zAxis.removeAction(forKey: "counterclockRotation")
                counterclockButton.removeAction(forKey: "counterclockRotation")
            } else {
                let counterclockRotate = SKAction.rotate(byAngle: 0.06, duration: 0.1)
                let infiniteCounterclockRotation = SKAction.repeatForever(counterclockRotate)
                zAxis.run(infiniteCounterclockRotation, withKey: "counterclockRotation")
                counterclockButton.run(infiniteCounterclockRotation, withKey: "counterclockRotation")
            }
            break
        default:
            break
        }
    }
    
    // MARK: - Create shapes
    func createTriangleAndHypBox() {
        addChild(zAxis)
        
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        triangleShape = SKSpriteNode(imageNamed: colorScheme == .dark ? "triangleDarkFull" : "triangleLightFull")
        triangleShape.size = CGSize(width: UIScreen.main.bounds.width/3.7, height: UIScreen.main.bounds.height/3.7)
        triangleShape.zPosition = 99
        triangleShape.position.x = -1
        zAxis.addChild(triangleShape)
        
        //cathetus number 1
        let c1 = SKShapeNode(rectOf: CGSize(width: UIScreen.main.bounds.width/4.5, height: 10))
        c1.fillColor = .red
        c1.zPosition = 1
        triangle.append(c1)
        
        //cathetus number 2
        let c2 = SKShapeNode(rectOf: CGSize(width: 10, height: UIScreen.main.bounds.height/4.5))
        c2.position = CGPoint(x: -c1.frame.size.width/2, y: 0)
        c2.fillColor = .red
        c2.zPosition = 1
        
        c1.position = CGPoint(x: 0, y: -c2.frame.size.height/2)
        
        triangle.append(c2)
        
        //hypotenuse
        //pythagoras theorem --> √((Hypotenuse)2) = √((Base)2 + (Altitude)2)
        let hypSize = sqrt( pow(c1.frame.size.width, 2) + pow(c2.frame.size.height, 2) )
        let spriteHypSize = sqrt( pow(triangleShape.frame.size.width, 2) + pow(triangleShape.frame.size.height, 2) )
        
        let hypotenuse = SKShapeNode(rectOf: CGSize(width: 10, height: hypSize))
        hypotenuse.position = CGPoint(x: 0, y: 0)
        hypotenuse.fillColor = .clear
        hypotenuse.strokeColor = .clear
        hypotenuse.zPosition = 1
        triangle.append(hypotenuse)

        //hypotenuse box Sprite Asset
        let hypBoxBottomSpriteWall = SKSpriteNode(imageNamed: colorScheme == .dark ? "purpleHyp" : "pinkHyp")
        hypBoxBottomSpriteWall.size.height = spriteHypSize * 0.95
        hypBoxBottomSpriteWall.position = CGPoint(x: triangle[2].frame.height, y: 0)
        hypBoxBottomSpriteWall.zPosition = 5
        hypBox.append(hypBoxBottomSpriteWall)
        hypotenuse.addChild(hypBoxBottomSpriteWall)

        let hypBoxLateralSpriteWall1 = SKSpriteNode(imageNamed: colorScheme == .dark ? "purpleHyp" : "pinkHyp")
        hypBoxLateralSpriteWall1.size.height = spriteHypSize * 0.95
        hypBoxLateralSpriteWall1.position = CGPoint(x: triangle[2].frame.size.height/2, y: triangle[2].frame.size.height/2)
        hypBoxLateralSpriteWall1.zPosition = 4
        hypBoxLateralSpriteWall1.run(SKAction.rotate(byAngle: 1.5708, duration: 0))
        hypBox.append(hypBoxLateralSpriteWall1)
        hypotenuse.addChild(hypBoxLateralSpriteWall1)

        guard let hypBoxLateralSpriteWall2 = hypBoxLateralSpriteWall1.copy() as? SKSpriteNode else { return }
        hypBoxLateralSpriteWall2.position.y = -triangle[2].frame.size.height/2
        hypBox.append(hypBoxLateralSpriteWall2)
        hypotenuse.addChild(hypBoxLateralSpriteWall2)
        
        //hypotenuse box structure
        let hypBoxBottomWall = SKShapeNode(rectOf: triangle[2].frame.size)
        hypBoxBottomWall.position = CGPoint(x: triangle[2].frame.height, y: 0)
        hypBoxBottomWall.fillColor = .clear
        hypBoxBottomWall.strokeColor = .clear
        
        let hypBoxBottomWallPhysics = SKPhysicsBody(rectangleOf: hypBoxBottomWall.frame.size)
        hypBoxBottomWallPhysics.isDynamic = false
        hypBoxBottomWallPhysics.affectedByGravity = false
        hypBoxBottomWall.physicsBody = hypBoxBottomWallPhysics
        hypotenuse.addChild(hypBoxBottomWall)

        let hypBoxLateralWall1 = SKShapeNode(rectOf: CGSize(width: triangle[2].frame.size.height, height: 10))
        hypBoxLateralWall1.position = CGPoint(x: triangle[2].frame.size.height/2, y: triangle[2].frame.size.height/2)
        hypBoxLateralWall1.fillColor = .clear
        hypBoxLateralWall1.strokeColor = .clear
        let hypBoxLateralWall1Physics = SKPhysicsBody(rectangleOf: hypBoxLateralWall1.frame.size)
        hypBoxLateralWall1Physics.isDynamic = false
        hypBoxLateralWall1Physics.affectedByGravity = false
        hypBoxLateralWall1.physicsBody = hypBoxLateralWall1Physics
        hypotenuse.addChild(hypBoxLateralWall1)
        
        guard let hypBoxLaterallWall2 = hypBoxLateralWall1.copy() as? SKShapeNode else { return }
        hypBoxLaterallWall2.position.y = -triangle[2].frame.size.height/2
        hypotenuse.addChild(hypBoxLaterallWall2)
        
        if screenSize.width == 1024.0 { //ipad pro max 12.9 inch
            hypotenuse.run(SKAction.rotate(byAngle: 0.65, duration: 0)) //setting correct angle
            zAxis.run(SKAction.rotate(byAngle: -1.57-0.65, duration: 0)) //setting initial position of triangle
        } else if screenSize.width == 834.0 { //ipad pro 11 inch
            hypotenuse.run(SKAction.rotate(byAngle: 0.60, duration: 0))
            zAxis.run(SKAction.rotate(byAngle: -1.57-0.60, duration: 0))
        } else if screenSize.width == 744.0 { //ipad mini (6th gen)
            hypotenuse.run(SKAction.rotate(byAngle: 0.58, duration: 0))
            zAxis.run(SKAction.rotate(byAngle: -1.57-0.58, duration: 0))
        } else {
            hypotenuse.run(SKAction.rotate(byAngle: 0.62, duration: 0))
            zAxis.run(SKAction.rotate(byAngle: -1.57-0.62, duration: 0))
        }

        zAxis.addChild(hypotenuse)
    }
    
    func createCathetusBoxes() {
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        
        //cathetus number 1 box sprite
        let c1BoxBottomSpriteWall = SKSpriteNode(imageNamed: colorScheme == .dark ? "purpleC1" : "pinkC1")
        c1BoxBottomSpriteWall.size.height = triangleShape.frame.size.width * 1.03
        c1BoxBottomSpriteWall.position = CGPoint(x: 0, y: triangle[0].position.y - triangle[0].frame.size.width)
        c1BoxBottomSpriteWall.zPosition = 5
        c1BoxBottomSpriteWall.run(SKAction.rotate(byAngle: 1.5708, duration: 0))
        c1Box.append(c1BoxBottomSpriteWall)
        zAxis.addChild(c1BoxBottomSpriteWall)
        
        guard let c1BoxLateralSpriteWall1 = c1BoxBottomSpriteWall.copy() as? SKSpriteNode else { return }
        c1BoxLateralSpriteWall1.run(SKAction.rotate(byAngle: -1.5708, duration: 0))
        c1BoxLateralSpriteWall1.zPosition = 4
        c1BoxLateralSpriteWall1.position.x = -triangle[0].frame.size.width/2
        c1BoxLateralSpriteWall1.position.y = -triangle[1].frame.size.height/2 - triangle[0].frame.size.width/2
        c1Box.append(c1BoxLateralSpriteWall1)
        zAxis.addChild(c1BoxLateralSpriteWall1)
        
        guard let c1BoxLateralSpriteWall2 = c1BoxLateralSpriteWall1.copy() as? SKSpriteNode else { return }
        c1BoxLateralSpriteWall2.position.x = triangle[0].frame.size.width/2
        c1Box.append(c1BoxLateralSpriteWall2)
        zAxis.addChild(c1BoxLateralSpriteWall2)
        
        //cathetus number 1 box structure
        let c1BoxBottomWall = SKShapeNode(rectOf: triangle[0].frame.size)
        c1BoxBottomWall.position = CGPoint(x: 0, y: triangle[0].position.y - triangle[0].frame.size.width)
        c1BoxBottomWall.fillColor = .clear
        let c1BoxBottomWallPhysics = SKPhysicsBody(rectangleOf: c1BoxBottomWall.frame.size)
        c1BoxBottomWallPhysics.isDynamic = false
        c1BoxBottomWallPhysics.affectedByGravity = false
        c1BoxBottomWall.physicsBody = c1BoxBottomWallPhysics
        zAxis.addChild(c1BoxBottomWall)
        
        let c1BoxLateralWall1 = SKShapeNode(rectOf: CGSize(width: 10, height: c1BoxBottomWall.frame.size.width))
        c1BoxLateralWall1.position = CGPoint(x: -triangle[0].frame.size.width/2, y: triangle[0].position.y - c1BoxLateralWall1.frame.size.height/2)
        c1BoxLateralWall1.fillColor = .clear
        c1BoxLateralWall1.strokeColor = .clear
        let c1BoxLateralWall1Physics = SKPhysicsBody(rectangleOf: c1BoxLateralWall1.frame.size)
        c1BoxLateralWall1Physics.isDynamic = false
        c1BoxLateralWall1Physics.affectedByGravity = false
        c1BoxLateralWall1.physicsBody = c1BoxLateralWall1Physics
        zAxis.addChild(c1BoxLateralWall1)
        
        guard let c1BoxLateralWall2 = c1BoxLateralWall1.copy() as? SKShapeNode else { return }
        c1BoxLateralWall2.position = CGPoint(x: triangle[0].frame.size.width/2, y: triangle[0].position.y - c1BoxLateralWall1.frame.size.height/2)
        zAxis.addChild(c1BoxLateralWall2)
        
        //cathetus number 2 box sprite
        let c2BoxBottomSpriteWall = SKSpriteNode(imageNamed: colorScheme == .dark ? "purpleC2" : "pinkC2")
        c2BoxBottomSpriteWall.size.height = triangleShape.frame.size.height * 0.98
        c2BoxBottomSpriteWall.position = CGPoint(x: triangle[1].position.x - triangle[1].frame.size.height, y: 0)
        c2BoxBottomSpriteWall.zPosition = 5
        c2Box.append(c2BoxBottomSpriteWall)
        zAxis.addChild(c2BoxBottomSpriteWall)
        
        guard let c2BoxLateralSpriteWall1 = c2BoxBottomSpriteWall.copy() as? SKSpriteNode else { return }
        c2BoxLateralSpriteWall1.zPosition = 4
        c2BoxLateralSpriteWall1.position.x = -triangle[1].frame.height/2 - triangle[0].frame.width/2
        c2BoxLateralSpriteWall1.position.y = triangle[1].frame.height/2
        c2BoxLateralSpriteWall1.run(SKAction.rotate(byAngle: 1.5708, duration: 0))
        c2Box.append(c2BoxLateralSpriteWall1)
        zAxis.addChild(c2BoxLateralSpriteWall1)
        
        guard let c2BoxLateralSpriteWall2 = c2BoxLateralSpriteWall1.copy() as? SKSpriteNode else { return }
        c2BoxLateralSpriteWall2.position.y = -triangle[1].frame.height/2
        c2Box.append(c2BoxLateralSpriteWall2)
        zAxis.addChild(c2BoxLateralSpriteWall2)
        
        //cathetus number 2 box structure
        let c2BoxBottomWall = SKShapeNode(rectOf: triangle[1].frame.size)
        c2BoxBottomWall.position = CGPoint(x: triangle[1].position.x - triangle[1].frame.size.height, y: 0)
        c2BoxBottomWall.fillColor = .gray
        let c2BoxBottomWallPhysics = SKPhysicsBody(rectangleOf: c2BoxBottomWall.frame.size)
        c2BoxBottomWallPhysics.isDynamic = false
        c2BoxBottomWallPhysics.affectedByGravity = false
        c2BoxBottomWall.physicsBody = c2BoxBottomWallPhysics
        zAxis.addChild(c2BoxBottomWall)
        
        let c2BoxLateralWall1 = SKShapeNode(rectOf: CGSize(width: triangle[1].frame.size.height, height: 10))
        c2BoxLateralWall1.position = CGPoint(x: -triangle[0].frame.size.width/2 - c2BoxLateralWall1.frame.size.width/2, y: triangle[1].frame.size.height/2)
        c2BoxLateralWall1.fillColor = .gray
        let c2BoxLateralWall1Physics = SKPhysicsBody(rectangleOf: c2BoxLateralWall1.frame.size)
        c2BoxLateralWall1Physics.isDynamic = false
        c2BoxLateralWall1Physics.affectedByGravity = false
        c2BoxLateralWall1.physicsBody = c2BoxLateralWall1Physics
        zAxis.addChild(c2BoxLateralWall1)
        
        guard let c2BoxLateralWall2 = c2BoxLateralWall1.copy() as? SKShapeNode else { return }
        c2BoxLateralWall2.position = CGPoint(x: -triangle[0].frame.size.width/2 - c2BoxLateralWall1.frame.size.width/2, y: -triangle[1].frame.size.height/2)
        zAxis.addChild(c2BoxLateralWall2)
        
    }
    
    // MARK: - Create water
    func createWaterWOAsset() {
        let colorScheme = UITraitCollection.current.userInterfaceStyle
        var radius = 24.0
        if screenSize.width == 1024.0 { //ipad pro max 12.9 inch
                radius = 22
        } else if screenSize.width == 834.0 { //ipad pro 11 inch
                radius = 18
        } else if screenSize.width == 744.0 { //ipad mini (6th gen)
                radius = 22
        } else { //default
                radius = 20
        }
        
        let waterNode = SKShapeNode.init(circleOfRadius: radius)
        waterNode.fillColor = colorScheme == .dark ? UIColor(named: "waterDropDark") ?? .blue : UIColor(named: "waterDropLight") ?? .systemBlue
        waterNode.strokeColor = .clear
        waterNode.name = "waterDrop"
        let waterNodePhysics = SKPhysicsBody(circleOfRadius: radius/2)
        waterNodePhysics.affectedByGravity = true
        waterNode.physicsBody = waterNodePhysics
        
        let hypSquareArea: Double = triangle[2].frame.size.height * triangle[2].frame.size.height
        let waterNodeArea: Double = Double.pi * (radius/2)*(radius/2)
        var waterDropsAmount: Int = 0
        var waterDropsArea: Double = 0
        let smallWaterNodeArea: Double = Double.pi * (radius/2/2)*(radius/2/2)

        while waterDropsArea < hypSquareArea {
            waterDropsAmount += 1
            waterDropsArea += waterNodeArea
            waterDropsArea += smallWaterNodeArea
        }
        
        //smallNodes
        let smallRadius = radius/2
        let smallWaterNode = SKShapeNode.init(circleOfRadius: smallRadius)
        smallWaterNode.fillColor = colorScheme == .dark ? UIColor(named: "waterDropDark") ?? .blue : UIColor(named: "waterDropLight") ?? .systemBlue
        smallWaterNode.strokeColor = .clear
        smallWaterNode.name = "waterDrop"
        let smallWaterNodePhysics = SKPhysicsBody(circleOfRadius: smallRadius/2)
        smallWaterNodePhysics.affectedByGravity = true
        smallWaterNode.physicsBody = smallWaterNodePhysics
        
        let waitAction = SKAction.wait(forDuration: 0.005)
        let add2WaterDrop = SKAction.run {
            let smallExtraNode = smallWaterNode.copy() as! SKShapeNode
            let extraNode = waterNode.copy() as! SKShapeNode
            self.zAxis.addChild(extraNode)
            self.zAxis.addChild(smallExtraNode)
        }
        let sequence = SKAction.sequence([add2WaterDrop,waitAction])
        
        var fillWaterAction = SKAction()
        
        if screenSize.width == 1024.0 { //ipad pro max 12.9 inch
//            fillWaterAction = SKAction.repeat(sequence, count: Int(Double(waterDropsAmount)*1.273))
            fillWaterAction = SKAction.repeat(sequence, count: Int(Double(waterDropsAmount)*1.29))
        } else if screenSize.width == 834.0 { //ipad pro 11 inch
            fillWaterAction = SKAction.repeat(sequence, count: Int(Double(waterDropsAmount)*1.2))
        } else if screenSize.width == 744.0 { //ipad mini (6th gen)
            fillWaterAction = SKAction.repeat(sequence, count: Int(Double(waterDropsAmount)*1.15))
        } else { //default
            fillWaterAction = SKAction.repeat(sequence, count: Int(Double(waterDropsAmount)*1.24))
        }
        
        zAxis.run(fillWaterAction, withKey: "fillWater")
    }
    
    func removeWater() {
        zAxis.enumerateChildNodes(withName: "waterDrop") { node, error in
            node.removeFromParent()
        }
        guard let label = fillButton.childNode(withName: "fillLabel") as? SKLabelNode else {return}
        label.text = "Fill Water"
    }
    
    // MARK: - Create Gravity
    func createGravitationalFields() {
        // c1gravity
        let c1Gravity = SKFieldNode.linearGravityField(withVector: vector_float3(0, -1, 0))
        c1Gravity.position = CGPoint(x: 0, y: -triangle[1].frame.size.height/2-triangle[0].frame.size.width/2)
        c1Gravity.region = SKRegion(size: CGSize(width: triangle[0].frame.size.width, height: triangle[0].frame.size.width))
        c1Gravity.strength = 5
        gravityNodes[0] = c1Gravity
        zAxis.addChild(c1Gravity)
        
        let c1RightGravity = SKFieldNode.linearGravityField(withVector: vector_float3(1, 0, 0))
        c1RightGravity.position = CGPoint(x: 0, y: triangle[0].position.y - triangle[0].frame.size.width/2)
        c1RightGravity.region = SKRegion(size: CGSize(width: triangle[0].frame.size.width, height: triangle[0].frame.size.width))
        c1RightGravity.strength = 5
        gravityNodes[1] = c1RightGravity
        zAxis.addChild(c1RightGravity)
        
        // c2gravity
        let c2Gravity = SKFieldNode.linearGravityField(withVector: vector_float3(-1, 0, 0))
        c2Gravity.position = CGPoint(x: -triangle[0].frame.width/2-triangle[1].frame.height/2, y: 0)
        c2Gravity.region = SKRegion(size: CGSize(width: triangle[1].frame.size.height, height: triangle[1].frame.size.height))
        c2Gravity.strength = 5
        zAxis.addChild(c2Gravity)
        gravityNodes[2] = c2Gravity
        
        let c2LeftGravity = SKFieldNode.linearGravityField(withVector: vector_float3(0, 1, 0))
        c2LeftGravity.position = CGPoint(x: -triangle[0].frame.width/2-triangle[1].frame.height/2, y: 0)
        c2LeftGravity.region = SKRegion(size: CGSize(width: triangle[1].frame.size.height, height: triangle[1].frame.size.height))
        c2LeftGravity.strength = 10
        gravityNodes[3] = c2LeftGravity
        zAxis.addChild(c2LeftGravity)
    }
    
    func checkGravityFields() {
        let c1GravityNodePos = scene?.convert(gravityNodes[0].position, from: zAxis)
        let c2GravityNodePos = scene?.convert(gravityNodes[2].position, from: zAxis)
        
        if c1GravityNodePos?.y ?? -1 > zAxis.position.y {
            gravityNodes[0].strength = -8
            gravityNodes[1].strength = -15
        } else {
            gravityNodes[0].strength = 15
            gravityNodes[1].strength = 15
        }
        
        if c2GravityNodePos?.y ?? -1 > zAxis.position.y {
            gravityNodes[2].strength = -8
            gravityNodes[3].strength = -15
        } else {
            gravityNodes[2].strength = 15
            gravityNodes[3].strength = 15
        }
    }
    
    func checkColorScheme() {
        if currentColorScheme != UITraitCollection.current.userInterfaceStyle {
            currentColorScheme = UITraitCollection.current.userInterfaceStyle
            switch currentColorScheme {
            case .light:
                if zAxis.childNode(withName: "waterDrop") != nil {
                    zAxis.enumerateChildNodes(withName: "waterDrop") { node, err in
                        guard let shapeNode = node as? SKShapeNode else { return }
                        shapeNode.fillColor = UIColor(named: "waterDropLight") ?? .systemBlue
                    }
                }
                self.triangleShape.run(SKAction.setTexture(SKTexture(imageNamed: "triangleLightFull")))
                c1Box[0].run(SKAction.setTexture(SKTexture(imageNamed: "pinkC1")))
                c1Box[1].run(SKAction.setTexture(SKTexture(imageNamed: "pinkC1")))
                c1Box[2].run(SKAction.setTexture(SKTexture(imageNamed: "pinkC1")))
                c2Box[0].run(SKAction.setTexture(SKTexture(imageNamed: "pinkC2")))
                c2Box[1].run(SKAction.setTexture(SKTexture(imageNamed: "pinkC2")))
                c2Box[2].run(SKAction.setTexture(SKTexture(imageNamed: "pinkC2")))
                hypBox[0].run(SKAction.setTexture(SKTexture(imageNamed: "pinkHyp")))
                hypBox[1].run(SKAction.setTexture(SKTexture(imageNamed: "pinkHyp")))
                hypBox[2].run(SKAction.setTexture(SKTexture(imageNamed: "pinkHyp")))
                self.backgroundColor = UIColor(named: "bgColorLight") ?? .clear
                display.run(SKAction.setTexture(SKTexture(imageNamed: "displayLight") ) )
                emptyButton.run(SKAction.setTexture(SKTexture(imageNamed: "emptyButtonLight") ) )
                fillButton.run(SKAction.setTexture(SKTexture(imageNamed: "fillButtonLight") ) )
                clockWiseButton.run(SKAction.setTexture(SKTexture(imageNamed: "clockwiseButtonLight") ) )
                counterclockButton.run(SKAction.setTexture(SKTexture(imageNamed: "counterclockwiseButtonLight") ) )
                break

            case .dark:
                if zAxis.childNode(withName: "waterDrop") != nil {
                    zAxis.enumerateChildNodes(withName: "waterDrop") { node, err in
                        guard let shapeNode = node as? SKShapeNode else { return }
                        shapeNode.fillColor = .blue
                    }
                }
                self.triangleShape.run(SKAction.setTexture(SKTexture(imageNamed: "triangleDarkFull")))
                c1Box[0].run(SKAction.setTexture(SKTexture(imageNamed: "purpleC1")))
                c1Box[1].run(SKAction.setTexture(SKTexture(imageNamed: "purpleC1")))
                c1Box[2].run(SKAction.setTexture(SKTexture(imageNamed: "purpleC1")))
                c2Box[0].run(SKAction.setTexture(SKTexture(imageNamed: "purpleC2")))
                c2Box[1].run(SKAction.setTexture(SKTexture(imageNamed: "purpleC2")))
                c2Box[2].run(SKAction.setTexture(SKTexture(imageNamed: "purpleC2")))
                hypBox[0].run(SKAction.setTexture(SKTexture(imageNamed: "purpleHyp")))
                hypBox[1].run(SKAction.setTexture(SKTexture(imageNamed: "purpleHyp")))
                hypBox[2].run(SKAction.setTexture(SKTexture(imageNamed: "purpleHyp")))
                
                self.backgroundColor = UIColor(named: "bgColorDark") ?? .black
                display.run(SKAction.setTexture(SKTexture(imageNamed: "displayDark") ) )
                emptyButton.run(SKAction.setTexture(SKTexture(imageNamed: "emptyButtonDark") ) )
                fillButton.run(SKAction.setTexture(SKTexture(imageNamed: "fillButtonDark") ) )
                clockWiseButton.run(SKAction.setTexture(SKTexture(imageNamed: "clockwiseButtonDark") ) )
                counterclockButton.run(SKAction.setTexture(SKTexture(imageNamed: "counterclockwiseButtonDark") ) )
                break
            default:
                break
            }
        }
    }
        
    override func update(_ currentTime: TimeInterval) {
        checkGravityFields()
        checkColorScheme()
    }
}
