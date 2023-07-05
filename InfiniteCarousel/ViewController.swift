//
//  ViewController.swift
//  InfiniteCarousel
//
//  Created by JeongminKim on 2023/07/05.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let carouselItems = [
        ("1", UIColor(red: 1, green: 0, blue: 0, alpha: 1)),
        ("2", UIColor(red: 0, green: 1, blue: 0, alpha: 1)),
        ("3", UIColor(red: 0, green: 0, blue: 1, alpha: 1)),
    ]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout
        layout.
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: <#T##UICollectionViewLayout#>)
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

