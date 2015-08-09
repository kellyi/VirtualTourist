//
//  DemoSeeFlickrImageViewController.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/9/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit

class DemoSeeFlickrImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
    }
    
}
