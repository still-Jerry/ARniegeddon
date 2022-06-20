/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import ARKit
//import SpriteKit
//import GameplayKit

class GameScene: SKScene {
  let gameSize = CGSize(width: 2, height: 2)
  var sight: SKSpriteNode!
  var isWorldSetUp = false
  var sceneView: ARSKView {
    return view as! ARSKView
  }
//  changes the sight image when it is changed.
  var hasBugspray = false {
    didSet {
      let sightImageName = hasBugspray ? "bugspraySight" : "sight"
      sight.texture = SKTexture(imageNamed: sightImageName)
    }
  }

//* Here you check whether the session has an initialized currentFrame. If the session doesn’t have a currentFrame, then you’ll have to try again later.
  private func setUpWorld() {
    
    guard let currentFrame = sceneView.session.currentFrame,
      // Here you load the scene, complete with bugs from Level1.sks.
      let scene = SKScene(fileNamed: "Level1")
      else { return }
      
    for node in scene.children {
      if let node = node as? SKSpriteNode {
        var translation = matrix_identity_float4x4
        // You calculate the position of the node relative to the size of the scene. ARKit translations are measured in meters. Turning 2D into 3D, you use the y-coordinate of the 2D scene as the z-coordinate in 3D space. Using these values, you create the anchor and the view’s delegate will add the SKSpriteNode bug for each anchor as before.
        let positionX = node.position.x / scene.size.width
        let positionY = node.position.y / scene.size.height
        translation.columns.3.x =
                Float(positionX * gameSize.width)
        translation.columns.3.z =
                -Float(positionY * gameSize.height)
        translation.columns.3.y = Float(drand48() - 0.5)

        let transform =
               currentFrame.camera.transform * translation
        let anchor = Anchor(transform: transform)
        if let name = node.name,
          let type = NodeType(rawValue: name) {
          anchor.type = type
          sceneView.session.add(anchor: anchor)
          if anchor.type == .firebug {
            addBugSpray(to: currentFrame)
          }

        }

      }
    }
    isWorldSetUp = true
  }
//*
//* Doing it this way, you only run the set up code once, and only when the session is ready.
  override func update(_ currentTime: TimeInterval) {
    if !isWorldSetUp {
      setUpWorld()
    }
    // You retrieve the light estimate from the session’s current frame.
    guard let currentFrame = sceneView.session.currentFrame,
      let lightEstimate = currentFrame.lightEstimate else {
        return
    }
//    // The measure of light is lumens, and 1000 lumens is a fairly bright light. Using the light estimate’s intensity of ambient light in the scene, you calculate a blend factor between 0 and 1, where 0 will be the brightest.
//    let neutralIntensity: CGFloat = 1000
//    let ambientIntensity = min(lightEstimate.ambientIntensity, neutralIntensity)
//    let blendFactor = 1 - ambientIntensity / neutralIntensity
//
//    // Using this blend factor, you calculate how much black should tint the bugs.
//    for node in children {
//      if let bug = node as? SKSpriteNode {
//        bug.color = .black
//        bug.colorBlendFactor = blendFactor
//      }
//    }
    // You process all of the anchors attached to the current frame,
    for anchor in currentFrame.anchors {
      // You check whether the node for the anchor is of type bugspray. At the time of writing, there is an Xcode bug whereby subclasses of ARAnchor lose their properties, so you can’t check the anchor type directly.
      guard let node = sceneView.node(for: anchor),
        node.name == NodeType.bugspray.rawValue
        else { continue }
      // ARKit includes the framework simd, which provides a distance function. You use this to calculate the distance between the anchor and the camera.
      let distance = simd_distance(anchor.transform.columns.3,
        currentFrame.camera.transform.columns.3)
      // If the distance is less than 10 centimeters, you remove the anchor from the session. This will remove the bug spray node as well.
      if distance < 0.1 {
        remove(bugspray: anchor)
        break
      }
    }

  }
//*
//  crosshair in the center of the screen
  override func didMove(to view: SKView) {
    sight = SKSpriteNode(imageNamed: "sight")
    addChild(sight)
    srand48(Int(Date.timeIntervalSinceReferenceDate))

  }
  override func touchesBegan(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    let location = sight.position
    let hitNodes = nodes(at: location)
    var hitBug: SKNode?
    for node in hitNodes {
      if node.name == NodeType.bug.rawValue ||
        (node.name == NodeType.firebug.rawValue && hasBugspray) {

        hitBug = node
        break
      }
    }
    run(Sounds.fire)
    if let hitBug = hitBug,
      let anchor = sceneView.anchor(for: hitBug) {
      let action = SKAction.run {
        self.sceneView.session.remove(anchor: anchor)
      }
      let group = SKAction.group([Sounds.hit, action])
      let sequence = [SKAction.wait(forDuration: 0.3), group]
      hitBug.run(SKAction.sequence(sequence))
      hasBugspray = false

    }

  }
//  In this method, you add a new anchor of type bugspray with a random position. You randomize the x (side) and z (forward/back) values between -1 and 1 and the y (up/down) value between -0.5 and 0.5.
  private func addBugSpray(to currentFrame: ARFrame) {
    var translation = matrix_identity_float4x4
    translation.columns.3.x = Float(drand48()*2 - 1)
    translation.columns.3.z = -Float(drand48()*2 - 1)
    translation.columns.3.y = Float(drand48() - 0.5)
    let transform = currentFrame.camera.transform * translation
    let anchor = Anchor(transform: transform)
    anchor.type = .bugspray
    sceneView.session.add(anchor: anchor)
  }
//  This is where you set up the SKAction and then mute it. This is also the wear of the SKNode attached to the anchor.

  private func remove(bugspray anchor: ARAnchor) {
    run(Sounds.bugspray)
    sceneView.session.remove(anchor: anchor)
    hasBugspray = true

  }

}
