//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

// https://api.openweathermap.org/data/2.5/weather?q=London&appid=244e992eec685bcdc922c11c5223e183&units=metric
// https://openweathermap.org/img/wn/\(success.weather?.last?.icon ?? "")@2x.png"

protocol INetworkService {
    var cityNetwork: BehaviorRelay<String> { get set }
    var temperatureNetwork: BehaviorRelay<String> { get set }
}

final class NetworkService: INetworkService {

    let url: ICreateURL
    var cityNetwork = BehaviorRelay<String>(value: "")
    var temperatureNetwork = BehaviorRelay<String>(value: "")

    init(url: ICreateURL) {
        self.url = url
        getData()
    }

    private func getData() {
         getWeather(httpMethod: "GET", type: WeatherModel.self) { [weak self] result in
             guard let self = self else { return }
             switch result {
             case .success(let data):
                 cityNetwork.accept(data.name)
                 temperatureNetwork.accept("\(Int(data.main?.temp ?? 0.0))°")
             case .failure(let error):
                 print("Error: \(error.localizedDescription)")
             }
         }
     }

   private func getWeather<T: Codable>(httpMethod: String, type: T.Type, completion: @escaping(Result<T, Error>) -> Void) {
        sendRequest(httpMethod: httpMethod) {  data in
            if let parseData = self.parseData(from: data, type: type) {
                completion(.success(parseData))
            }
        }
    }

  private  func sendRequest(httpMethod: String, completion: @escaping(Data) -> Void) {
      guard let url = url.createURL() else { return }
        let test = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data {
                completion(data)
            }
        }
        test.resume()
    }

    private func parseData<T: Codable>(from data: Data, type: T.Type) -> T? {
            let data = try? JSONDecoder().decode(type.self, from: data)
            return data
        }
}
