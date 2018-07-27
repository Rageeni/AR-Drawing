//
//  ViewController.swift
//  Drawing
//
//  Created by Rageeni Jadam on 19/07/18.
//  Copyright © 2018 Rageeni Jadam. All rights reserved.
//

import UIKit
import ARKit
import RGSColorSlider

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var btnReset: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var btnDraw: UIButton!
    @IBOutlet var settingView: UIView!
    @IBOutlet var lblLineWidth: UILabel!
    @IBOutlet var btnEraser: UIButton!
    
    let config = ARWorldTrackingConfiguration()
    var isDraw: Bool = false
    var isErase: Bool = false
    var lineWidth: CGFloat!
    var lineColour: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        //set default value of sliders
        lineWidth = 2
        lineColour = UIColor(red: 0, green: 119.0/255.0, blue: 1, alpha: 1)
        sceneView.session.run(config)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func drawingAction(_ sender: Any) {
        if btnDraw.imageView?.image == #imageLiteral(resourceName: "drawing_pen") {
            isDraw = true
            btnEraser.isHidden = true
            btnReset.isHidden = true
            btnDraw.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        } else {
            isDraw = false
            btnEraser.isHidden = false
            btnReset.isHidden = false
            btnDraw.setImage(#imageLiteral(resourceName: "drawing_pen"), for: .normal)
        }
    }
    
    @IBAction func openSettingAction(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.settingView.isHidden = (self.settingView.isHidden) ? false : true
        }
    }
    
    @IBAction func resetDrawing(_ sender: Any) {
        DispatchQueue.main.async {
            self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                node.removeFromParentNode()
            })
        }
    }
    
    @IBAction func changeLineWidth(_ sender: Any) {
        lineWidth = CGFloat((sender as! UISlider).value)
        lblLineWidth.text = "Line Width :- \(String(format: "%.1f", lineWidth!)) cm"
    }
    
    @IBAction func changeLineColour(_ sender: Any) {
        lineColour = (sender as! RGSColorSlider).color!
    }
    
    @IBAction func eraseDrawing(_ sender: Any) {
        isErase = isErase ? false : true
        btnDraw.isHidden = isErase ? true : false
        btnReset.isHidden = isErase ? true : false
        if !isErase {
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "eraser" {
                        node.removeFromParentNode()
                    }
                }
            }
        }
    }
    
    @IBAction func undoDraw(_ sender: Any) {
    }
    
    @IBAction func redoDraw(_ sender: Any) {
    }
    
    //MARK:- Render Delegate
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(x: -transform.m31, y: -transform.m32, z: -transform.m33)
        let location = SCNVector3(x: transform.m41, y: transform.m42, z: transform.m43)
        let currentPosition = orientation + location
        if isDraw { //drawing starts
            let drawNode = SCNNode(geometry: SCNSphere(radius: lineWidth/200))
            drawNode.geometry?.firstMaterial?.diffuse.contents = lineColour
            drawNode.position = currentPosition
            sceneView.scene.rootNode.addChildNode(drawNode)
        } else if isErase {
            DispatchQueue.main.async {
                let eraser = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.1))
                eraser.name = "eraser"
                eraser.position = currentPosition
                eraser.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "eraser")
                
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.position == currentPosition || node.name == "eraser" {
                        node.removeFromParentNode()
                    }
                }
                self.sceneView.scene.rootNode.addChildNode(eraser)
            }
        } else {
            DispatchQueue.main.async {
                let pointerNode = SCNNode(geometry: SCNSphere(radius: self.lineWidth/200))
                pointerNode.name = "pointer"
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                }
                pointerNode.geometry?.firstMaterial?.diffuse.contents = self.lineColour
                pointerNode.position = currentPosition
                self.sceneView.scene.rootNode.addChildNode(pointerNode)
            }
        }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func ==(left: SCNVector3, right: SCNVector3) -> Bool {
    if String(format: "%.1f",left.x) == String(format: "%.1f",right.x) {
        if String(format: "%.1f",left.y) == String(format: "%.1f",right.y) {
            if String(format: "%.1f",left.z) == String(format: "%.1f",right.z) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    } else {
        return false
    }
}

