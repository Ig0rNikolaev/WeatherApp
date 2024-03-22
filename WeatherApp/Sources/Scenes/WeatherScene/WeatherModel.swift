//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import Foundation

// MARK: - WeatherModel
struct WeatherModel: Codable {
    let cod: String?
    let message, cnt: Int?
    let list: [List]?
    let city: City?
}

// MARK: - City
struct City: Codable {
    let id: Int?
    let name: String?
    let coord: Coord?
    let country: String?
    let population, timezone, sunrise, sunset: Int?
}

// MARK: - Coord
struct Coord: Codable {
    let lat, lon: Double?
}

// MARK: - List
struct List: Codable {
    let dt: Date?
    let main: MainClass?
    let weather: [Weather]?
}

// MARK: - MainClass
struct MainClass: Codable {
    let temp, tempMin, tempMax: Double?

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
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
