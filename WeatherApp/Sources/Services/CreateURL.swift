//
//  CreateURL.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import Foundation

protocol ICreateURL {
    func createURL() -> URL?
}

class CreateURL: ICreateURL {
    func createURL() -> URL? {
        let key = "244e992eec685bcdc922c11c5223e183"
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        
        components.queryItems = [
            URLQueryItem(name: "q", value: "London"),
            URLQueryItem(name: "appid", value: key),
            URLQueryItem(name: "units", value: "metric"),
        ]
        return components.url
    }
}
