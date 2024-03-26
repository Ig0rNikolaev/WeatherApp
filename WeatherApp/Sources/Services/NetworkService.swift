//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import RxSwift
import RxRelay

protocol INetworkService {
    func createImageData(icon: List, completion: @escaping (Data?) -> Void)
    func transmitsDataFromNetwork(completion: @escaping () -> Void)
    var networkCustom: NetworkCustom { get set }
}

final class NetworkService: INetworkService {
    private let url: ICreateURL
    var networkCustom = NetworkCustom()


    init(url: ICreateURL) {
        self.url = url
    }

    func transmitsDataFromNetwork(completion: @escaping () -> Void) {
        getData(completion: completion)
    }

    func createImageData(icon: List, completion: @escaping (Data?) -> Void) {
        let url = self.url.imageURL(image: icon.weather?.first?.icon ?? Constant.Default.icon)
        sendRequest(url: url, httpMethod: .get) { data in
            completion(data)
        }
    }

    private func getData(completion: @escaping () -> Void) {
        getWeather(httpMethod: .get, type: WeatherModel.self) { result in
            switch result {
            case .success(let data):
                let weatherSetting = self.createWeatherDTO(from: data)
                self.networkCustom.weatherDto.accept(weatherSetting)
                self.networkCustom.listData.accept(data.list ?? [])
                completion()
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

    private func getWeather<T: Codable>(httpMethod: HttpMethod, type: T.Type, completion: @escaping(Result<T, NetworkError>) -> Void) {
        let url = self.url.createURL(city: networkCustom.currentСity.value)
        sendRequest(url: url, httpMethod: httpMethod) { data in
            if let parseData = self.parseData(from: data, type: type) {
                completion(.success(parseData))
            } else {
                completion(.failure(.decoding(nil)))
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
