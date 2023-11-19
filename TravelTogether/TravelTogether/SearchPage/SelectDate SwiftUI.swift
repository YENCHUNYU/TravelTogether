//
//  SelectDate SwiftUI.swift
//  TravelTogether
//
//  Created by User on 2023/11/19.
//

import SwiftUI

struct DatePickerView: View {
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var isStartDatePickerPresented = false
    @State private var isEndDatePickerPresented = false
    var dateChanged: ((Date, Date) -> Void)?
    
    var body: some View {
        HStack {
            Text("\(startDate, formatter: dateFormatter)")
                .onTapGesture {
                    isStartDatePickerPresented.toggle()
                }
                .popover(isPresented: $isStartDatePickerPresented) {
                    VStack {
                        DatePicker(
                            "",
                            selection: $startDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                        .onChange(of: startDate) { newDate in
                            dateChanged?(newDate, endDate)
                                    }
                        Button("確定") {
                            isStartDatePickerPresented.toggle()
                           
                        }
                    }}
            
            Spacer() // 加入 Spacer 來平均分配兩個 DatePicker 之間的空間
            
           Text("\(endDate, formatter: dateFormatter)")
               .onTapGesture {
                   isEndDatePickerPresented.toggle()
               }
               .popover(isPresented: $isEndDatePickerPresented) {
                   DatePicker(
                       "",
                       selection: $endDate,
                       in: startDate...,
                       displayedComponents: [.date]
                   )
                   .datePickerStyle(GraphicalDatePickerStyle())
                   .labelsHidden()
                   .environment(\.locale, Locale(identifier: "zh_CN"))
                   .onChange(of: endDate) { newDate in
                       dateChanged?(startDate, newDate)}
                
                   Button("確定") {
                   isEndDatePickerPresented.toggle()
               }
               }
       }
        .padding()
    }
    
    var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
    return formatter
        }
}
