//
//  NetworkCustom.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 26.03.2024.
//

import Foundation
import RxRelay

struct NetworkCustom {
    var currentСity = BehaviorRelay<String>(value: Constant.Default.city)
    var listData = BehaviorRelay<[List]>(value: [])
    var weatherDto = BehaviorRelay<WeatherDto>(value: WeatherDto())
}
