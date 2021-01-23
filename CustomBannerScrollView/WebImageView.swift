//
//  WebImageView.swift
//  CustomBannerScrollView
//
//  Created by Andrei Volkau on 14.12.2020.
//

import UIKit

class WebImageView: UIImageView {
    
    private var currentImageUrl: String?
    
    func load(with urlString: String?) {
        currentImageUrl = urlString
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            self.image = nil
            return
        }
        
        if let cachesResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            self.image = UIImage(data: cachesResponse.data)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                guard let data = data,
                      let response = response else { return }
                self.handleCachedImage(data: data, response: response)
            }
        }.resume()
    }
    
    private func handleCachedImage(data: Data, response: URLResponse) {
        guard let responseUrl = response.url else { return }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: responseUrl))
        
        if responseUrl.absoluteString == currentImageUrl {
            self.image = UIImage(data: data)
        }
    }
}


