//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol INetworkService {
    func transmitsDataFromNetwork()
    func createImageData(url: URL, completion: @escaping (Data?) -> Void)
    var currentСity: BehaviorRelay<String> { get set }
    var listData: BehaviorRelay<[List]> { get set }
    var weatherDto: BehaviorRelay<WeatherDto> { get set }
}

final class NetworkService: INetworkService {
    private let url: ICreateURL
    var currentСity = BehaviorRelay<String>(value: "")
    var listData = BehaviorRelay<[List]>(value: [])
    var weatherDto = BehaviorRelay<WeatherDto>(value: WeatherDto())

    init(url: ICreateURL) {
        self.url = url
    }

    func transmitsDataFromNetwork() {
        getData()
    }

    func createImageData(url: URL, completion: @escaping (Data?) -> Void) {
        sendRequest(url: url, httpMethod: .get) { data in
            completion(data)
        }
    }

    private func getData() {
        getWeather(httpMethod: .get, type: WeatherModel.self) { result in
            switch result {
            case .success(let data):
                let weatherSetting = self.createWeatherDTO(from: data)
                self.weatherDto.accept(weatherSetting)
                self.listData.accept(data.list ?? [])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func createWeatherDTO(from data: WeatherModel) -> WeatherDto {
        let weatherSetting = WeatherDto(city: data.city?.name,
                                        temperature: data.list?.first?.main?.temp,
                                        main: data.list?.first?.weather?.first?.main,
                                        description: data.list?.first?.weather?.first?.description)
        return weatherSetting
    }

    private func getWeather<T: Codable>(httpMethod: HttpMethod, type: T.Type, completion: @escaping(Result<T, Error>) -> Void) {
        let url = self.url.createURL(city: currentСity.value)
        sendRequest(url: url, httpMethod: httpMethod) {  data in
            if let parseData = self.parseData(from: data, type: type) {
                completion(.success(parseData))
            }
        }
    }

    private func sendRequest(url: URL?, httpMethod: HttpMethod, completion: @escaping(Data) -> Void) {
        guard let url = url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data {
                completion(data)
            }
        }.resume()
    }

    private func parseData<T: Codable>(from data: Data, type: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let data = try? decoder.decode(type.self, from: data)
        return data
    }
}
