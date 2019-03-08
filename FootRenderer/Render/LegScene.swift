//
//  LegScene.swift
//  FootRenderer
//
//  Created by William Perkins on 3/4/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

import SceneKit


protocol Maskable {
    func setMaskLighting()
    func setRegularLighting()
}


class LegScene: SCNScene {

    //
    // MARK: Camera
    //
    var camera: SCNNode? {
        didSet {
            cameraInitialPos = camera?.worldPosition ?? SCNVector3Zero
            cameraRight = camera?.worldRight ?? SCNVector3Zero
        }
    }
    private var cameraInitialPos: SCNVector3 = SCNVector3Zero
    private var cameraRight: SCNVector3 = SCNVector3Zero
    private var cameraFront: SCNVector3 = SCNVector3Zero

    //
    // MARK: Legs
    //  structure:
    //    legParent
    //     - legParent2
    //     -- leg
    var leg: SCNNode { return rootNode.childNode(withName: "leg", recursively: true)! }
    var legClothed: SCNNode { return rootNode.childNode(withName: "leg_clothed", recursively: true)! }
    var legParent: SCNNode { return rootNode.childNode(withName: "leg_parent", recursively: true)! }
    var legParent2: SCNNode { return rootNode.childNode(withName: "leg_parent2", recursively: true)! }

    enum LegMode : Int {
        case noLeg
        case realLegImage
        case clothedLeg3d
        case bareLeg3d
    }

    // 2D image plane

    var legPlane2d: SCNNode { return rootNode.childNode(withName: "leg_plane", recursively: true)! }
    var leg2dParent: SCNNode { return rootNode.childNode(withName: "leg2dparent", recursively: true)! }

    //
    // Floor
    //
    var floor: SCNNode { return rootNode.childNode(withName: "floor", recursively: true)! }

    //
    // MARK: Scene Lighting
    //
    var directional: SCNNode { return rootNode.childNode(withName: "directional", recursively: true)! }
    var omni: SCNNode { return rootNode.childNode(withName: "omni", recursively: true)! }
    var spot1: SCNNode { return rootNode.childNode(withName: "spot1", recursively: true)! }
    var spot2: SCNNode { return rootNode.childNode(withName: "spot2", recursively: true)! }

    //
    // MARK: Textures
    //
    var skinColors : [Any] = []
    var floorTextures : [Any] = []

    var legToeTextureTransform: SCNMatrix4 = SCNMatrix4Identity
    lazy var legToeMaskTexture: NSImage! = nil

    var clothedToeTextureTransform: SCNMatrix4 = SCNMatrix4Identity
    var clothedToeMaskTexture: NSImage! = nil

    //
    // MARK: Misc
    //
    public typealias TrainingData = (image: NSImage, mask: NSImage)
    var legs: [TrainingData] = [] {
        didSet {
            current2dLeg = legs.randomElement()!
        }
    }

    var current2dLeg: TrainingData! = nil

    var initialFloorPos: SCNVector3 = SCNVector3Zero

    func setup() {
        loadTextures()

        legToeTextureTransform = leg.geometry!.firstMaterial!.diffuse.contentsTransform
        legToeMaskTexture = NSImage.named("Render/art.scnassets/leg_toe_texture.png")

        clothedToeTextureTransform = legClothed.geometry!.materials[1].diffuse.contentsTransform
        clothedToeMaskTexture = NSImage.named("Render/art.scnassets/clothed_toe_texture.png")

        initialFloorPos = floor.worldPosition
    }

    func loadTextures() {
        floorTextures = TextureLoader.shared.loadFloorColorsAndImages()
        skinColors = TextureLoader.shared.loadSkinColorsAndImages()
        legs = TextureLoader.shared.loadLegImagesAndMasks()
    }
}

//
// MARK: - Leg Masking
//
extension LegScene: Maskable {

    func setRegularLighting() {

        leg.geometry?.firstMaterial?.lightingModel = .physicallyBased

        legClothed.geometry?.materials[0].lightingModel = .physicallyBased
        legClothed.geometry?.materials[1].lightingModel = .physicallyBased

        legClothed.geometry?.materials[0].transparency = 1.0

        legPlane2d.geometry?.firstMaterial?.diffuse.contents = current2dLeg.image
        legPlane2d.geometry?.firstMaterial?.transparent.contents = nil

        floor.isHidden = false
    }

    func setMaskLighting() {

        legPlane2d.geometry?.firstMaterial?.diffuse.contents = NSColor.red
        legPlane2d.geometry?.firstMaterial?.transparent.contents = current2dLeg.mask

        leg.geometry?.firstMaterial?.lightingModel = .constant
        leg.geometry?.firstMaterial?.diffuse.contents = legToeMaskTexture
        leg.geometry?.firstMaterial?.diffuse.contentsTransform = legToeTextureTransform


        legClothed.geometry?.materials[1].lightingModel = .constant
        legClothed.geometry!.materials[1].diffuse.contents = clothedToeMaskTexture
        legClothed.geometry!.materials[1].diffuse.contentsTransform = clothedToeTextureTransform


        legClothed.geometry?.materials[0].lightingModel = .constant
        legClothed.geometry?.materials[0].transparency = 0.0

        floor.isHidden = true
    }
}

