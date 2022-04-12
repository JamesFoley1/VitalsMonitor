//
//  ContentView.swift
//  VitalTest WatchKit Extension
//
//  Created by Daniel Mendoza on 4/11/22.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var emergencyScreenShown = false
    @State var timerVal = -1
    @State var timerScreenShown = false
    @State var heartRateFlag = false
    @State var permissionGranted = false

    let healthStore = HKHealthStore()
    
    func authorizeHealthKit() {

        let heartRate_ = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        let heartRateShared_ = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])

        healthStore.requestAuthorization(toShare: heartRateShared_, read: heartRate_) {
            (check, error) in
            if(check) {
                print("permission granted")
                permissionGranted = true
                getLatestHeartRate()
            }
            else if (error != nil) {
                print("permission denied")
            }
        }
    }
    
    func saveQuantity(type: String, device: String?, unit: String, startDate: String, endDate: String, value: String, metadata: [String : Any]?){
            // 'Authorization to share the following types is disallowed: HKQuantityTypeIdentifierWalkingHeartRateAverage' 等
            guard type != "HKQuantityTypeIdentifierAppleExerciseTime" else { return }
            guard type != "HKQuantityTypeIdentifierWalkingHeartRateAverage" else { return }
            guard type != "HKQuantityTypeIdentifierXXXXXXXXXXXXXXXX" else { return } // <- Add
    }
    
    func getLatestHeartRate() {
        if permissionGranted {
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor
            
            do {
                let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
//                let builder_ = session.associatedWorkoutBuilder()
                session.startActivity(with: Date())
                
//                builder_.beginCollection(withStart: Date()) { (success, error) in

//                    guard success else {
//                        // Handle errors.
//                        print("ERROR STARTING SESSION")
//                        print(error!)
//                        return
//                    }
//                    print(success)
//                     Indicate that the session has started.
//                }
            } catch {
                // Handle failure here.
                print("session failed")
                return
            }
            
            

            guard let currentHeartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
                return
            }
            
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: currentHeartRate, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in guard error == nil else {
                    print("error")
                    print(error!)
                    return
                }
                
                
                print("sample", sample)
                print("result", result! == [])
                if result! == [] {
                    print("No Heart Rate Data")
                }
                else {
                    print(result![0])
                    let data = result![0] as! HKQuantitySample
                    let unit = HKUnit(from: "count/min")
                    let latestHr = data.quantity.doubleValue(for: unit)
                    print("Latest Hr \(latestHr) BPM.")

                    let dateFormator = DateFormatter()
                    dateFormator.dateFormat = "dd/MM/yyyy hh:mm s"
                    let startDate = dateFormator.string(from: data.startDate)
                    let endDate = dateFormator.string(from: data.endDate)

                    print("Start Date \(startDate) : EndDate \(endDate)")
                }
            }
            healthStore.execute(query)
        }
    }
    
    var body: some View {
        VStack{
            Text("We are monitoring your health!").foregroundColor(.green)
                .padding()
            NavigationLink(destination: emergencyScreen(emergencyScreenShown: $emergencyScreenShown), isActive: $emergencyScreenShown, label: {Text("Tap if emergency!").foregroundColor(.red)})
            NavigationLink(destination: timerScreen(timerScreenShown: $timerScreenShown, emergencyScreenShown: $emergencyScreenShown), isActive: $timerScreenShown, label: {Text("Temp to Timer")})
        }.onLoad{ authorizeHealthKit() }
    }
}

struct emergencyScreen: View {
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
                    
                    Button(action:{
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
                            timer in if self.timerVal > 0 {
                                self.timerVal = 0
                            }
                        }
                    }) {
                        Text("Yes").foregroundColor(.red)
                    }
                    .tint(.red)
                    
                    Button(action:{
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
                            timer in if self.timerVal > 0 {
                                self.timerVal = -1
                            }
                        }
                    }) {
                        Text("No").foregroundColor(.green)
                    }
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

struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }

}

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


