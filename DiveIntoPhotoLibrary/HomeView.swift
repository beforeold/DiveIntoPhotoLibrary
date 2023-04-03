//
//  HomeView.swift
//  DiveIntoPhotoLibrary
//
//  Created by Brook_Mobius on 2023/4/3.
//

import SwiftUI

struct HomeView: View {
  @StateObject var viewModel: PhotoViewModel = .shared
  
  var body: some View {
    content
  }
  
  @ViewBuilder
  var content: some View {
    if viewModel.isAuthed {
      authedContent
    } else {
      Text("Not authed")
    }
  }
  
  var authedContent: some View {
    VStack(spacing: 20) {
      makeScanAllButton()
      
      makeDeleteAllButton()
    }
  }
  
  func makeScanAllButton() -> some View {
    Button("Scan all") {
      viewModel.checkAssetsInfo()
    }
  }
  
  func makeDeleteAllButton() -> some View {
    Button("Delete all") {
      viewModel.deleteAll()
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
