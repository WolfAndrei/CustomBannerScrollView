//
//  ViewController.swift
//  CustomBannerScrollView
//
//  Created by Andrei Volkau on 10.12.2020.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bannerView: BannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bannerView.set(viewModel: bannerViewModel)
    }

}

extension ViewController: BannerViewProtocol {
    func didTap(atIndex index: Int) {
//        print(bannerViewModel.items[index])
         print(index)
    }
}
