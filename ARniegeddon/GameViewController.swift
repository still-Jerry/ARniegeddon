
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
