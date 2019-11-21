//
//  ViewController.swift
//  ImageEditor
//
//  Created by Guowei Mo on 20/11/2019.
//  Copyright © 2019 Guowei Mo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  @IBAction func buttonTapped(_ sender: Any) {
    let vc = PhotoEditorViewController(image: UIImage(named: "test")!)
    vc.photoEditorDelegate = self
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
  
}

extension ViewController: PhotoEditorDelegate {
  
  func doneEditing(image: UIImage) {
    
  }
  
  func canceledEditing() {
    
  }
}
