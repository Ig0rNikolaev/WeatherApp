//
//  CreateURL.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import Foundation

protocol ICreateURL {
    func createURL(lat: Double, lon: Double) -> URL?
}

class CreateURL: ICreateURL {
    func createURL(lat: Double, lon: Double) -> URL? {
        let key = "6cbbb4eeff5ee35fb1777767f16b2885"
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/forecast"

        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: key),
            URLQueryItem(name: "units", value: "metric"),
        ]

        print(components.url!)
        return components.url
    }
}

//https://api.openweathermap.org/data/2.5/forecast?q=Moscow&appid=6cbbb4eeff5ee35fb1777767f16b2885
