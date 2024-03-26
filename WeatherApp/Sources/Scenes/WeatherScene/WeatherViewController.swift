//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreLocation

private extension String {
    static let backgroundImage = "background"
    static let placeholder = "Enter your city"
    static let clear = ""
}

private extension CGFloat {
    static let fontCity: CGFloat = 35
    static let fontTemperature: CGFloat = 100
    static let fontDescription: CGFloat = 25
    static let stackSpacing: CGFloat = 5
}

private extension Int {
    static let second = 1
}

fileprivate enum ConstantsWeather {
    static let searchHeight: CGFloat = 45
    static let stackHeight: CGFloat = 250

    static let replacingDash = "-"
    static let replacingSpace = " "
}

final class WeatherViewController: UIViewController {
    //: MARK: - Properties

    private var viewModel: IWeatherViewModel
    private let disposeBag = DisposeBag()

    //: MARK: - UI Elements

    private lazy var backgroundImage: UIImageView = {
        let image =  UIImageView()
        image.image = UIImage(named: .backgroundImage)
        image.contentMode = .scaleAspectFill
        return image
    }()

    private lazy var searchCityField: UITextField = {
        let text = UITextField()
        text.placeholder = .placeholder
        text.backgroundColor = .white
        text.borderStyle = .roundedRect
        text.clearButtonMode = .always
        text.alpha = Constant.Alpha.alpha
        return text
    }()

    private lazy var cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(.fontCity)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(.fontTemperature)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(.fontDescription)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var weatherWeakTable: UITableView = {
        let tabel = UITableView(frame: .zero, style: .insetGrouped)
        tabel.register(WeatherCell.self, forCellReuseIdentifier: WeatherCell.identifier)
        tabel.rx.setDelegate(self).disposed(by: disposeBag)
        tabel.alpha = Constant.Alpha.alpha
        tabel.backgroundColor = .clear
        return tabel
    }()

    private lazy var weatherStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cityNameLabel,
                                                   temperatureLabel,
                                                   descriptionLabel])
        stack.axis = .vertical
        stack.spacing = .stackSpacing
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()

    private lazy var manager: CLLocationManager = {
        let manager =  CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()

    //: MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupBindings()
        locationManagerDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCity()
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

    private func locationManagerDelegate() {
        manager.delegate = self
    }

    private func setupBindings() {
        viewModel.weatherCustom.listDTo.bind(to: weatherWeakTable
            .rx.items(cellIdentifier: WeatherCell.identifier,
                      cellType: WeatherCell.self)) { _, item, cell in
            cell.createWeatherContent(from: item)
        }.disposed(by: disposeBag)

        viewModel.weatherCustom.weatherDto
            .subscribe { [weak self] event in
                self?.updateWeatherData(event: event)
            }.disposed(by: disposeBag)
    }

    private func updateCity() {
        searchCityField.rx.text.orEmpty
            .debounce(.seconds(.second), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe { [weak self] text in
                if !text.isEmpty {
                    self?.viewModel.updateWeatherData(for: text.replacingOccurrences(of: ConstantsWeather.replacingDash,
                                                                                     with: ConstantsWeather.replacingSpace))
                } else {
                    self?.clearWeatherData()
                }
            }.disposed(by: disposeBag)
    }

    private func updateWeatherData(event: WeatherDto) {
        DispatchQueue.main.async {
            self.cityNameLabel.text = event.city ?? Constant.Default.city
            self.descriptionLabel.text = event.description?.capitalized
            if let temp = event.temperature?.rounded() {
                self.temperatureLabel.text = "\(Int(temp))"
            }
        }
    }

    private func clearWeatherData() {
        cityNameLabel.text = .clear
        temperatureLabel.text = .clear
        descriptionLabel.text = .clear
        viewModel.weatherCustom.listDTo.accept([])
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
            make.left.right.equalToSuperview().inset(Constant.Offset.leftRight)
            make.height.equalTo(ConstantsWeather.searchHeight)
        }

        weatherStack.snp.makeConstraints { make in
            make.top.equalTo(searchCityField.snp.bottom).offset(Constant.Offset.top)
            make.height.equalTo(ConstantsWeather.stackHeight)
            make.left.right.equalToSuperview().inset(Constant.Offset.leftRight)
            make.centerX.equalToSuperview()
        }

        weatherWeakTable.snp.makeConstraints { make in
            make.top.equalTo(weatherStack.snp.bottom).offset(Constant.Offset.top)
            make.left.right.bottom.equalToSuperview()
        }
    }

    deinit {
        print("deinit VC")
    }
}

//: MARK: - Extensions

extension WeatherViewController: CLLocationManagerDelegate, UIScrollViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, _) in
            guard let placemark = placemarks?.first else { return }
            if let city = placemark.locality {
                self?.viewModel.updateWeatherData(for: city)
            }
        }
    }
}
