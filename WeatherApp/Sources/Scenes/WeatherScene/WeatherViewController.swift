//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WeatherViewController: UIViewController {
    //: MARK: - Properties

    private var viewModel: IWeatherViewModel
    private let disposeBag = DisposeBag()

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
        text.addTarget(self, action: #selector(updateCity), for: .editingChanged)
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
        tabel.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
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
        setupHierarchy()
        setupLayout()
        setupBindings()
        viewModel.bing()
    }

    //: MARK: - Initializers
    
    init(viewModel: IWeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    //: MARK: - Setups

    @objc
        func updateCity() {
            self.viewModel.city.accept(self.searchCityField.text ?? "")
            self.viewModel.netUpdate()
        }

    private func setupBindings() {
        viewModel.cityName
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.temperature
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)
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

//: MARK: - Extensions

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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Прогноз погоды на 10 дней"
    }
}

extension WeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
