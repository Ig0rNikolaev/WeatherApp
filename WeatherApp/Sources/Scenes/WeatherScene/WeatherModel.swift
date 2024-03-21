//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import Foundation

struct WeatherModel: Codable {
    var name: String
    let main: Main?
}

struct Main: Codable {
    let temp: Double
}
