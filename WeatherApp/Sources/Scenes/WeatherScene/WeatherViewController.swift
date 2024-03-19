//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import SnapKit

final class WeatherViewController: UIViewController {

    //: MARK: - UI Elements

    private lazy var backgroundImage: UIImageView = {
        let image =  UIImageView()
        image.image = UIImage(named: "background")
        image.contentMode = .scaleAspectFill
        return image
    }()

    private lazy var searchCityField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter your city"
        text.backgroundColor = .white
        text.borderStyle = .roundedRect
        text.alpha = 0.7
        return text
    }()

    private lazy var cityNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Los-Angeles"
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(50)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "25°"
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(100)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Sunny"
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(25)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var maxMinTemperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "Max.: 5°, min.: -2°"
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(25)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var weatherWeakTable: UITableView = {
        let tabel = UITableView(frame: .zero, style: .insetGrouped)
        tabel.register(WeatherCell.self, forCellReuseIdentifier: WeatherCell.identifier)
        tabel.dataSource = self
        tabel.delegate = self
        tabel.backgroundColor = .clear
        tabel.alpha = 0.7
        return tabel
    }()

    private lazy var weatherStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cityNameLabel,
                                                   temperatureLabel,
                                                   weatherDescriptionLabel,
                                                   maxMinTemperatureLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()

    //: MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
    }

    //: MARK: - Setups

    private func setupView() {

    }

    private func setupHierarchy() {
        let views = [backgroundImage,
                     searchCityField,
                     weatherStack,
                     weatherWeakTable]
        view.addViews(views)
    }

    private func setupLayout() {
        backgroundImage.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }

        searchCityField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(45)
        }

        weatherStack.snp.makeConstraints { make in
            make.top.equalTo(searchCityField.snp.bottom).offset(20)
            make.height.equalTo(250)
            make.left.right.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }

        weatherWeakTable.snp.makeConstraints { make in
            make.top.equalTo(weatherStack.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.identifier,
                                                       for: indexPath) as? WeatherCell else { return UITableViewCell() }
        cell.createWeatherContent()
        return cell
    }
}

extension WeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
