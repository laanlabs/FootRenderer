//
//  NSImage+Extensions.swift
//  FootRenderer
//
//  Created by William Perkins on 3/4/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

import Cocoa


public extension NSImage {
    public func writePNG(toURL url: URL) {

        guard let data = tiffRepresentation,
            let rep = NSBitmapImageRep(data: data),
            let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {

                Swift.print("\(self.self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
                return
        }

        do {
            try imgData.write(to: url)
        }catch let error {
            Swift.print("\(self.self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
    }
}

extension NSImage {
    static func named(_ name: String ) -> NSImage {
        let imagePath = Project.projectPath.appendingPathComponent("FootRenderer/\(name)")
        return NSImage(contentsOf: imagePath)!
    }
}
