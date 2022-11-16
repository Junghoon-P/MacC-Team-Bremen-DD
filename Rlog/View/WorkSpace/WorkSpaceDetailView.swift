//
//  WorkSpaceDetailView.swift
//  Rlog
//
//  Created by 송시원 on 2022/10/17.
//

import SwiftUI

// TODO: 완료 Button isActive 기능 추가하기
// TODO: 근무지 삭제 Alert 구현
// TODO: Schedule 추가하기

enum WorkSpaceDetailInfo: CaseIterable {
    case hasTax
    case hasJuhyu
    
    var text: (title: String, description: String) {
        switch self {
        case .hasTax: return (title: "소득세", description: "3.3% 적용")
        case .hasJuhyu: return (title: "주휴수당", description: "60시간 근무 시 적용")
        }
    }
}

struct WorkSpaceDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkSpaceDetailViewModel
    
    init() {
        viewModel = WorkSpaceDetailViewModel()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                InputFormElement(containerType: .workplace, text: $viewModel.name)
                InputFormElement(containerType: .wage, text: $viewModel.hourlyWageString)
                InputFormElement(containerType: .payday, text: $viewModel.paymentDayString)
                makePaymentSystemToggle()
                
                Text("근무패턴")
                    .font(.caption)
                    .foregroundColor(.grayMedium)
                    .padding(.bottom, -16)
                
                //                ForEach(viewModel.schedules) { schedule in
                ScheduleContainer(
                    repeatedSchedule: ["월 화 수 목"],
                    startHour: "10",
                    startMinute: "00",
                    endHour: "12",
                    endMinute: "00"
                )
                //                }
                .padding(.bottom, -8)
                
                StrokeButton(label: "+ 근무패턴 추가", buttonType: .add) {
                }
                .padding(.bottom, -8)
                
                HDivider()
                
                StrokeButton(label: "근무지 삭제", buttonType: .destructive) {
                }
                .alert("근무지 삭제", isPresented: $viewModel.isAlertOpen) {
                    Button("취소", role: .cancel) {
                    }
                    Button("삭제", role: .destructive) {
                        
                    }
                } message: {
                    Text("해당 근무지를 삭제합니다.?")
                }
                .padding(.top, -8)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 24, leading: 16, bottom: 0, trailing: 16))
        }
        .navigationTitle("근무수정")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }){
                    Image(systemName: "chevron.left")
                        .foregroundColor(.fontBlack)
                    Text("이전")
                        .foregroundColor(.fontBlack)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                }){
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                }
            }
        }
        .background(Color.backgroundWhite)
        .navigationBarBackButtonHidden()
    }
}

private extension WorkSpaceDetailView {
    @ViewBuilder
    func makePaymentSystemToggle() -> some View {
        ForEach(WorkSpaceDetailInfo.allCases, id: \.self) { tab in
            Toggle(isOn: tab == .hasTax ? $viewModel.hasTax : $viewModel.hasJuhyu, label: {
                HStack(spacing: 13) {
                    Text(tab.text.title)
                        .font(.body)
                        .foregroundColor(.grayMedium)
                    Text(tab.text.description)
                        .font(.caption)
                        .foregroundColor(.grayMedium)
                }
            })
        }
    }
    
    @ViewBuilder
    func schedulesContainer() -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                //                ForEach(schedule.repeatedSchedule, id:\.self) { weekDay in
                //                    Text(weekDay)
                //                        .font(.body)
                //                        .foregroundColor(.fontBlack)
                //                        .padding(.horizontal, 1)
                //                }
            }
            .padding(.trailing, 3)
            Spacer()
            Text("11 : 00 - 12 : 00")
                .font(.body)
                .foregroundColor(.fontBlack)
            Button {
            } label: {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
                    .padding(.leading, 16)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 54)
        .background(Color.backgroundWhite)
        .cornerRadius(10)
    }
}


