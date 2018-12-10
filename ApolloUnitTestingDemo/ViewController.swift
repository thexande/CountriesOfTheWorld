//
//  ViewController.swift
//  ApolloUnitTestingDemo
//
//  Created by Alexander Murphy on 12/8/18.
//  Copyright © 2018 Alexander Murphy. All rights reserved.
//

import UIKit
import Apollo

class ViewController: UIViewController {
    
//    var store: WorldStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let serverAdress = "https://countries.trevorblades.com/"
        guard let url = URL(string: serverAdress) else {
            return
        }
        
//       store = WorldStore(client: ApolloClient(url: url))
        
//        store?.fetchAllCountries { (result) in
//            switch result {
//            case let .success(properties):
//                print(properties)
//            case let .failure(error):
//                print(error)
//            }
//        }
    }
}

