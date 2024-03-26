//
//  CreateURL.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import Foundation

private extension String {
    static let key = "6cbbb4eeff5ee35fb1777767f16b2885"
    static let scheme = "https"
    static let host = "api.openweathermap.org"
    static let imageHost = "openweathermap.org"
    static let path = "/data/2.5/forecast"
    static let imagePath = "/img/wn/"
    static let city = "q"
    static let appid = "appid"
    static let lang = "lang"
    static let units = "units"
    static let ru = "ru"
    static let metric = "metric"
    static let png = "@2x.png"
}

protocol ICreateURL {
    func createURL(city: String) -> URL?
    func imageURL(image: String) -> URL? 
}

class CreateURL: ICreateURL {
    func createURL(city: String) -> URL? {
        let key: String = .key
        var components = URLComponents()
        components.scheme = .scheme
        components.host = .host
        components.path = .path
        components.queryItems = [
            URLQueryItem(name: .city, value: city),
            URLQueryItem(name: .appid, value: key),
            URLQueryItem(name: .lang, value: .ru),
            URLQueryItem(name: .units, value: .metric),
        ]
        return components.url
    }

    func imageURL(image: String) -> URL? {
        var components = URLComponents()
        components.scheme = .scheme
        components.host = .imageHost
        components.path = .imagePath
        components.path += "\(image + .png)"
        return components.url
    }

    deinit {
        print("deinit CreateURL")
    }
}
