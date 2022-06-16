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
//import UIKit
//import SpriteKit
//import GameplayKit

class GameViewController: UIViewController {

  var sceneView: ARSKView!

//* Here  set the view’s delegate and initialize GameScene directly, instead of through the scene file.
  override func viewDidLoad() {
    super.viewDidLoad()
    if let view = self.view as? ARSKView {
      sceneView = view
      sceneView!.delegate = self
      let scene = GameScene(size: view.bounds.size)
      scene.scaleMode = .resizeFill
      scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      view.presentScene(scene)
      view.showsFPS = true
      view.showsNodeCount = true
    }
  }
// *
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
// * Here you start the session when the view appears and pause the session when the view disappears.
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARWorldTrackingConfiguration()
    sceneView.session.run(configuration)
  }
    
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
//*
}




//* Extension for the delegate methods with placeholder error messages:
extension GameViewController: ARSKViewDelegate {
//  will execute when the view can’t create a session. This generally means that to be able to use the game, the user will have to allow access to the camera through the Settings app.
  func session(_ session: ARSession,
               didFailWithError error: Error) {
  print("Session Failed - probably due to lack of camera access")
}
//  means that the app is now in the background. The user may have pressed the home button or received a phone call.
func sessionWasInterrupted(_ session: ARSession) {
  print("Session interrupted")
}
//  means that play is back on again. The camera won’t be in exactly the same orientation or position so you reset tracking and anchors.
func sessionInterruptionEnded(_ session: ARSession) {
  print("Session resumed")
  sceneView.session.run(session.configuration!,
                        options: [.resetTracking,
                                  .removeExistingAnchors])
 }
func view(_ view: ARSKView,
          nodeFor anchor: ARAnchor) -> SKNode? {
  var node: SKNode?
  if let anchor = anchor as? Anchor {
    if let type = anchor.type {
      node = SKSpriteNode(imageNamed: type.rawValue)
      node?.name = type.rawValue
    }
  }
  return node
}


}
//*
