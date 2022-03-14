//
//  WelcomeViewController.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 12/12/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton: UIButton = {
        let button =  UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        view.tintColor = .systemFill
        title = "Spotify"
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(onTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 20,
                                    y: view.height-50-view.safeAreaInsets.bottom,
                                    width: view.width-40,
                                    height: 50)
        
    }
    
    @objc func onTapSignIn(){
        let viewController = AuthViewController()
        viewController.completionHandler = { [weak self] success in
            DispatchQueue.main.async{
                self?.handleSignIn(success: success)
            }
        }
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func handleSignIn(success: Bool){
        guard success else {
            let alert = UIAlertController(title: "Oops!", message: "Something went wrong with your authentication.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil ))
            present(alert, animated: true)
            return
        }
        
        let mainAppTabBarViewController = TabBarViewController()
        mainAppTabBarViewController.modalPresentationStyle = .fullScreen
        present(mainAppTabBarViewController, animated: true)
    }
    

}