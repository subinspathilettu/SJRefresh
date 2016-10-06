//
//  UIImage+Gif.swift
//  Pods
//
//  Created by Subins on 06/10/16.
//
//

import UIKit
import ImageIO

public extension UIImage {

	public class func imagesFromGif(name: String) -> [UIImage]? {

		// Check for existance of gif
		guard let bundleURL = Bundle.main
			.url(forResource: name, withExtension: "gif") else {
				print("SwiftGif: This image named \"\(name)\" does not exist")
				return nil
		}

		// Validate data
		guard let imageData = try? Data(contentsOf: bundleURL) else {
			print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
			return nil
		}

		// Create source from data
		guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
			print("SwiftGif: Source for the image does not exist")
			return nil
		}

		let count = CGImageSourceGetCount(source)
		var images = [UIImage]()

		// Fill arrays
		for index in 0..<count {
			// Add image
			if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
				images.append(UIImage(cgImage: image))
			}
		}

		return images
	}
}

