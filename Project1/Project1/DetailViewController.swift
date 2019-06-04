//
//  DetailViewController.swift
//  Project1
//
//  Created by Christian Mitteldorf on 14/04/2019.
//  Copyright © 2019 Christian Mitteldorf. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!

    var selectedImage: String?

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = selectedImage
        navigationItem.largeTitleDisplayMode = .never

        if let selectedImage = selectedImage {
            imageView.image = UIImage(named: selectedImage)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
