//
//  MonthlyCalculateDetailViewModel.swift
//  Rlog
//
//  Created by 정지혁 on 2022/11/14.
//

import Foundation

@MainActor
final class MonthlyCalculateDetailViewModel: ObservableObject {
    let calculateResult: MonthlyCalculateResult
    @Published var calendarDays: [Date] = []
    @Published var emptyCalendarDays: [Int] = []

    @Published var startDate = Date()
    @Published var target = Date()

    let current: Date
    let workTypeManager = WorkTypeManager()
    let timeManager = TimeManager()
    
    var notRegularWorkdays: [WorkdayEntity] {
        return calculateResult.hasDoneWorkdays.filter { workTypeManager.defineWorkType(workday: $0) != .regular }
    }

    init(calculateResult: MonthlyCalculateResult) {
        self.calculateResult = calculateResult
        self.current = calculateResult.currentMonth
        Task {
            await makeCalendarDates()
            makeEmptyCalendarDates()
        }
    }

    func calculateLeftDays() -> Int {
        let components = Calendar.current.dateComponents([.day], from: current, to: target)
        guard let leftDay = components.day else { return 0 }
        return leftDay
    }

    func filterWorkday(for day: Date) -> [WorkdayEntity] {
        return calculateResult.hasDoneWorkdays.filter{ $0.date == day }
    }
    
    func getSpentHour(_ endTime: Date, _ startTime: Date) -> String {
        let timeGap = endTime - startTime
        let result = timeManager.secondsToHoursMinutesSeconds(timeGap)
        
        return result.1 < 30 ? "\(result.0)시간" : "\(result.0)시간 \(result.1)분"
    }
}

private extension MonthlyCalculateDetailViewModel {
    func makeCalendarDates() async {
        let payDay = calculateResult.workspace.payDay
        let yearMonthDayFormatter = DateFormatter(dateFormatType: .yearMonthDay)
        let dayInt = current.dayInt
        let monthInt = current.monthInt
        let yearInt = current.yearInt

        var range = Date()

        if dayInt < payDay {
            let previousMonth = monthInt - 1
            let rangeString = "\(yearInt)/\(previousMonth)/\(payDay)"
            let targetString = "\(yearInt)/\(monthInt)/\(payDay)"
            range = yearMonthDayFormatter.date(from: rangeString)!
            target = yearMonthDayFormatter.date(from: targetString)!
            startDate = range
        } else {
            let nextMonth = monthInt + 1
            let rangeString = "\(yearInt)/\(monthInt)/\(payDay)"
            let targetString = "\(yearInt)/\(nextMonth)/\(payDay)"
            range = yearMonthDayFormatter.date(from: rangeString)!
            target = yearMonthDayFormatter.date(from: targetString)!
            startDate = range
        }

        while range < target {
            calendarDays.append(range)
            guard let next = Calendar.current.date(byAdding: DateComponents(day: 1), to: range) else { return }
            range = next
        }
    }

    func makeEmptyCalendarDates() {
        for count in 0..<startDate.weekDayInt - 1 {
            emptyCalendarDays.append(count)
        }
    }
}
