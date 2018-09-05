//
//  CreateBetViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/16/17.
//  Copyright © 2017 Anirudh Narayan. All rights reserved.
//

import UIKit
import Foundation
import XLPagerTabStrip

class CreateBetViewController: ButtonBarPagerTabStripViewController, ChainUp {
    
    func chainUp1() {
        dele?.chainUp2()
    }
    
    func chainUp2()
    {
        
    }
    
    var dele: ChainUp?
    var isReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Here is the code to change strip bar color
        buttonBarView.selectedBar.backgroundColor = .black
        buttonBarView.backgroundColor = UIColor(red: 26/255, green: 164/255, blue: 122/255, alpha: 100)
        buttonBarView.backgroundColor = UIColor(red: 26/255, green: 164/255, blue: 122/255, alpha: 100)
        settings.style.buttonBarBackgroundColor = UIColor(red: 26/255, green: 164/255, blue: 122/255, alpha: 100)
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 26/255, green: 164/255, blue: 122/255, alpha: 100)
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 18)
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "NBA")
        let child_2 = TableChildExampleViewController(style: .plain, itemInfo: "NFL")
        let child_3 = TableChildExampleViewController(style: .plain, itemInfo: "NHL")
        let child_4 = TableChildExampleViewController(style: .plain, itemInfo: "EPL")
        
        child_1.delegate = self
        child_2.delegate = self
        child_3.delegate = self
        child_4.delegate = self
        
        
        guard isReload else {
            // need to change also if another child is added
            return [child_1, child_2, child_3, child_4]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4]
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ChooseContactsSegue"{
//            let vc = segue.destination as! ContactsViewController
//            vc.team1Name = firstTeam
//            vc.team2Name = secondTeam
//        }
//    }
}

