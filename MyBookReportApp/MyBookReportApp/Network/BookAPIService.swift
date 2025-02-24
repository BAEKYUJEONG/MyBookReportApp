//
//  BookAPIService.swift
//  MyBookReportApp
//
//  Created by 백유정 on 2022/08/01.
//

import UIKit
import Alamofire
import SwiftyJSON

final class BookAPIService {
    
    func getBook(_ text: String, _ startPage: Int, _ completion: @escaping (Result<JSON, Error>) -> Void) {
        let url = EndPoint.getBook(text, startPage).url.absoluteString
        
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(.success(json))
            case .failure(let error):
                completion(.failure(error.localizedDescription as! Error))
            }
        }
    }
    
    func getBestSeller(_ completion: @escaping (Result<JSON, Error>) -> Void) {
        let url = EndPoint.getBestSeller.url.absoluteString
        
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(.success(json))
            case .failure(let error):
                completion(.failure(error.localizedDescription as! Error))
            }
        }
    }
}
