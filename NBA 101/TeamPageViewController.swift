//
//  TeamPageViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class TeamPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
    }
    
    func createTeam

}

extension TeamPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    
}
