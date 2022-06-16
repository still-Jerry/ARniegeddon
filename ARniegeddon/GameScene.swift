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
  var sight: SKSpriteNode!
  var isWorldSetUp = false
  var sceneView: ARSKView {
    return view as! ARSKView
  }
//* Here you check whether the session has an initialized currentFrame. If the session doesn’t have a currentFrame, then you’ll have to try again later.
  private func setUpWorld() {
    guard let currentFrame = sceneView.session.currentFrame
      else { return }
//    Here you create a four-dimensional identity matrix
    var translation = matrix_identity_float4x4
//    This is what the translation matrix
    translation.columns.3.z = -0.3
//    Here you multiply the transform matrix of the current frame’s camera by your translation matrix. This results in a new transform matrix. When you create an anchor using this new matrix, ARKit will place the anchor at the correct position in 3D space relative to the camera.
    let transform = currentFrame.camera.transform * translation
//    Here you add an anchor to the session. The anchor is now a permanent feature in your 3D world (until you remove it). Each frame tracks this anchor and recalculates the transformation matrices of the anchors and the camera using the device’s new position and orientation.
    let anchor = ARAnchor(transform: transform)
    sceneView.session.add(anchor: anchor)

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
    // The measure of light is lumens, and 1000 lumens is a fairly bright light. Using the light estimate’s intensity of ambient light in the scene, you calculate a blend factor between 0 and 1, where 0 will be the brightest.
    let neutralIntensity: CGFloat = 1000
    let ambientIntensity = min(lightEstimate.ambientIntensity, neutralIntensity)
    let blendFactor = 1 - ambientIntensity / neutralIntensity

    // Using this blend factor, you calculate how much black should tint the bugs.
    for node in children {
      if let bug = node as? SKSpriteNode {
        bug.color = .black
        bug.colorBlendFactor = blendFactor
      }
    }
  }
//*
//  crosshair in the center of the screen
  override func didMove(to view: SKView) {
    sight = SKSpriteNode(imageNamed: "sight")
    addChild(sight)
  }
  override func touchesBegan(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    let location = sight.position
    let hitNodes = nodes(at: location)
    var hitBug: SKNode?
    for node in hitNodes {
      if node.name == "bug" {
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
    }

  }
}
