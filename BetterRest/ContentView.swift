//
//  ContentView.swift
//  BetterRest
//
//  Created by George Patterson on 07/02/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var amountOfSleep = 8.0
    @State private var wakeUp = defaultWakeTime //accesses static instance in body
    @State private var coffeeAmount = 1
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        //Dates are hard becuase times go back and forth as well as leap years etc
        //Swift has a slightly different type for that purpose, called DateComponents, which lets us read or write specific parts of a date rather than the whole thing.
        
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please select a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired Sleep").font(.headline)
                    
                    Stepper(value: $amountOfSleep, in: 4...12, step: 0.25) {
                        Text("\(amountOfSleep, specifier: "%g") hours")
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake").font(.headline)
                    Stepper(value: $coffeeAmount, in: 1 ... 10) {
                        if coffeeAmount == 1 {
                            Text("1 Cup")
                        }
                        else {
                            Text("\(coffeeAmount) cups")
                        }
                    }
                }
            }
                .navigationBarTitle("BetterRest")
                .navigationBarItems(trailing: Button(action: calculateBedtime) { //calculateBedtime is a closure and therefore doesn't require the need for () on the action. This is a distinguishable concept of closures and functions
                    Text("Calculate") //button text
                }
                ).alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

        }
    }
    
        //we have to make this cariable static. This means that it can be accessed from outside this struct
    
        static var defaultWakeTime: Date {
            var components = DateComponents()
            components.hour = 7
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }
        
        func calculateBedtime() {
            let model = SleepCalculator() //defines our model from the ml file
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
       
            do {
                let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: amountOfSleep, coffee: Double(coffeeAmount))
                //this tries to get a prediction using the input params from wakeup time
                
                let sleepTime = wakeUp - prediction.actualSleep
                //calculates the time you should sleep for
                
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                alertMessage = formatter.string(from: sleepTime)
                alertTitle = "Your ideal bedtime is .."
                
            } catch {
                alertTitle = "error"
                alertMessage = "Couldn't calculate bedtime"
            }
            
            showingAlert = true
        
        }
        

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

