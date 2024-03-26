//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 21.03.2024.
//

import RxSwift
import RxRelay

private extension String {
    static let dateFormat = "EE, d"
}

private extension Double {
    static let minTemp: Double = 100.0
    static let maxTemp: Double = -100.0
}

protocol IWeatherViewModel {
    func updateWeatherData(for city: String)
    var weatherCustom: WeatherDataCustom { get set }
}

class WeatherViewModel: IWeatherViewModel {
    //: MARK: - Properties

    private let network: INetworkService
    private let disposeBag = DisposeBag()
    var weatherCustom = WeatherDataCustom()

    //: MARK: - Initializers

    init(network: INetworkService) {
        self.network = network
        setupBindings()
    }

    //: MARK: - Setups

    func updateWeatherData(for city: String) {
        if city.isEmpty {
            weatherCustom.listDTo.accept([])
        } else {
            weatherCustom.currentСity.accept(city)
            updatesCurrentСity()
        }
    }

    private func updatesCurrentСity() {
        weatherCustom.currentСity
            .bind(to: network.networkCustom.currentСity)
            .disposed(by: disposeBag)

        self.network.transmitsDataFromNetwork {
            self.updatesWeeklyWeatherForecast()
        }
    }

    private func setupBindings() {
        network.networkCustom.weatherDto.subscribe { [weak self] event in
            if let weather = event.element {
                self?.weatherCustom.weatherDto.accept(weather)
            }
        }.disposed(by: disposeBag)

        network.networkCustom.listData.subscribe { [weak self] event in
            if let list = event.element {
                self?.weatherCustom.listData.accept(list)
            }
        }.disposed(by: disposeBag)
    }

    private func updatesWeeklyWeatherForecast() {
        var weatherList: [ListDTo] = []
        var weatherDictionary: [String: List] = [:]

        for day in weatherCustom.listData.value {
            let date = self.dateFormatter(date: day.dt ?? Date())
            guard weatherDictionary[date] == nil else { continue }
            weatherDictionary[date] = day

            network.createImageData(icon: day) { data in
                let weatherDTO = ListDTo(date: date,
                                         min: self.temperatureRange(for: day.dt).min,
                                         max: self.temperatureRange(for: day.dt).max,
                                         image: data ?? Data())
                weatherList.append(weatherDTO)
                self.weatherCustom.listDTo.accept(weatherList)
            }
        }
    }

    private func temperatureRange(for day: Date?) -> (min: Int, max: Int) {
        var minTemp: Double = .minTemp.rounded()
        var maxTemp: Double = .maxTemp.rounded()

        for days in weatherCustom.listData.value {
            guard let hourlyDate = days.dt else { continue }
            if Calendar.current.isDate(hourlyDate, inSameDayAs: day ?? Date()) {
                if let temperature = days.main?.temp {
                    minTemp = min(minTemp, temperature)
                    maxTemp = max(maxTemp, temperature)
                }
            }
        }
        let roundedMinTemp = Int(minTemp)
        let roundedMaxTemp = Int(maxTemp)
        return (roundedMinTemp, roundedMaxTemp)
    }

    private func dateFormatter(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = .dateFormat
        return dateFormater.string(from: date)
    }

    deinit {
        print("deinit VM")
    }
}
