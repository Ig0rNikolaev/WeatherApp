//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

protocol INetworkService {
    func transportData()
    var cityNetwork: BehaviorRelay<String> { get set }
    var temperatureNetwork: BehaviorRelay<String> { get set }
    var city: BehaviorRelay<String> { get set }
}

final class NetworkService: INetworkService {
    let url: ICreateURL
    var cityNetwork = BehaviorRelay<String>(value: "")
    var temperatureNetwork = BehaviorRelay<String>(value: "")
    var city = BehaviorRelay<String>(value: "No city")

    init(url: ICreateURL) {
        self.url = url
    }

    func transportData() {
        getData()
    }

    private func getData() {
         getWeather(httpMethod: "GET", type: WeatherModel.self) { result in
             switch result {
             case .success(let data):
                 self.cityNetwork.accept(data.city?.name ?? "")
                 print("Город: \(data.city?.name ?? "")")
                 for day in data.list! {
                     print("Температура: \(day.main?.temp ?? 0.0)")
                     self.temperatureNetwork.accept("\(Int(day.main?.temp ?? 0.0))")
                     print("Температура Мин: \(day.main?.tempMin ?? 0.0)")
                     print("Температура Макс:\(day.main?.tempMax ?? 0.0)")
                     print("Дата: \(self.dateFormatter(date: day.dt ?? Date()))")
                     print("Картинка: \(String(describing: day.weather?[0].iconURL))")
                     print("Описание погоды: \(day.weather?[0].description ?? "")")
                     print("Осадки: \(day.weather?[0].main ?? "")")
                     print("                                                                ")
                 }
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

    private func sendRequest(httpMethod: String, completion: @escaping(Data) -> Void) {

        CLGeocoder().geocodeAddressString(city.value) { (placemark, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let lat = placemark?.first?.location?.coordinate.latitude,
               let lon = placemark?.first?.location?.coordinate.longitude {

                let urlS = self.url.createURL(lat: lat, lon: lon)!
                URLSession.shared.dataTask(with: urlS) { data, _, _ in
                    if let data {
                        completion(data)
                    }
                }.resume()
            }
        }
    }

    private func parseData<T: Codable>(from data: Data, type: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let data = try? decoder.decode(type.self, from: data)
        return data
    }

    private func dateFormatter(date: Date) -> String {
         let dateFormater = DateFormatter()
         dateFormater.dateFormat = "E, MMM, d"
         return dateFormater.string(from: date)
     }
}
