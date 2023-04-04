//
//  HomeView.swift
//  DiveIntoPhotoLibrary
//
//  Created by Brook_Mobius on 2023/4/3.
//

import SwiftUI
import Photos

struct HomeView: View {
  @StateObject var viewModel: PhotoViewModel = .shared
  
  var body: some View {
    content
  }
  
  @ViewBuilder
  var content: some View {
    if viewModel.isAuthed {
      authedContent
        .onAppear {
          viewModel.onAppear()
        }
    } else {
      Text("Not authed")
    }
  }
  
  var authedContent: some View {
    VStack(spacing: 20) {
      makeScanAllButton20()
      makeScanAllButton224()
      makeScanAllButtonDefault()
      makeScanAllButtonFull()
      
      makeCheckResourceButton()
      
      makeDeleteAllButton()
    }
  }
  
  func makeScanAllButton20() -> some View {
    Button("Scan all 20 \(viewModel.countString)") {
      viewModel.checkAssetsInfo(targetSize: .init(width: 20, height: 20))
    }
  }
  
  func makeScanAllButton224() -> some View {
    Button("Scan all 224 \(viewModel.countString)") {
      viewModel.checkAssetsInfo(targetSize: .init(width: 224, height: 224))
    }
  }
  
  func makeScanAllButtonDefault() -> some View {
    Button("Scan all Default \(viewModel.countString)") {
      viewModel.checkAssetsInfo(targetSize: defaultTargetSize())
    }
  }
  
  func makeScanAllButtonFull() -> some View {
    Button("Scan all Full \(viewModel.countString)") {
      viewModel.checkAssetsInfo(targetSize: PHImageManagerMaximumSize)
    }
  }
  
  func makeCheckResourceButton() -> some View {
    Button("Check Resouce") {
      viewModel.checkResource()
    }
  }
  
  func makeDeleteAllButton() -> some View {
    Button("Delete all") {
      viewModel.deleteAll()
    }
    .foregroundColor(.red)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
