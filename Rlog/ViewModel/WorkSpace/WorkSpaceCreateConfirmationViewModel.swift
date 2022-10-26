//
//  WorkSpaceCreateConfirmationViewModel.swift
//  Rlog
//
//  Created by 송시원 on 2022/10/25.
//
import SwiftUI

final class WorkSpaceCreateConfirmationViewModel: ObservableObject {
    @Binding var isActive: Bool
    var workspaceData: CreatingWorkSpaceModel
    var scheduleData: [CreatingScheduleModel]


    init(isActive: Binding<Bool>, workspaceData: CreatingWorkSpaceModel, scheduleData: [CreatingScheduleModel]) {
        self._isActive = isActive
        self.workspaceData = workspaceData
        self.scheduleData = scheduleData
    }

    let hasTax = false
    let hasJuhyu = false
    func didTapConfirmButton() {
        popToRoot()
        writeCoredata()
    }
}
extension WorkSpaceCreateConfirmationViewModel {
    func popToRoot() {
        isActive = false
    }
    func writeCoredata() {
        // 코어데이터에 저장하는 함수를 구현
    }
}
