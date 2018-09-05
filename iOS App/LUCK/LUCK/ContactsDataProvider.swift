//
//  ContactsDataProvider.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/17/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import Foundation
import UIKit
import SwiftAddressBook
import AddressBook

class ContactsDataProvider {
    
    
    
    static let sharedInstance = ContactsDataProvider()
    func getData () -> [[String:Any]]
    {
        
       //print("Getting all user phone numbers")
        var returnResponse: [[String: Any]] = []
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        
        let url = URL(string: "http://"+ipAddress+":3000/api/godView")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            returnResponse = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        
        return returnResponse
        
    }
}


