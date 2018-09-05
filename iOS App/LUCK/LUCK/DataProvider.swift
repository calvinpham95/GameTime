//  Created by Anirudh Narayan on 11/16/17.
//  Copyright © 2017 Anirudh Narayan. All rights reserved.

import Foundation
import UIKit

var currentLeagueChosen: String = String()

class DataProvider {
    
    static let sharedInstance = DataProvider()
    func getData (league : String) -> [[String:Any]]
    {
        
        currentLeagueChosen = league
        var returnResponse: [[String: Any]] = []
        
        // For now returns empty array for other leagues
        if (league == "NBA")
        {
            let semaphore = DispatchSemaphore(value: 0)
            
            // Change this depending on the league
            let url = URL(string: "http://"+ipAddress+":3000/api/game/getSevenDayNBAGames")!
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
        else if (league == "NFL")
        {
            let semaphore = DispatchSemaphore(value: 0)
            
            // Change this depending on the league
            let url = URL(string: "http://"+ipAddress+":3000/api/game/getSevenDayNFLGames")!
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
        else if (league == "NHL")
        {
            let semaphore = DispatchSemaphore(value: 0)
            
            // Change this depending on the league
            let url = URL(string: "http://"+ipAddress+":3000/api/game/getSevenDayNHLGames")!
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
        else
        {
            let semaphore = DispatchSemaphore(value: 0)
            
            // Change this depending on the league
            let url = URL(string: "http://"+ipAddress+":3000/api/game/getSevenDayPremierGames")!
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
}

class NavController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

class TabBarController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

