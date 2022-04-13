//
//  ContentView.swift
//  VitalTest WatchKit Extension
//
//  Created by Daniel Mendoza and James Foley on 4/11/22.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var emergencyScreenShown = false
    @State var permissionGranted = false
    @State var timerScreenShown = false
    @State var timerVal = -1

    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    @State private var value = 0
    
    var body: some View {
        VStack{
            Text("We are monitoring...").foregroundColor(.green)
                .font(.system(size: 20))

            HStack{
                Text("❤️")
                    .font(.system(size: 20))

                Text("\(value)")
                    .fontWeight(.regular)
                    .font(.system(size: 35))
                
                Text("BPM")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
            }

            NavigationLink(destination: emergencyScreen(emergencyScreenShown: $emergencyScreenShown), isActive: $emergencyScreenShown, label: {Text("Tap if emergency!").foregroundColor(.red)})
            NavigationLink(destination: timerScreen(timerScreenShown: $timerScreenShown, emergencyScreenShown: $emergencyScreenShown), isActive: $timerScreenShown) {
                EmptyView()
            }.hidden()
        }
        .padding()
        .onAppear(perform: start)
    }

    
    func start() {
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                query, samples, deletedObjects, queryAnchor, error in
            
                guard let samples = samples as? [HKQuantitySample] else {
                    return
            }
            
            self.process(samples, type: quantityTypeIdentifier)

        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            self.value = Int(lastHeartRate)
        }
        
        if lastHeartRate > 100 || lastHeartRate < 40 {
//            NavigationLink(destination: timerScreen(timerScreenShown: $timerScreenShown, emergencyScreenShown: $emergencyScreenShown), isActive: $timerScreenShown, label: {Text("Temp to Timer")})
//            timerScreen(timerScreenShown: $timerScreenShown, emergencyScreenShown: $emergencyScreenShown)
            timerScreenShown = true
        }
                
    }
}

struct emergencyScreen: View {
    @Binding var emergencyScreenShown:Bool

    var body: some View{
        Text("Message has been sent to caretaker!").foregroundColor(.yellow).padding()
    }
}

public struct timerScreen: View {
    @Binding var timerScreenShown:Bool
    @Binding var emergencyScreenShown:Bool
    @State var timerVal = 60

    public var body: some View {
        VStack{
            Text("Emergency?").font(.system(size: 14))
            Text("\(timerVal)").font(.system(size: 40)).onAppear(){
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
                    timer in if self.timerVal > 0 {
                        self.timerVal -= 1
                        if timerVal == 0 {
                            emergencyScreenShown = true
                        }
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
                    emergencyScreenShown = true
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
                    timerScreenShown = false
                }) {
                    Text("No").foregroundColor(.green)
                }
                .tint(.green)
            }
        }
    }
}

//may not need these two views
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
