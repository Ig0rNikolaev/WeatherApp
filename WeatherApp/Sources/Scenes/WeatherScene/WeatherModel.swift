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

struct City: Codable {
    let id: Int?
    let name: String?
}

struct List: Codable {
    let dt: Date?
    let main: MainClass?
    let weather: [Weather]?
}

struct MainClass: Codable {
    let temp: Double?
}

struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}
