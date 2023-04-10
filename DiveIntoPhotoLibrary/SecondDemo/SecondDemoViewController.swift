//
//  SecondDemoViewController.swift
//  DiveIntoPhotoLibrary
//
//  Created by Brook_Mobius on 2023/4/3.
//

import SwiftUI

class SecondDemoViewController: UIHostingController<SecondDemoView> {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder, rootView: SecondDemoView())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Second"
  }
}
