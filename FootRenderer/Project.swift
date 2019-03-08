//
//  Project.swift
//  FootRenderer
//
//  Created by William Perkins on 3/6/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

import Cocoa


/**
 File saving & loading, path management

 */
struct Project {
//    public static let dataPath: URL = {
//        return Project.playgroundPath.deletingLastPathComponent().appendingPathComponent("data")
//    }()

    static let outputImagesPath: URL = {
        return outputPath.appendingPathComponent("frames_\(sessionID)/images")
    }()

    static let outputMasksPath: URL = {
        return outputPath.appendingPathComponent("frames_\(sessionID)/masks")
    }()

    public static let inputPath: URL = {
        return projectPath.appendingPathComponent("input")
    }()

    public static let outputPath: URL = {
        return projectPath.appendingPathComponent("output")
    }()

    static let projectPath: URL = {
        // load project path from Info.plist file
        let path = Bundle.main.object(forInfoDictionaryKey: "LLProjectPath") as! String
        return URL(fileURLWithPath: path)
    }()

    static var sessionID: String = "undefined"

    public static func createOutputDirectories() {
        sessionID = createSessionID()

        do {
            for url in [outputImagesPath,  outputMasksPath] {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }

    private static func createSessionID() -> String {
        let formatter = DateFormatter()
        let now = Date()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: now)
    }

    @discardableResult
    public static func saveImage(_ image: NSImage, to path: String) -> String {
        let imageURL = outputImagesPath.appendingPathComponent(path)
        image.writePNG(toURL: imageURL)

        return imageURL.path
    }

    @discardableResult
    public static func saveMask(_ image: NSImage, to path: String) -> String {
        let imageURL = outputMasksPath.appendingPathComponent(path)
        image.writePNG(toURL: imageURL)

        return imageURL.path
    }
}
