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
    var search: BehaviorRelay<String> { get set }
    var city: BehaviorRelay<String> { get set }
    func bing()
    func netUpdate()
}

class WeatherViewModel: IWeatherViewModel {
    //: MARK: - Properties

    private let network: INetworkService
    private let disposeBag = DisposeBag()
    var cityName = BehaviorRelay<String>(value: "")
    var temperature = BehaviorRelay<String>(value: "")
    var search = BehaviorRelay<String>(value: "")
    var city = BehaviorRelay<String>(value: "")

    //: MARK: - Initializers

    init(network: INetworkService) {
        self.network = network
    }

    //: MARK: - Setups

    func bing() {
        setupBindings()
    }

    func netUpdate() {
        city
            .bind(to: network.city)
            .disposed(by: disposeBag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.network.transportData()
        }
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
