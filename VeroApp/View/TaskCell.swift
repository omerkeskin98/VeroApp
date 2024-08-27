//
//  TaskCell.swift
//  VeroApp
//
//  Created by Omer Keskin on 26.08.2024.
//




import UIKit
import SnapKit

class TaskCell: UITableViewCell {

    private let taskLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let colorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure labels
        taskLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        taskLabel.font = .boldSystemFont(ofSize: 20)
        descriptionLabel.numberOfLines = 0
        
        // Add labels and colorView to contentView
        contentView.addSubview(taskLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(colorView)
        
        colorView.layer.cornerRadius = 5
        colorView.layer.masksToBounds = true
        
        // Setup constraints using SnapKit
        taskLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(colorView.snp.left).offset(-10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(taskLabel.snp.bottom).offset(5)
            make.left.equalTo(taskLabel.snp.left)
            make.right.equalTo(taskLabel.snp.right)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(titleLabel.snp.right)
            make.bottom.equalToSuperview().inset(10)
        }
        
        colorView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
        }
    }
    
    func configure(with task: TaskEntity) {
        taskLabel.text = task.task
        titleLabel.text = task.title
        descriptionLabel.text = task.taskDescription
        
        if let colorCode = task.colorCode, !colorCode.isEmpty, let color = UIColor(hex: colorCode) {
            colorView.isHidden = false
            colorView.backgroundColor = color
        } else {
            colorView.isHidden = true
        }
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Ensure the string has a valid length
        guard hexString.count == 7, hexString.hasPrefix("#") else {
            return nil
        }
        
        var rgb: UInt64 = 0
        Scanner(string: String(hexString.dropFirst())).scanHexInt64(&rgb)
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