//
// MARK: - Scene Randomization
//
extension LegScene {

    func randomizeScene() {

        directional.light?.intensity = 10.0 + Float.random() * 350.0
        directional.eulerAngles.x = Float.random(-30, -140) * Float.pi / 180.0
        directional.eulerAngles.y =  Float.random() * Float.pi * 2.0


        spot1.light?.intensity = 15.0 + Float.random() * 170.0
        spot2.light?.intensity = 15.0 + Float.random() * 170.0

        omni.light?.intensity = Float.random(0, 400)
        omni.worldPosition = SCNVector3( Float.random(-6, 6), Float.random(8, 18), Float.random(-6, 6) )

        randomLightPosition( light: spot2, yRange: (3.5, 10), posRange: (1.5, 4) )
        randomLightPosition( light: spot1, yRange: (3.5, 10), posRange: (1.5, 4) )


        floor.geometry?.firstMaterial?.diffuse.contents = floorTextures[ Int(arc4random() % UInt32(floorTextures.count)) ]

        floor.geometry?.firstMaterial?.lightingModel = (Float.random() > 0.4) ? .physicallyBased : .constant

        camera?.position = cameraInitialPos +
            cameraRight * Float.random(-0.9, 0.9) +
            SCNVector3(Float.random(-0.14, 0.14), Float.random(-0.5, 2.1), Float.random(-0.14, 0.14))

        legParent.eulerAngles.z = Float.random(-35, 14) * Float.pi / 180.0
        legParent2.eulerAngles.y = Float.random(-20, 20) * Float.pi / 180.0


        let legMode : LegMode = self.sampleLegMode()

        //let useClothed = (Float.random() > 0.5)
        if legMode == .noLeg {

            leg.isHidden = true
            legClothed.isHidden = true
            legPlane2d.isHidden = true

        } else if legMode == .clothedLeg3d {

            leg.isHidden = true
            legClothed.isHidden = false
            legPlane2d.isHidden = true

            legClothed.geometry?.materials[0].diffuse.contents = skinColors[ Int(arc4random() % UInt32(skinColors.count)) ]
            legClothed.geometry?.materials[1].diffuse.contents = skinColors[ Int(arc4random() % UInt32(skinColors.count)) ]

            legClothed.geometry?.materials[0].diffuse.contentsTransform = SCNMatrix4MakeScale(Float.random(0.8, 1.2),
                                                                                                    Float.random(0.8, 1.2),
                                                                                                    Float.random(0.8, 1.2))
            legClothed.geometry?.materials[1].diffuse.contentsTransform = SCNMatrix4MakeScale(Float.random(0.8, 1.2),
                                                                                                    Float.random(0.8, 1.2),
                                                                                                    Float.random(0.8, 1.2))

        } else if legMode == .bareLeg3d {

            legPlane2d.isHidden = true
            leg.isHidden = false
            legClothed.isHidden = true

            leg.eulerAngles.x = Float.random(-20, 20) * Float.pi / 180.0

            leg.geometry?.firstMaterial?.diffuse.contents = skinColors[ Int(arc4random() % UInt32(skinColors.count)) ]

            leg.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float.random(0.8, 1.2),
                                                                                               Float.random(0.8, 1.2),
                                                                                               Float.random(0.8, 1.2))
        } else if legMode == .realLegImage {


            legPlane2d.isHidden = false
            leg.isHidden = true
            legClothed.isHidden = true

            leg2dParent.worldPosition = SCNVector3( Float.random(-2.5, 0),
                                                          Float.random(0.3, 0.5),
                                                          Float.random(-1, 1) )

            leg2dParent.eulerAngles.y = Float.random(-25, 25) * Float.pi / 180.0

            current2dLeg = legs.randomElement()!
        }

        floor.scale = SCNVector3( Float.random(0.8, 1.4), Float.random(0.8, 1.4), 1.0 )

        floor.eulerAngles.y = Float.random() * Float.pi * 2
        floor.eulerAngles.z = Float.random(-0.01, 0.01)

        floor.worldPosition = initialFloorPos + SCNVector3(Float.random(-1, 1), 0.0, Float.random(-1.0, 1.0))
    }

    func randomLightPosition( light: SCNNode, yRange : (Float, Float) , posRange : (Float, Float)) {

        var x : Float = posRange.0 + (posRange.1 - posRange.0) * Float.random()
        if Float.random() > 0.5 {
            x = -x
        }

        var z : Float = posRange.0 + (posRange.1 - posRange.0) * Float.random()
        if Float.random() > 0.5 {
            z = -z
        }


        let y : Float = yRange.0 + (yRange.1 - yRange.0) * Float.random()
        light.position = SCNVector3(x, y, z)

        light.look(at: SCNVector3Zero )

    }

    func sampleLegMode() -> LegMode {

//        case noLeg
//        case realLegImage
//        case clothedLeg3d
//        case bareLeg3d

        //return .bareLeg3d;

        // sample no leg with 8% chance
        if Float.random() < 0.08 {
            return .noLeg
        } else {

            let ran = Int(1 + arc4random_uniform(3))
            assert(ran != 4)
            assert(ran != 0)
            return LegMode(rawValue: ran)!

        }
    }
}
