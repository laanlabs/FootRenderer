//
//  ViewController.swift
//  FootRenderer
//
//  Created by cc on 4/22/18.
//  Copyright © 2018 Laan Labs. All rights reserved.
//
// Modified by Haricharan Bole(github: haricharanbole)
// Modified the code to avoid using a separate mask renderer code. 

import SceneKit
import QuartzCore

struct AppSettings {
    static let numImagesToRender: Int = 100
}

class ViewController: NSViewController {

    var sceneView : SCNView! = nil

    // TODO: implement reusable scene state
    typealias SceneState = Int

    class Task {
        enum TaskState {
            case waiting
            case preparing
            case capturing
            case captured
            case finished
        }
        var state: TaskState = .waiting
        var sceneState: SceneState
        var id: Int

        init(id: Int, sceneState: SceneState = 0) {
            self.sceneState = sceneState
            self.id = id
        }

    }
    private var renderTasks: [Task] = []
    private var scene: LegScene! = nil

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        scene = LegScene(named: "art.scnassets/leg.scn")!
        scene.setup()

        setupScene()

        /*
         Create a destination directory for generated images & masks
         */
        Project.createOutputDirectories()
        print("Saving output to: \(Project.outputPath)")


        DispatchQueue.global(qos: .utility).async {

            for i in 0..<AppSettings.numImagesToRender {

                self.renderTasks.append(Task(id: i))

            }

            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { (timer) in
                    self.processQueue(timer)
                }
            }
        }

    }

    // MARK: - Helpers

    fileprivate func setupScene() {
        // retrieve the SCNView
        let scnView = self.view as! SCNView

        // set the scene to the view
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // configure the view
        scnView.backgroundColor = NSColor.black

        sceneView  = scnView

        sceneView.rendersContinuously = true
        sceneView.isPlaying = true

        scene.camera = sceneView.pointOfView
    }

    func processQueue(_ timer: Timer) {
        guard let task = renderTasks.first else {
            timer.invalidate()
            print("[processQueue] finished processing all tasks")
            return
        }

        //    print("Processing task: \(task)")

        switch task.state {
        case .waiting:
            print("[processQueue(\(task.id))] preparing scene")
            task.state = .preparing

//            scene?.configure(task.sceneState)  // TODO: make scene restorable
            scene.randomizeScene()
            scene.setRegularLighting()

            sceneView.prepare([scene as Any]) { (success) in

                print("scene is prepared: \(success)")

                print("taking snapshot")
                let name = String(format: "%05d.png", task.id)
                self.sceneView.scene = self.scene
                let img = self.sceneView.snapshot()
                Project.saveImage(img, to: name)
                self.scene.setMaskLighting()
                self.sceneView.scene = self.scene
                let msk = self.sceneView.snapshot()
                Project.saveMask(msk, to: name)
                
                task.state = .captured

            }
        case .preparing:
            print("[processQueue(\(task.id))] waiting for scene to be prepared")
        case .capturing:
            print("[processQueue(\(task.id))] waiting for scene capture to complete:")
        case .captured:
            task.state = .finished
        case .finished:
            print("[processQueue(\(task.id))] removing task from queue")
            // TODO: check that this is actually the current task
            renderTasks.removeFirst()
        }
    }

}
