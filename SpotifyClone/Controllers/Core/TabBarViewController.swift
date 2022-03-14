//
//  TabBarViewController.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 12/12/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var viewControllers : [Int : [UITabBarItem : UIViewController]] = [:]
        
        viewControllers[0] = [UITabBarItem(title: "Library", image: UIImage(systemName: "book"), tag: 1) : LibraryViewController()]
        viewControllers[1] = [UITabBarItem(title: "Browse", image: UIImage(systemName: "house"), tag: 2) : HomeViewController()]
        viewControllers[2] = [UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 3) :
            SearchViewController()]
        
        var uiNavigationControllers: [UINavigationController] = []
        
        for (_, value) in viewControllers.sorted(by: { $0.0 < $1.0 }){
            guard let tabBarItem = value.first?.key, let vc = value.first?.value else{
                continue
            }
            
            vc.title = tabBarItem.title
            vc.navigationItem.largeTitleDisplayMode = .always
            let nav = UINavigationController(rootViewController: vc)
            nav.tabBarItem = tabBarItem
            uiNavigationControllers.append(nav)
        }
        uiNavigationControllers.forEach { nc in
            nc.navigationBar.prefersLargeTitles = true
            nc.navigationBar.tintColor = .label
        }
        
        setViewControllers(uiNavigationControllers, animated: true)
        view.backgroundColor = .systemBackground
    }

}
