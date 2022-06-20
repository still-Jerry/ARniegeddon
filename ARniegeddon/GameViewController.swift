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
import UIKit
import RealityKit
import ARKit
import MultipeerConnectivity
//import UIKit
//import SpriteKit
//import GameplayKit

class GameViewController: UIViewController {
  @IBOutlet weak var messageLabel: MessageLabel!

  var multipeerSession: MultipeerSession?

  var sceneView: ARSKView!
  var configuration: ARWorldTrackingConfiguration?

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
//    let configuration = ARWorldTrackingConfiguration()
//    подключение совсместной работы.
    configuration = ARWorldTrackingConfiguration()

    // Enable a collaborative session.
    configuration?.isCollaborationEnabled = true

    // Enable realistic reflections.
    configuration?.environmentTexturing = .automatic

    // Begin the session.
    sceneView.session.run(configuration!)
//
//    sceneView.session.run(configuration)
  }
  
  
  
  
  
//  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
      for anchor in anchors {
          if let participantAnchor = anchor as? ARParticipantAnchor {
              messageLabel.displayMessage("Established joint experience with a peer.")
              // ...
//              let anchorEntity = AnchorEntity(anchor: participantAnchor)
//              
//              let coordinateSystem = MeshResource.generateCoordinateSystemAxes()
//              anchorEntity.addChild(coordinateSystem)
//              
//              let color = participantAnchor.sessionIdentifier?.toRandomColor() ?? .white
//              let coloredSphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.03),
//                                              materials: [SimpleMaterial(color: color, isMetallic: true)])
//              anchorEntity.addChild(coloredSphere)
//              
//              arView.scene.addAnchor(anchorEntity)
//          } else if anchor.name == "Anchor for object placement" {
//              // Create a cube at the location of the anchor.
//              let boxLength: Float = 0.05
//              // Color the cube based on the user that placed it.
//              let color = anchor.sessionIdentifier?.toRandomColor() ?? .white
//              let coloredCube = ModelEntity(mesh: MeshResource.generateBox(size: boxLength),
//                                            materials: [SimpleMaterial(color: color, isMetallic: true)])
//              // Offset the cube by half its length to align its bottom with the real-world surface.
//              coloredCube.position = [0, boxLength / 2, 0]
//              
//              // Attach the cube to the ARAnchor via an AnchorEntity.
//              //   World origin -> ARAnchor -> AnchorEntity -> ModelEntity
//              let anchorEntity = AnchorEntity(anchor: anchor)
//              anchorEntity.addChild(coloredCube)
//              arView.scene.addAnchor(anchorEntity)
          }
      }
  }
  
//  Wealth Data Collection
  func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
      guard let multipeerSession = multipeerSession else { return }
      if !multipeerSession.connectedPeers.isEmpty {
          guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
          else { fatalError("Unexpectedly failed to encode collaboration data.") }
          // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
          let dataIsCritical = data.priority == .critical
          multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
      } else {
          print("Deferred sending collaboration to later because there are no peers.")
      }
  }
  func receivedData(_ data: Data, from peer: MCPeerID) {
    if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
      sceneView.session.update(with: collaborationData!)
//      может стоит убрать восклитацельный знак???
        return
    }
    func peerJoined(_ peer: MCPeerID) {
        messageLabel.displayMessage("""
            A peer wants to join the experience.
            Hold the phones next to each other.
            """, duration: 6.0)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
 
    
      // ...
//      let sessionIDCommandString = "SessionID:"
//      if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
//          let newSessionID = String(commandString[commandString.index(commandString.startIndex,
//                                                                   offsetBy: sessionIDCommandString.count)...])
//          // If this peer was using a different session ID before, remove all its associated anchors.
//          // This will remove the old participant anchor and its geometry from the scene.
//          if let oldSessionID = peerSessionIDs[peer] {
//              removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
//          }
//
//          peerSessionIDs[peer] = newSessionID
//      }
  }
  //  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  
  
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
  private func sendARSessionIDTo(peers: [MCPeerID]) {
      guard let multipeerSession = multipeerSession else { return }
      let idString = sceneView.session.identifier.uuidString
      let command = "SessionID:" + idString
      if let commandData = command.data(using: .utf8) {
          multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
      }
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
