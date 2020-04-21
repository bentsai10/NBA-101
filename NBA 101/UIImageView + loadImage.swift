//
//  UIImageView + loadImage.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/19/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

extension UIImageView{
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func loadImage(from url: URL)  {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.image = UIImage(data: data)
                print("image set")
            }
        }
    }
}
