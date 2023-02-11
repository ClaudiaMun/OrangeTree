
import SpriteKit

class GameScene: SKScene {
    
    var orangeTree: SKSpriteNode!
    var orange: Orange?
    var touchStart: CGPoint = .zero
    var shapeNode = SKShapeNode()
    var boundary = SKNode()
    var numOfLevels: UInt32 = 3
    
    // Class method to load .sks files
    static func Load(level: Int) -> GameScene? {
      return GameScene(fileNamed: "Level-\(level)")
    }
    
    override func didMove(to view: SKView) {
        //connect Game Objects
        orangeTree = childNode(withName: "tree") as? SKSpriteNode
        shapeNode.lineWidth = 20
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        // Set the contact delegate
        physicsWorld.contactDelegate = self
        
        // Setup the boundaries
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
        let background = childNode(withName: "background") as? SKSpriteNode
        boundary.position = CGPoint(x: (background?.size.width ?? 0) / -2, y: (background?.size.height ?? 0) / -2)
        addChild(boundary)
        
        // Add the Sun to the scene
        let sun = SKSpriteNode(imageNamed: "Sun")
        sun.name = "sun"
        sun.position.x = size.width / 2.6 - (sun.size.width * 0.25)
        sun.position.y = size.height / 3 - (sun.size.height * 0.25)
        addChild(sun)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      // Get the location of the touch on the screen
      let touch = touches.first!
      let location = touch.location(in: self)
        
    
      // Check if the touch was on the Orange Tree
      if atPoint(location).name == "tree" {
        // Create the orange and add it to the scene at the touch location
        orange = Orange()
        orange?.physicsBody?.isDynamic = false
        orange?.position = location
        addChild(orange!)
        //store the location of the touch
          touchStart = location
        // Give the orange an impulse to make it fly!
          //let vector = CGVector(dx: 100, dy: 0)
          //orange?.physicsBody?.applyImpulse(vector)
      }
        // Check whether the sun was tapped and change the level
        for node in nodes(at: location) {
          if node.name == "sun" {
            let n = Int(arc4random() % numOfLevels + 1)
            if let scene = GameScene.Load(level: n) {
              scene.scaleMode = .aspectFill
              if let view = view {
                view.presentScene(scene)
              }
            }
          }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      // Get the location of the touch
      let touch = touches.first!
      let location = touch.location(in: self)

      // Update the position of the Orange to the current location
      orange?.position = location
        //Draw firing vector
      let path = UIBezierPath()
      path.move(to: touchStart)
      path.addLine(to: location)
      shapeNode.path = path.cgPath
    
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      // Get the location of where the touch ended
      let touch = touches.first!
      let location = touch.location(in: self)

      // Get the difference between the start and end point as a vector
        let dx = (touchStart.x - location.x) * 0.7
        let dy = (touchStart.y - location.y) * 0.7
        let vector = CGVector(dx: dx, dy: dy)

      // Set the Orange dynamic again and apply the vector as an impulse
      orange?.physicsBody?.isDynamic = true
      orange?.physicsBody?.applyImpulse(vector)
        //remove path from shapenode
      shapeNode.path = nil
    }
  
    }
extension GameScene: SKPhysicsContactDelegate {
    // Called when the physicsWorld detects two nodes colliding
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        // Check that the bodies collided hard enough
        if contact.collisionImpulse > 15 {
            if nodeA?.name == "skull" {
                removeSkull(node: nodeA!)
                skullDestroyedParticles(point: nodeA!.position)
            } else if nodeB?.name == "skull" {
                removeSkull(node: nodeB!)
                skullDestroyedParticles(point: nodeB!.position)
            }
        }
    }
        
        // Function used to remove the Skull node from the scene
        func removeSkull(node: SKNode) {
            node.removeFromParent()
    
        }
}

extension GameScene {
  func skullDestroyedParticles(point: CGPoint) {
      if let explosion = SKEmitterNode(fileNamed: "Explosion") {
        addChild(explosion)
        explosion.position = point
        let wait = SKAction.wait(forDuration: 1)
        let removeExplosion = SKAction.removeFromParent()
        explosion.run(SKAction.sequence([wait, removeExplosion]))
      }
    
    }
}

