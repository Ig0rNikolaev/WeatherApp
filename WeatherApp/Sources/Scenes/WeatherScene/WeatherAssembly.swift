//
//  WeatherAssembly.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import UIKit

class WeatherAssembly {
    func build() -> UIViewController {
        let url = CreateURL()
        let networkService = NetworkService(url: url)
        let viewModel = WeatherViewModel(network: networkService)
        let view = WeatherViewController(viewModel: viewModel)
        return view
    }
}
