//
//  ProfileViewController.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 12/12/21.
//

import SDWebImage
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var models = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        fetchProfile()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        view.tintColor = .systemFill
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    
    private func fetchProfile(){
        APICaller.shared.getCurrentUserProfile(){ [weak self] success in
            DispatchQueue.main.async {
                switch success {
                case .success(let model):
                    self?.updateUI(with: model)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.onFailedToGetProfile()
                    break
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile){
        tableView.isHidden = false
        //
        models.append("Full Name: \(model.display_name)")
        models.append("E-mail: \(model.email)")
        models.append("User ID: \(model.id)")
        models.append("Plan: \(model.product)")
        models.append("Full Name: \(model.display_name)")
        //
        createTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }
    
    private func createTableHeader(with string: String?){
        //GET IMAGELINK AND SEE IF IT'S LOCAL/URL
        let urlString = string != nil ? ["url": string] : ["local": "placeholder-user"]
        guard let image = urlString.first else {
            return
        }
        let isURL = image.key == "url"
        let imageLink = image.value!
        
        //CREATE IMAGEVIEW
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize: CGFloat = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        if isURL {
            let url = URL(string: imageLink)
            imageView.sd_setImage(with: url, completed: nil)
        }else {
            imageView.image = UIImage(named: imageLink)
        }
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        
        tableView.tableHeaderView = headerView
    }
    
    private func onFailedToGetProfile(){
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile data."
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    // MARK: - TABLEVIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    

}
