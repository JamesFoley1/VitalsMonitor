//
//  ContentView.swift
//  VitalsMonitor WatchKit Extension
//
//  Created by James Foley on 4/9/22.
//

import SwiftUI

struct ContentView: View {
    @State var secondScreenShown = false
    @State var timerVal = 60
    
    var body: some View {
        VStack{
            Text("We are monitoring your health!").font(.system(size: 14)).foregroundColor(.green)
        }
    }
}

struct EmergencyResponse: View {
    @Binding var secondScreenShown: Bool
    @State var timerVal: Int
    var body : some View {
        VStack{
            if timerVal > 0 {
                Text("Emergency?").font(.system(size: 14))
                Text("\(timerVal)").font(.system(size: 40))
                    .onAppear(){
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                            _ in if self.timerVal > 0 {
                                self.timerVal -= 1
                            }
                        }
                    }
                Text("Please Respond").font(.system(size: 14))
                
                HStack{
                    Button(action: {
                        self.secondScreenShown = false
                        NSLog("send alert to api")
                    }) {
                        Text("Yes").foregroundColor(.red)
                    }
                    .tint(.red)
                    
                    
                    Button(action: {
                        self.secondScreenShown = false
                        NSLog("Go back to monitoring")
    //                        Consider a using a minimum / maximum time to monitor for emergency...
                    }) {
                        Text("No").foregroundColor(.green)
                    }
                    .tint(.green)
                }
                
                
            } else {
                Button(action: {
                    self.secondScreenShown = false
                }) {
                    Text("Done").foregroundColor(.green)
                }
                .tint(.green)
            }
        }
     }
}

//struct SecondView: View {
//    @Binding var secondScreenShown: Bool
//    @State var timerVal: Int
//    var body: some View {
//        VStack{
//
//
//
//            Text("Start Timer for \(timerVal) seconds")
//            Picker(selection: $timerVal, label: Text("")) {
//                Text("60").tag(60)
//                Text("50").tag(50)
//                Text("40").tag(40)
//                Text("30").tag(30)
//                Text("20").tag(20)
//                Text("10").tag(10)
//            }
//            NavigationLink(destination: SecondView(secondScreenShown: $secondScreenShown, timerVal: timerVal), isActive: $secondScreenShown, label: { Text("Go")})
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
