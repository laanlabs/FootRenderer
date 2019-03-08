//
//  MaskRenderer.swift
//  FootRenderer
//
//  Created by William Perkins on 3/8/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

import SceneKit


/**
 Renders an image and associated mask
 */
class MaskRenderer: NSObject, SCNSceneRendererDelegate {
    var frameIdx: Int = 0
    let framesUntilImageCapture: Int // number of frames to render before capturing image
    let framesUntilMaskCapture: Int  // number of frames to render before capturing mask

    typealias RenderCompletion = (_ image: NSImage, _ mask: NSImage) -> Void
    let completion: RenderCompletion
    private var image: NSImage?
    private var mask: NSImage?

    init(after numFrames: Int, completion: @escaping RenderCompletion) {
        self.framesUntilImageCapture = numFrames
        self.framesUntilMaskCapture = numFrames * 2
        self.completion = completion
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //        print("rendered at: \(time) (idx: \(frameIdx)) (renderer: \(renderer)")

        guard frameIdx < framesUntilMaskCapture else { return }

        // only capture what is being rendered to the sceneview
        guard let sceneView = renderer as? SCNView else { return }

        if frameIdx == (framesUntilImageCapture - 1) {
            saveFrame(renderer)
            (sceneView.scene as? Maskable)?.setMaskLighting()
        }
        else if frameIdx == (framesUntilMaskCapture - 1) {
            saveMask(renderer)
            completion(image!, mask!)
        }

        frameIdx += 1
    }

    func saveFrame(_ renderer: SCNSceneRenderer) {
        guard let image = (renderer as? SCNView)?.snapshot() else { return }
        self.image = image
    }


    func saveMask(_ renderer: SCNSceneRenderer) {
        guard let image = (renderer as? SCNView)?.snapshot() else { return }
        self.mask = image
    }
}
