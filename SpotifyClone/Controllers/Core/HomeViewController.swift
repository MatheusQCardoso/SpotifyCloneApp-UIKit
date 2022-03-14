//
//  ViewController.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 12/12/21.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    var collectionView: UICollectionView!
    
    private var sections = [BrowseSectionType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettings))
        
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        spinner.color = .systemFill
        view.backgroundColor = .systemBackground
        view.tintColor = .systemFill
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout:
            UICollectionViewCompositionalLayout{ [weak self] sectionIndex, _ -> NSCollectionLayoutSection in
            return (self?.sectionLayout(for: sectionIndex))!
            }
        )

        view.addSubview(collectionView)
        collectionView.register(UICollectionViewListCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self,
                                forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.tintColor = .systemFill
    }
    
    //MARK: - COLLECTIONVIEW

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else{
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.contentView.backgroundColor = .systemRed
            return cell
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.backgroundView?.backgroundColor = .systemBlue
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedTrackCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.backgroundView?.backgroundColor = .systemGreen
            return cell
        }
    }
    
    private func fetchData(){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlaylists: FeaturedPlaylistsResponse?
        var recommendedTracks: RecommendationsResponse?
        
        //NEW RELEASES
        APICaller.shared.getNewReleases{ result in
            defer{
                group.leave()
            }
            switch result{
            case .success(let model):
                newReleases = model
                break
            case .failure(let error):
                print("ERR_ \(error.localizedDescription)")
                break
            }
        }
        //FEATURED PLAYLISTS
        APICaller.shared.getFeaturedPlaylists{ result in
            defer{
                group.leave()
            }
            switch result{
            case .success(let model):
                featuredPlaylists = model
                break
            case .failure(let error):
                print("ERR_ \(error.localizedDescription)")
                break
            }
        }
        
        //RECOMMENDED TRACKS
        APICaller.shared.getRecommendedGenres(){ result in
            switch result{
            case .success(let model):
                let genres = model.genres
                var genre_seeds = Set<String>()
                while genre_seeds.count < 5 {
                    if let random = genres.randomElement(){
                        genre_seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: genre_seeds){ result in
                    defer{
                        group.leave()
                    }
                    switch result{
                    case .success(let model):
                        recommendedTracks = model
                        break
                    case .failure(let error):
                        print("ERR_ \(error.localizedDescription)")
                        break
                    }
                }
                break
            case .failure(let error):
                print("ERR_ \(error.localizedDescription)")
                break
            }
        }
        
        group.notify(queue: .main){ [weak self] in
            guard let newAlbums = newReleases?.albums.items,
                  let featuredPlaylists = featuredPlaylists?.playlists.items,
                  let recommendedTracks = recommendedTracks?.tracks else {
                return
            }
            
            print("S_ Models POPULATED")
            
            self?.populateModels(newAlbums: newAlbums, featuredPlaylists: featuredPlaylists, recommendedTracks: recommendedTracks)
        }
    }
    
    private func populateModels(newAlbums: [Album],
                                featuredPlaylists: [Playlist],
                                recommendedTracks: [AudioTrack]){
        
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name,
                                            artworkURL: URL(string: $0.images.first?.url ?? ""),
                                            numberOfTracks: $0.total_tracks,
                                            artistName: $0.artists.first?.name ?? "")
        })))
        sections.append(.featuredPlaylists(viewModels: []))
        sections.append(.recommendedTracks(viewModels: []))
        self.collectionView.reloadData()
    }
    
    @objc func didTapSettings(){
        let viewController = SettingsViewController()
        viewController.title = "Settings"
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func sectionLayout(for sectionIndex: Int) -> NSCollectionLayoutSection!{
        switch sectionIndex {
        case 0:
            //= == 1 START ==
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                   heightDimension: .absolute(390))
            
            //ITEM
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                         leading: 2,
                                                         bottom: 2,
                                                         trailing: 2)
            
            //GROUP
            let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: 3)
            //GROUP
            let hGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitem: vGroup,
                                                         count: 1)
            
            //SECTION
            let section = NSCollectionLayoutSection(group: hGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            
            return section
            //= == 1 END ==
        case 1:
            //= == 2 START ==
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(225),
                                                  heightDimension: .absolute(225))
            let vGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(225),
                                                   heightDimension: .absolute(450))
            let hGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(225),
                                                   heightDimension: .absolute(450))
            
            //ITEM
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                         leading: 2,
                                                         bottom: 2,
                                                         trailing: 2)
            
            //GROUP
            let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: vGroupSize,
                                                         subitem: item,
                                                         count: 2)
            //GROUP
            let hGroup = NSCollectionLayoutGroup.horizontal(layoutSize: hGroupSize,
                                                         subitem: vGroup,
                                                         count: 1)
            
            //SECTION
            let section = NSCollectionLayoutSection(group: hGroup)
            section.orthogonalScrollingBehavior = .continuous
            
            return section
            //= == 2 END ==
        case 2:
            //= == 3 START ==
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(80))
            
            //ITEM
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                         leading: 2,
                                                         bottom: 2,
                                                         trailing: 2)
            
            //GROUP
            let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: 1)
//            //GROUP
//            let hGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                         subitem: vGroup,
//                                                         count: 1)
            
            //SECTION
            let section = NSCollectionLayoutSection(group: vGroup)
            
            return section
            //= == 3 END ==
        default:
            //= == DEFAULT START ==
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                   heightDimension: .absolute(390))
            
            //ITEM
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                         leading: 2,
                                                         bottom: 2,
                                                         trailing: 2)
            
            //GROUP
            let vGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: 1)
            //SECTION
            let section = NSCollectionLayoutSection(group: vGroup)
            return section
            //= == DEFAULT END ==
        }
    }

}

enum BrowseSectionType{
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [NewReleasesCellViewModel])
    case recommendedTracks(viewModels: [NewReleasesCellViewModel])
}
