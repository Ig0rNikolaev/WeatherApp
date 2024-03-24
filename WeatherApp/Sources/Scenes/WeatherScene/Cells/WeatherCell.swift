//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by Игорь Николаев on 19.03.2024.
//

import UIKit
import SnapKit

fileprivate enum ConstantsCell {
    static let identifier = "\(Self.self)"
    static let font: CGFloat = 15
    static let inset: CGFloat = 10
}

final class WeatherCell: UITableViewCell {
    //: MARK: - Properties

    static var identifier: String { ConstantsCell.identifier }

    //: MARK: - UI Elements

     var weatherImage: UIImageView = {
        let image =  UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.tintColor = .black
        return image
    }()

     var dayWeekLabel: UILabel = {
        let label = UILabel()
         label.font = UIFont.preferredFont(forTextStyle: .headline).withSize(ConstantsCell.font)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var tempMinCellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline).withSize(ConstantsCell.font)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var weatherStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dayWeekLabel, weatherImage, tempMinCellLabel])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()

    //: MARK: - initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    //: MARK: - Setups

    override func prepareForReuse() {
        super.prepareForReuse()
        dayWeekLabel.text = nil
        weatherImage.image = nil
        tempMinCellLabel.text = nil
    }

    private func setupHierarchy() {
        contentView.addSubview(weatherStack)
    }

    private func setupLayout() {
        weatherStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(ConstantsCell.inset)
            make.height.equalToSuperview()
        }
    }

    func createWeatherContent(from weather: ListDTo) {
        dayWeekLabel.text = weather.date
        weatherImage.image =  UIImage(data: weather.image ?? Data())
        tempMinCellLabel.text = "Макс.: \(weather.max ?? 0)° | Мин.: \(weather.min ?? 0)°"
    }
}
