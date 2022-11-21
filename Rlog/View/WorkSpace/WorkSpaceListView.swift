//
//  WorkSpaceListView.swift
//  Rlog
//
//  Created by 송시원 on 2022/10/17.
//

import SwiftUI

struct WorkSpaceListView: View {
    @StateObject private var viewModel = WorkspaceListViewModel()
    
    var body: some View {
        NavigationView {
            workspaceList
        }
    }
}

private extension WorkSpaceListView {
    var workspaceList: some View {
        VStack(spacing: 0){
            HStack(){
                Text("근무지")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.fontBlack)
                
                Spacer()
                
                NavigationLink(
                    destination: WorkspaceCreateView(isActive: $viewModel.isShowingSheet),
                    isActive: $viewModel.isShowingSheet) {
                        
                        Image("plus.curved")
                            .foregroundColor(Color.primary)
                    }
            }
            .padding(EdgeInsets(top: 27, leading: 16, bottom: 24, trailing: 16))
            
            ScrollView {
                ForEach(viewModel.workspaces, id: \.self) { workspace in
                    WorkspaceCell(workspace: workspace)
                }
            }
        }
        .navigationBarTitle("", displayMode: .automatic)
        .navigationBarHidden(true)
        .background(Color.backgroundWhite)
        .onAppear {
            viewModel.onAppear()
        }
        
    }
}
