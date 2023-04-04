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
      Text("waiting")
    }
  }
  
  var authedContent: some View {
    VStack(spacing: 20) {
      Text("assets \(viewModel.countString)")
        .foregroundColor(.gray)
      makeScanAllButton20()
      makeScanAllButton224()
      makeScanAllButtonDefault()
      makeScanAllButton600()
      makeScanAllButtonFull()
      
      makeCheckResourceButton()
      
      makeDeleteAllButton()
    }
  }
  
  func makeScanAllButton20() -> some View {
    Button("Scan all 20") {
      viewModel.checkAssetsInfo(targetSize: .init(width: 20, height: 20))
    }
  }
  
  func makeScanAllButton224() -> some View {
    Button("Scan all 224") {
      viewModel.checkAssetsInfo(targetSize: .init(width: 224, height: 224))
    }
  }
  
  func makeScanAllButtonDefault() -> some View {
    Button("Scan all Default") {
      viewModel.checkAssetsInfo(targetSize: defaultTargetSize())
    }
  }
  
  func makeScanAllButton600() -> some View {
    Button("Scan all 600") {
      viewModel.checkAssetsInfo(targetSize: .init(width: 1000, height: 1000))
    }
  }
  
  func makeScanAllButtonFull() -> some View {
    Button("Scan all Full)") {
      viewModel.checkAssetsInfo(targetSize: PHImageManagerMaximumSize)
    }
  }
  
  func makeCheckResourceButton() -> some View {
    Button("Check Resouce -> \(viewModel.resourceString)") {
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
