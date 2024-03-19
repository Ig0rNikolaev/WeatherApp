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
}

final class WeatherCell: UITableViewCell {
    //: MARK: - Properties

    static var identifier: String { ConstantsCell.identifier }

    //: MARK: - UI Elements

    private lazy var weatherImage: UIImageView = {
        let image =  UIImageView()
        image.image = UIImage(systemName: "sun.max")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.tintColor = .black
        return image
    }()

    private lazy var dayWeekLabel: UILabel = {
        let label = UILabel()
        label.text = "Today"
        label.font = UIFont.preferredFont(forTextStyle: .headline).withSize(20)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var temperatureCellLabel: UILabel = {
        let label = UILabel()
        label.text = "25°"
        label.font = UIFont.preferredFont(forTextStyle: .body).withSize(20)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var weatherStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [temperatureCellLabel, weatherImage])
        stack.axis = .horizontal
        stack.spacing = 10
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
        temperatureCellLabel.text = nil
    }

    private func setupHierarchy() {
        let views = [dayWeekLabel, weatherStack]
        contentView.addViews(views)
    }

    private func setupLayout() {
        dayWeekLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }

        weatherStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
            make.height.equalTo(40)
            make.width.equalTo(110)
        }
    }

    func createWeatherContent() {
        dayWeekLabel.text = "Today"
        weatherImage.image =  UIImage(systemName: "sun.max")
        temperatureCellLabel.text = "25°"
    }
}
