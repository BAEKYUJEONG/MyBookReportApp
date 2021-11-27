//
//  FavoriteViewController.swift
//  MyBookReportApp
//
//  Created by 백유정 on 2021/11/22.
//

import UIKit
import RealmSwift
import Kingfisher

class FavoriteViewController: UIViewController {

    @IBOutlet weak var favoriteTableView: UITableView!
    
    let localRealm = try! Realm()
    
    var tasks: Results<UserFavoriteBook>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "내 서재"
        
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        
        tasks = localRealm.objects(UserFavoriteBook.self).filter("favorite == true")
        print("테스크", tasks)
        print(localRealm.configuration.fileURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        favoriteTableView.reloadData()
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = favoriteTableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier) as? FavoriteTableViewCell else {
            return UITableViewCell()
        }
        
        let row = tasks[indexPath.row]
        
        cell.configureCell(row: row)
        
        if let url = URL(string: row.image) {
            cell.favoriteImageView.kf.setImage(with: url)
        } else {
            cell.favoriteImageView.image = UIImage(systemName: "nosign")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 140
    }
}
