//
//  WorkSpaceCreateConfirmationViewModel.swift
//  Rlog
//
//  Created by 송시원 on 2022/10/25.
//
import SwiftUI

final class WorkSpaceCreateConfirmationViewModel: ObservableObject {
    @Binding var isActive: Bool

    var workspaceData: WorkSpaceModel
    var scheduleData: [ScheduleModel]

    init(isActive: Binding<Bool>, workspaceData: WorkSpaceModel, scheduleData: [ScheduleModel]) {
        self._isActive = isActive
        self.workspaceData = workspaceData
        self.scheduleData = scheduleData
    }

    private let hasTax = false
    private let hasJuhyu = false

    func didTapConfirmButton(completion: @escaping (() -> Void)) {
        Task {
            await createDatas()
            completion()
            popToRoot()
        }
    }
}

// MARK: - Private Functions
private extension WorkSpaceCreateConfirmationViewModel {
    func popToRoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isActive = false
        }
    }

    func createDatas() async {
        Task {
            await createWorkspace()
            await createSchedules()
        }
    }

    func createWorkspace() async {
        guard let random = WorkspaceColor.allCases.randomElement(),
              let hourlyWage = Int16(workspaceData.hourlyWage),
              let paymentDay = Int16(workspaceData.paymentDay)
        else { return }

        CoreDataManager.shared.createWorkspace(
            name: workspaceData.name,
            hourlyWage: hourlyWage,
            paymentDay: paymentDay,
            colorString: random.name,
            hasTax: workspaceData.hasTax,
            hasJuhyu: workspaceData.hasJuhyu
        )
    }

    func createSchedules() async {
        let workspace = CoreDataManager.shared.getWorkspace(by: workspaceData.name)
        for schedule in scheduleData {

            guard let startHour = Int16(schedule.startHour),
                  let startMinute = Int16(schedule.startMinute),
                  let endHour = Int16(schedule.endHour),
                  let endMinute = Int16(schedule.endMinute) else { return }

            let spentHour = calculateSpentHour(
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute
            )

            guard let workspace = workspace else { return }

            CoreDataManager.shared.createSchedule(
                of: workspace,
                repeatedSchedule: schedule.repeatedSchedule,
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute,
                spentHour: spentHour
            )
        }
    }

    func calculateSpentHour(startHour: Int16, startMinute: Int16, endHour: Int16, endMinute: Int16) -> Double {
        let formatter = DateFormatter(dateFormatType: .timeAndMinute)

        let startDate = formatter.date(from: "\(startHour):\(startMinute)")
        let endDate = formatter.date(from: "\(endHour):\(endMinute)")

        guard let startDate = startDate,
              let endDate = endDate else { return 0.0 }

        let timeInterval = endDate.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate

        return (timeInterval / 3600)
    }
}
