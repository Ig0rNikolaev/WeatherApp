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
    static let cityDefault = ""
}

private extension Double {
    static let minTemp: Double = 100.0
    static let maxTemp: Double = -100.0
}

protocol IWeatherViewModel {
    func updateWeatherData(for city: String)
    var listDTo: BehaviorRelay<[ListDTo]> { get set }
    var currentСity: BehaviorRelay<String> { get set }
    var weatherDto: BehaviorRelay<WeatherDto> { get set }
}

class WeatherViewModel: IWeatherViewModel {
    //: MARK: - Properties

    private let network: INetworkService
    private let disposeBag = DisposeBag()
    var listData = BehaviorRelay<[List]>(value: [])
    var listDTo = BehaviorRelay<[ListDTo]>(value: [])
    var currentСity = BehaviorRelay<String>(value: .cityDefault)
    var weatherDto = BehaviorRelay<WeatherDto>(value: WeatherDto())

    //: MARK: - Initializers

    init(network: INetworkService) {
        self.network = network
        setupBindings()
    }

    //: MARK: - Setups

    func updateWeatherData(for city: String) {
        if city.isEmpty {
            listDTo.accept([])
        } else {
            currentСity.accept(city)
            updatesCurrentСity()
        }
    }

    private func updatesCurrentСity() {
        currentСity
            .bind(to: network.currentСity)
            .disposed(by: disposeBag)

        self.network.transmitsDataFromNetwork {
            self.updatesWeeklyWeatherForecast()
        }
    }

    private func setupBindings() {
        network.weatherDto.subscribe { [weak self] event in
            if let weather = event.element {
                self?.weatherDto.accept(weather)
            }
        }.disposed(by: disposeBag)

        network.listData.subscribe { [weak self] event in
            if let list = event.element {
                self?.listData.accept(list)
            }
        }.disposed(by: disposeBag)
    }

    private func updatesWeeklyWeatherForecast() {
        var weatherList: [ListDTo] = []
        var weatherDictionary: [String: List] = [:]

        for day in listData.value {
            let date = self.dateFormatter(date: day.dt ?? Date())
            guard weatherDictionary[date] == nil else { continue }
            weatherDictionary[date] = day

            let minMaxTemp = self.calculatesTemperatureRange(for: day.dt)
            guard let urlImage = day.weather?.first?.iconURL else { return }
            network.createImageData(url: urlImage) { data in
                let weatherDTO = ListDTo(date: date,
                                         min: minMaxTemp.min,
                                         max:  minMaxTemp.max,
                                         image: data ?? Data())
                weatherList.append(weatherDTO)
                self.listDTo.accept(weatherList)
            }
        }
    }

    private func calculatesTemperatureRange(for day: Date?) -> (min: Int, max: Int) {
        var minTemp: Double = .minTemp.rounded()
        var maxTemp: Double = .maxTemp.rounded()

        for days in listData.value {
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
