//
//  ViewControllerDeinit.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 25.03.2024.
//

import UIKit

class ViewControllerDeinit: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Button", style: .done, target: self, action: #selector(tap))
    }

    @objc func tap() {
        let vc = WeatherAssembly().build()
        navigationController?.pushViewController(vc, animated: true)
    }
}
