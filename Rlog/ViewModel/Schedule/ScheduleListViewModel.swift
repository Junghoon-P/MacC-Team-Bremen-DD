//
//  MonthlyCalculateListViewModel.swift
//  Rlog
//
//  Created by 송시원 on 2022/10/17.
//

import SwiftUI

enum ScheduleCase: String, CaseIterable {
    case upcoming = "예정된 일정"
    case past = "지나간 일정"
}

final class ScheduleListViewModel: ObservableObject {
    @Published var selectedScheduleCase: ScheduleCase = .upcoming
    @Published var allWorkDays: [WorkDayEntity] = []
    @Published var isShowCreateModal = false
    var upcomingWorkDays: [WorkDayEntity] = []
    var pastWorkDays: [WorkDayEntity] = []
    let yearAndMonth: String = Date().fetchYearAndMonth()
    
    init() {
        fetchAllWorkDays()
    }
    
    func didSheetDismissed() {
        fetchAllWorkDays()
    }
    
    func didTapPlusButton() {
        isShowCreateModal.toggle()
    }
    
    func onAppear() {
        initWorkDays()
    }
}

private extension ScheduleListViewModel {
    func fetchAllWorkDays() {
        let result = CoreDataManager.shared.getAllWorkspaces()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for workspace in result {
                self.allWorkDays.append(contentsOf: CoreDataManager.shared.getWorkdays(
                    of: workspace,
                    yearInt: Calendar.current.component(.year, from: Date()),
                    monthInt: Calendar.current.component(.month, from: Date()),
                    limit: 20)
                )
            }
            self.upcomingWorkDays = self.allWorkDays.filter { self.isUpcomming(day: $0.dayInt) }
            self.pastWorkDays = self.allWorkDays.filter { !self.isUpcomming(day: $0.dayInt) }
        }
    }
    
    func initWorkDays() {
        let allSchedules = CoreDataManager.shared.getAllSchedules()
        var date = Date()
    }
    
    // TODO: - 날짜 struct 만들기
    func isUpcomming(day: Int16) -> Bool {
        if day >= Calendar.current.component(.day, from: Date()) {
            return true
        }
        return false
    }
}

final class StatusPickerViewModel: ObservableObject {
    @Binding var selectedScheduleCase: ScheduleCase
    let scheduleCases = ScheduleCase.allCases
    var statusPickerOffset: CGFloat {
        selectedScheduleCase == .upcoming ? -40 : 40
    }
    
    init(selectedScheduleCase: Binding<ScheduleCase>) {
        self._selectedScheduleCase = selectedScheduleCase
    }
    
    func getStatusPickerTextWeight(compareCase: ScheduleCase) -> Font.Weight {
        return selectedScheduleCase == compareCase ? Font.Weight.bold : Font.Weight.regular
    }
    
    func getStatusPickerForegroundColor(compareCase: ScheduleCase) -> Color {
        return selectedScheduleCase == compareCase ? .white : Color.fontLightGray
    }
}

final class ScheduleCellViewModel: ObservableObject {
    @Published var isShowUpdateModal = false
    var workDay: WorkDay
    var workDayEntity: WorkDayEntity
    var didDismiss: () -> Void
    var isShowConfirmButton: Bool {
        if isToday(month: workDay.monthInt, day: workDay.dayInt) {
            return !workDay.hasDone
        }
        return false
    }
    
    init(workDayEntity: WorkDayEntity, didDismiss: @escaping () -> Void) {
        self.workDayEntity = workDayEntity
        self.workDay = WorkDay(
            weekDay: workDayEntity.weekDay,
            yearInt: workDayEntity.yearInt,
            monthInt: workDayEntity.monthInt,
            dayInt: workDayEntity.dayInt,
            startHour: workDayEntity.startHour,
            startMinute: workDayEntity.startMinute,
            endHour: workDayEntity.endHour,
            endMinute: workDayEntity.endMinute,
            hasDone: workDayEntity.hasDone,
            spentHour: workDayEntity.spentHour,
            workDayType: workDayEntity.workDayType
        )
        self.didDismiss = didDismiss
    }
    
    func didTapConfirmButton() {
        Task {
            try? await updateHasDone()
        }
    }
    
    func didTapEditButton() {
        isShowUpdateModal.toggle()
    }
}

private extension ScheduleCellViewModel {
    func updateHasDone() async throws {
        workDay.hasDone = true
        CoreDataManager.shared.editWorkday(
            of: workDayEntity,
            weekDay: workDay.weekDay,
            yearInt: workDay.yearInt,
            monthInt: workDay.monthInt,
            dayInt: workDay.dayInt,
            startHour: workDay.startHour,
            startMinute: workDay.startMinute,
            endHour: workDay.endHour,
            endMinute: workDay.endMinute,
            spentHour: workDay.spentHour,
            hasDone: workDay.hasDone,
            workDayType: workDay.workDayType
        )
    }
    
    // TODO: - 날짜 struct 만들기
    func isToday(month: Int16, day: Int16) -> Bool {
        if month == Calendar.current.component(.month, from: Date()) {
            if day == Calendar.current.component(.day, from: Date()) {
                return true
            }
        }
        return false
    }
}
