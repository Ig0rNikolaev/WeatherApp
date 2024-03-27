//
//  WeatherDataCustom.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 26.03.2024.
//

import Foundation
import RxRelay

struct WeatherDataCustom {
    var listData = BehaviorRelay<[List]>(value: [])
    var listDTo = BehaviorRelay<[ListDTo]>(value: [])
    var currentСity = BehaviorRelay<String>(value: Constant.Default.city)
    var weatherDto = BehaviorRelay<WeatherDto>(value: WeatherDto())
}
