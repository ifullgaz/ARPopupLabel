//
//  ViewController.swift
//  ARPopupLabel
//
//  Created by Emmanuel Merali on 12/16/2019.
//  Copyright (c) 2019 Emmanuel Merali. All rights reserved.
//

import SceneKit
import ARPopupLabel

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    var popupLabel = ARPopupLabel()

    lazy var updateQueue = DispatchQueue(label: "org.cocoapods.demo.ARPopupLabel-Example")

    @IBAction func tapDetected(_ sender: Any) {
        switch popupLabel.isExpanded {
        case true:
            popupLabel.collapse(duration: 1) {
                self.popupLabel.isHidden = true
            }
        default:
            self.popupLabel.isHidden = false
            popupLabel.expand(duration: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()
        sceneView?.scene = scene
        sceneView.allowsCameraControl = true
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.1
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 1)
        scene.rootNode.addChildNode(cameraNode)
        
        popupLabel.backgrounColor = UIColor.white.withAlphaComponent(0.8)
        popupLabel.headerColor = UIColor.brown
        popupLabel.detailsColor = UIColor.darkGray
        popupLabel.borderColor = UIColor.brown
        popupLabel.dotColor = UIColor.brown
        popupLabel.headerText = "Coffee"
        popupLabel.detailsText = "Makes your day\nGives you energy\nPuts a smile on your face"
        scene.rootNode.addChildNode(popupLabel)
        popupLabel.scale = SCNVector3(0.5, 0.5, 0.5)
        popupLabel.updateQueue = updateQueue
        popupLabel.expand(duration: 1)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

