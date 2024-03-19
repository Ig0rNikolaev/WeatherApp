//
//  Extension+UIView.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit

extension UIView {
    func addViews(_ array: [UIView]) {
        array.forEach { self.addSubview($0) }
    }
}
