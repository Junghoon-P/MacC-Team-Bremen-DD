//
//  WorkSpaceCreateScheduleListViewModel.swift
//  Rlog
//
//  Created by 송시원 on 2022/10/20.
//

import SwiftUI

final class WorkSpaceCreateScheduleListViewModel: ObservableObject {
    @Published var isShowingModal = false
    @Published var isShowingConfirmButton = false
    
    @Published var scheduleList: [Schedule] = [] {
        didSet {
            if !scheduleList.isEmpty {
                isShowingConfirmButton = true
            }
            isShowingConfirmButton = true
        }
    }
    
    func didTapAddScheduleButton() {
        showModal()
    }
}

extension WorkSpaceCreateScheduleListViewModel {
    func showModal() {
        isShowingModal = true
    }
}

struct Schedule: Hashable{
    var repeatedSchedule: [String] = []
    var startHour: String = ""
    var startMinute: String = ""
    var endHour: String = ""
    var endMinute: String = ""
}
