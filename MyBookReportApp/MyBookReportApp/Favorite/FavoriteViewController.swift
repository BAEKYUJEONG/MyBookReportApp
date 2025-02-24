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
    @IBOutlet weak var favoriteEmptyView: UIView!
    
    let localRealm = try! Realm()
    
    var tasks: Results<UserFavoriteBook>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "내 서재"
        
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        
        tasks = localRealm.objects(UserFavoriteBook.self).filter("favorite == true").sorted(byKeyPath: "writeDate", ascending: false)
        print(localRealm.configuration.fileURL)
        
        if tasks.count == 0 {
            favoriteEmptyView.isHidden = false
        } else {
            favoriteEmptyView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        favoriteTableView.reloadData()
        emptyView()
    }
    
    func emptyView() {
        if tasks.count == 0 {
            favoriteEmptyView.isHidden = false
        } else {
            favoriteEmptyView.isHidden = true
        }
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
        
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "SearchDetail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: SearchDetailViewController.identifier) as! SearchDetailViewController
        
        let row = tasks[indexPath.row]
        vc.titleText = row.bookTitle
        vc.authorText = row.author
        vc.publisherText = row.publisher
        vc.imageText = row.image
        
        vc.pubDateText = row.pubDate
        vc.descriptionText = row.descriptionBook
        
        vc.customerReviewRank = row.customerReviewRank
        vc.reviewCount = row.reviewCount
        vc.priceStandard = row.priceStandard
        vc.linkText = row.link
        
        vc.nowBool = row.now
        
        vc.isbnText = row.isbn
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
