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

private extension String {
    static let backgroundImage = "background"
    static let placeholder = "Enter your city"
}

private extension CGFloat {
    static let fontCity: CGFloat = 50
    static let fontTemperature: CGFloat = 100
    static let fontDescription: CGFloat = 25
    static let stackSpacing: CGFloat = 5
}

fileprivate enum ConstantsWeather {
    static let searchHeight: CGFloat = 45
    static let stackHeight: CGFloat = 250
}

final class WeatherViewController: UIViewController {
    //: MARK: - Properties

    private var viewModel: IWeatherViewModel
    private let disposeBag = DisposeBag()
    private var listWeather: [ListDTo] = []

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
        tabel.dataSource = self
        tabel.backgroundColor = .clear
        tabel.alpha = Constant.Alpha.alpha
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

    //: MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupBindings()
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

    private func updateCity() {
        searchCityField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] in
                if let text = self?.searchCityField.text {
                    self?.viewModel.currentСity.accept(text)
                    self?.viewModel.updatesCurrentСity()
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupBindings() {
        viewModel.listDTo
            .subscribe(onNext: { [weak self] list in
                DispatchQueue.main.async {
                    self?.listWeather = list ?? []
                    self?.weatherWeakTable.reloadData()
                }
            })
            .disposed(by: disposeBag)

        viewModel.weatherDto
            .subscribe(onNext: { [weak self] user in
                DispatchQueue.main.async {
                    self?.cityNameLabel.text = user.city ?? ""
                    self?.temperatureLabel.text = "\(Int(user.temperature?.rounded() ?? 0.0))"
                    self?.descriptionLabel.text = user.description?.capitalized
                }
            })
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

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listWeather.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.identifier,
                                                       for: indexPath) as? WeatherCell else { return UITableViewCell() }
        cell.createWeatherContent(from: listWeather[indexPath.row])
        return cell
    }
}
