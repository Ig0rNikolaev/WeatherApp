//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import Foundation

// MARK: - WeatherModel
struct WeatherModel: Codable {
    let list: [List]?
    let city: City?
}

// MARK: - City
struct City: Codable {
    let id: Int?
    let name: String?
}

// MARK: - List
struct List: Codable {
    let dt: Date?
    let main: MainClass?
    let weather: [Weather]?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather
    }
}

// MARK: - MainClass
struct MainClass: Codable {
    let temp: Double?
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?

    var iconURL: URL {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon ?? "")@2x.png") else { return URL(fileURLWithPath: "") }
        return url
    }
}
