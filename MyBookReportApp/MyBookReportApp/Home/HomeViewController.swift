//
//  HomeViewController.swift
//  MyBookReportApp
//
//  Created by 백유정 on 2021/11/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import FSPagerView
import RealmSwift

class HomeViewController: UIViewController {
    
    private var viewModel = HomeViewModel()
    let localRealm = try! Realm()
    
    var tasks: Results<UserBestBook>!
    var tasks_recent: Results<UserRecentBook>!
    
    @IBOutlet weak var homeSearchBar: UISearchBar!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
            self.pagerView.itemSize = CGSize(width: 130, height: 195)
            self.pagerView.isInfinite = true
            self.pagerView.contentMode = .scaleAspectFit
            self.pagerView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
            self.pagerView.automaticSlidingInterval = 3.0
        }
    }
    
    @IBOutlet weak var systemLabel: UILabel!
    
    @IBOutlet weak var todayDateLabel: UILabel!
    
    @IBOutlet weak var recentImageView: UIImageView!
    @IBOutlet weak var recentTitle: UILabel!
    @IBOutlet weak var recentAuthor: UILabel!
    @IBOutlet weak var recentCustomerReviewRank: UILabel!
    @IBOutlet weak var recentReviewCount: UILabel!
    @IBOutlet weak var recentHeartImage: UIImageView!
    @IBOutlet weak var recentView: UIView!
    @IBOutlet weak var recentEmptyView: UIView!
    
    @IBOutlet weak var bookQuotesImageView: UIImageView!
    @IBOutlet weak var bookQuotesLabel: UILabel!
    
    var arrayBestSellerCover: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "홈"
        
        homeSearchBar.delegate = self
        pagerView.dataSource = self
        pagerView.delegate = self
        
        todayDateSetting()
        bookQuoteSetting()
        fetchBestSellerData()
        bind(viewModel)
        
        tasks = localRealm.objects(UserBestBook.self)
        print("링크", localRealm.configuration.fileURL)
        
        try! localRealm.write {
            localRealm.delete(localRealm.objects(UserBestBook.self))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recentSetting()
    }
    
    private func bind(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    func todayDateSetting() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy년 M월 d일"
        let strDate = format.string(from: date)
        todayDateLabel.text = strDate
    }
    
    func recentSetting() {
        if let thisRecentBook = localRealm.objects(UserRecentBook.self).last {
            recentEmptyView.isHidden = true
            let recentUrl = URL(string: thisRecentBook.image)
            recentImageView.kf.setImage(with: recentUrl)
            recentTitle.text = thisRecentBook.bookTitle
            recentAuthor.text = thisRecentBook.author
            recentCustomerReviewRank.text = String(thisRecentBook.customerReviewRank)+"/10"
            recentReviewCount.text = String(thisRecentBook.reviewCount)
            
            let isbn = thisRecentBook.isbn
            
            // 만약에 책이 favoriteBook에 있다면
            if  localRealm.objects(UserFavoriteBook.self).filter("isbn == '\(isbn)'") != nil {
                let rcbook = localRealm.objects(UserFavoriteBook.self).filter("isbn == '\(isbn)'")
                if rcbook.first?.favorite == true {
                    recentHeartImage.image = UIImage(named: "heart_like")
                } else {
                    recentHeartImage.image = UIImage(named: "heart_dislike")
                }
            } else {
                recentHeartImage.image = UIImage(named: "heart_dislike")
            }
            
            recentViewClicked()
        } else {
            recentEmptyView.isHidden = false
        }
        
        recentImageView.layer.borderWidth = 0
        recentImageView.layer.masksToBounds = false
        recentImageView.layer.shadowColor = UIColor.gray.cgColor
        recentImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
        recentImageView.layer.shadowOpacity = 0.3
    }
    
    func recentViewClicked() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goPage(sender:)))
        recentView.addGestureRecognizer(gesture)
    }
    
    func bookQuoteSetting() {
        let random2 = Int.random(in: 0...bookQuotesImages.count-1)
        let bookQuotesUrl = URL(string: bookQuotesImages[random2])
        bookQuotesImageView.kf.setImage(with: bookQuotesUrl)
        
        let random1 = Int.random(in: 0...bookQuotes.count-1)
        bookQuotesLabel.text = bookQuotes[random1]
        bookQuotesLabel.font = UIFont(name: "GowunBatang-Regular", size: 14)
        
        /// 행간 조절
        let attrString = NSMutableAttributedString(string: bookQuotesLabel.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        bookQuotesLabel.attributedText = attrString
    }
    
    @objc func goPage(sender: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "SearchDetail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: SearchDetailViewController.identifier) as! SearchDetailViewController
        
        if let thisRecentBook = localRealm.self.objects(UserRecentBook.self).last {
            vc.titleText = thisRecentBook.bookTitle
            vc.authorText = thisRecentBook.author
            vc.publisherText = thisRecentBook.publisher
            vc.imageText = thisRecentBook.image
            
            vc.pubDateText = thisRecentBook.pubDate
            vc.descriptionText = thisRecentBook.descriptionBook
            
            vc.customerReviewRank = thisRecentBook.customerReviewRank
            vc.reviewCount = thisRecentBook.reviewCount
            vc.priceStandard = thisRecentBook.priceStandard
            vc.linkText = thisRecentBook.link
            
            vc.isbnText = thisRecentBook.isbn
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchBestSellerData() {
        viewModel.getBestSeller { result in
            switch result {
            case .success(let bestSellerData):
                let tasks = bestSellerData.0
                let images = bestSellerData.1
                
                try! self.localRealm.write {
                    self.localRealm.add(tasks)
                    
                    for image in images {
                        self.arrayBestSellerCover.append(image)
                    }
                }
                
                DispatchQueue.main.async {
                    self.pagerView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.systemLabel.isHidden = false
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    // 커서가 깜빡이기 시작할 때
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let sb = UIStoryboard(name: "Search", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: SearchViewController.identifier) as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        let url = URL(string: arrayBestSellerCover[index])
        
        cell.imageView?.kf.setImage(with: url)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return arrayBestSellerCover.count
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let sb = UIStoryboard(name: "SearchDetail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: SearchDetailViewController.identifier) as! SearchDetailViewController
        
        let row = tasks[index]
        
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
