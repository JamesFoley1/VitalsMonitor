//
//  ContentView.swift
//  VitalTest WatchKit Extension
//
//  Created by Daniel Mendoza on 4/11/22.
//

import SwiftUI

struct ContentView: View {
    @State var emergencyScreenShown = false
    @State var timerVal = -1
    @State var timerScreenShown = false
    @State var heartRateFlag = false
    var body: some View {
        VStack{
            Text("We are monitoring your health!").foregroundColor(.green)
                .padding()
            NavigationLink(destination: emergencyScreen(emergencyScreenShown: $emergencyScreenShown), isActive: $emergencyScreenShown, label: {Text("Tap if emergency!").foregroundColor(.red)})
            NavigationLink(destination: timerScreen(timerScreenShown: $timerScreenShown, emergencyScreenShown: $emergencyScreenShown), isActive: $timerScreenShown, label: {Text("Temp to Timer")})
        }
    }
}

struct emergencyScreen: View{
    @Binding var emergencyScreenShown:Bool
    var body: some View{
        Text("Message has been sent to caretaker!").foregroundColor(.yellow).padding()
    }
}

struct timerScreen: View{
    @Binding var timerScreenShown:Bool
    @Binding var emergencyScreenShown:Bool
    //@state var heartRateFlag = true
    @State var timerVal = 5
    var body: some View {
        VStack{
            if timerVal > 0 {
                Text("Emergency?").font(.system(size: 14))
                Text("\(timerVal)").font(.system(size: 40)).onAppear(){
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
                        timer in if self.timerVal > 0 {
                            self.timerVal -= 1
                        }
                    }
                }
                Text("Please Respond").font(.system(size: 14))
                
                HStack{
                    //Yes button
                    NavigationLink(destination: emergencyScreen(emergencyScreenShown: $emergencyScreenShown), isActive: $emergencyScreenShown, label: {Text("Yes").foregroundColor(.red)})
                    .tint(.red)
                    
                    //No button
                    NavigationLink(destination: ContentView(),label: {Text("No").foregroundColor(.green)})
                    .tint(.green)
                    
                    
                    
                }
            }
            else if(timerVal==0){
                emergencyScreen(emergencyScreenShown: $emergencyScreenShown)
            }
            else{
                ContentView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


