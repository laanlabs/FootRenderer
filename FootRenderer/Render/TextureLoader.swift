//
//  TextureLoader.swift
//  FootRenderer
//
//  Created by William Perkins on 3/6/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

import Cocoa


class TextureLoader {
    public static let shared = TextureLoader()

    public func loadFloorImages() -> [NSImage] {
        let floorImagesURL = Project.inputPath.appendingPathComponent("floors/")
        return loadImages(at: floorImagesURL)
    }

    public func loadFloorColors() -> [NSColor] {
        return [
            NSColor.brown,
            NSColor.black,
            NSColor.blue,
            NSColor.white,
            NSColor.lightGray,
            NSColor.init(white: 0.1, alpha: 1),
            NSColor.init(white: 0.3, alpha: 1),
            NSColor.yellow,
            NSColor.orange,

            NSColor("#c78e63")!,
            NSColor("#ae7142")!,
            NSColor("#845737")!,
            NSColor("#715031")!,
            NSColor("#88563b")!,
            NSColor("#3b885d")!,
        ]
    }

    public func loadFloorColorsAndImages() -> [Any] {
        let colors = loadFloorColors() as [Any]
        let images = loadFloorImages() as [Any]

        return colors + images
    }

    public func loadSkinImages() -> [NSImage] {
        let skinImagesURL = Project.inputPath.appendingPathComponent("leg_textures/")
        return loadImages(at: skinImagesURL)
    }

    public typealias TrainingData = (image: NSImage, mask: NSImage)

    public func loadLegImagesAndMasks() -> [TrainingData] {
        var data: [TrainingData] = []
        let imagesURL = Project.inputPath.appendingPathComponent("legs/")
        let masksURL = Project.inputPath.appendingPathComponent("leg_masks/")
        let fileManager = FileManager.default

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: imagesURL, includingPropertiesForKeys: nil)
            for imageURL in fileURLs {
                // check that we have a corresponding mask for the image
                let maskURL = masksURL.appendingPathComponent(imageURL.lastPathComponent)
                guard fileManager.fileExists(atPath: masksURL.path) else { continue }

                let image = NSImage(byReferencing: imageURL)
                let mask = NSImage(byReferencing: maskURL)

                data.append((image, mask))
            }

        } catch {
            print("Error while loading leg images & masks: \(error.localizedDescription)")
        }

        return data
    }

    /**

     let idx = Int(arc4random() % UInt32(self.legImages2d.count))
     current2dLegImage = self.legImages2d[ idx ]
     current2dLegImageMask = self.legMasks2d[ idx ]
     */
    public func loadSkinColors() -> [NSColor] {
        return [
            NSColor.red,
            NSColor.blue,
            NSColor.brown,
            NSColor.yellow,

            NSColor("#f8d5c2")!,
            NSColor("#efbba6")!,
            NSColor("#e6aa86")!,

            NSColor("#f8d5c2")!,
            NSColor("#efbba6")!,
            NSColor("#e6aa86")!,

            NSColor("#d2946b")!,
            NSColor("#c78e63")!,
            NSColor("#ae7142")!,
            NSColor("#845737")!,
            NSColor("#715031")!,
            NSColor("#88563b")!,
            NSColor("#3b885d")!,
            NSColor("#3b6688")!,
            NSColor("#999999")!,

            NSColor("#f8d5c2")!,
            NSColor("#efbba6")!,
            NSColor("#e6aa86")!,

            NSColor("#f8d5c2")!,
            NSColor("#efbba6")!,
            NSColor("#e6aa86")!,

            NSColor("#d2946b")!,
            NSColor("#c78e63")!,
            NSColor("#ae7142")!,
            NSColor("#845737")!,
            NSColor("#715031")!,
            NSColor("#88563b")!,
            NSColor("#3b885d")!,
            NSColor("#3b6688")!,
            NSColor("#999999")!,
        ]
    }

    public func loadSkinColorsAndImages() -> [Any] {
        let colors = loadSkinColors() as [Any]
        let images = loadSkinImages() as [Any]

        return colors + images
    }

    private func loadImages(at url: URL) -> [NSImage] {
        var images: [NSImage] = []
        let fileManager = FileManager.default

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                let image = NSImage(byReferencing: fileURL)
                images.append(image)
            }

        } catch {
            print("Error while enumerating files \(url): \(error.localizedDescription)")
        }

        return images
    }
}
