//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import RxSwift
import RxCocoa
import RxRelay

protocol IWeatherViewModel {
    var cityName: BehaviorRelay<String> { get }
    var temperature: BehaviorRelay<String> { get }
    func bing()
}

class WeatherViewModel: IWeatherViewModel {
    //: MARK: - Properties

    private let network: INetworkService
    private let disposeBag = DisposeBag()
    var cityName = BehaviorRelay<String>(value: "")
    var temperature = BehaviorRelay<String>(value: "")

    //: MARK: - Initializers

    init(network: INetworkService) {
        self.network = network
    }

    //: MARK: - Setups

    func bing() {
        setupBindings()
    }

    func setupBindings() {
        network.cityNetwork.subscribe { event in
            if let cityName = event.element {
                self.cityName.accept(cityName)
            }
        }.disposed(by: disposeBag)

        network.temperatureNetwork.subscribe { event in
            if let temperature = event.element {
                self.temperature.accept(temperature)
            }
        }.disposed(by: disposeBag)
    }
}
