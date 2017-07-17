//
//  AppDelegate.swift
//  Decibel
//
//  Created by Peter Reinhardt on 8/13/16.
//  Copyright © 2016 Peter Reinhardt. All rights reserved.
//

import UIKit

/*
 NOTE: PLEASE PUT YOUR DATADOG KEY BELOW
 */
let DATADOG_KEY = "YOUR_KEY_HERE"
/*
 NOTE: PLEASE PUT YOUR DATADOG KEY ABOVE
 */


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        
        return true
    }
    
    
    func sendDatadogDatapoint(average: Float, peak: Float) {
        // Send a single datapoint to DataDog
        let datadogUrlString = "https://app.datadoghq.com/api/v1/series?api_key=\(DATADOG_KEY)"
        
        let deviceName = UIDevice.current.name
        let timestamp = (NSInteger)(Date().timeIntervalSince1970)
        let body = [
            "series": [
                ["metric": "office.dblevel.average", "host": deviceName, "points": [ [timestamp, average] ] ],
                ["metric": "office.dblevel.peak", "host": deviceName, "points":[ [timestamp, peak] ] ],
            ]
        ]
        
        guard let datadogUrl = URL(string: datadogUrlString),
            let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Bad URL or body")
            return
        }
        print("Will send request to \(datadogUrl)", body)
        
        let request = NSMutableURLRequest(url: datadogUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let error = error {
                print("error=\(error)")
                return
            }
            if let data = data {
                let responseString = String(data: data, encoding: String.Encoding.utf8)
                print("responseString = \(responseString)")
                return
            }
            print("Neither error nor data was provided")
        }
        task.resume()
    }

}

