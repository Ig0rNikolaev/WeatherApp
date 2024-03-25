//
//  NetworkError.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 26.03.2024.
//

import Foundation

private extension String {
    static let error = "Ошибка: что-то пошло не так"
}

enum NetworkError: Error {
    case decoding(DecodingError?)

    var localizedDescription: String {
        switch self {
        case .decoding(let decodingError):
            return decodingError?.localizedDescription ?? .error
        }
    }
}
