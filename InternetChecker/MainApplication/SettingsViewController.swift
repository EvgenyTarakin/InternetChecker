//
//  SettingsViewController.swift
//  InternetChecker
//
//  Created by Евгений Таракин on 07.04.2024.
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    
    // MARK: - private property
    // Основные проперти
    private lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Тема"
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let items = ["Светлая", "Темная", "Системная"]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.addTarget(self, action: #selector(selectItemSegmentControl), for: .valueChanged)
        segmentControl.selectedSegmentIndex = UserDefaults.standard.value(forKey: "theme") as? Int ?? 2
        
        return segmentControl
    }()
    
    private lazy var serverTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "URL сервера:"
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var valueServerLabel: UILabel = {
        let label = UILabel()
        label.text = "https://uk.loadingtest.com"
        label.font = .systemFont(ofSize: 20)
        
        return label
    }()
    
    private lazy var speedDownloadTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Измерять скорость загрузки"
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var downloadSwitch: UISwitch = {
        let downloadSwitch = UISwitch()
        downloadSwitch.onTintColor = .systemBlue
        downloadSwitch.isOn = UserDefaults.standard.bool(forKey: "isOnDownload")
        downloadSwitch.addTarget(self, action: #selector(changeValueDownloadSwitch), for: .valueChanged)
        
        return downloadSwitch
    }()
    
    private lazy var speedUploadTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Измерять скорость отдачи"
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var uploadSwitch: UISwitch = {
        let uploadSwitch = UISwitch()
        uploadSwitch.onTintColor = .systemBlue
        uploadSwitch.isOn = UserDefaults.standard.bool(forKey: "isOnUpload")
        uploadSwitch.addTarget(self, action: #selector(changeValueUploadSwitch), for: .valueChanged)
        
        return uploadSwitch
    }()

    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }

}

// MARK: - private func

private extension SettingsViewController {
    func commonInit() {
        // Верстка и установка заголовка
        title = "Настройки"
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(segmentControl)
        view.addSubview(themeLabel)
        view.addSubview(valueServerLabel)
        view.addSubview(serverTitleLabel)
        view.addSubview(downloadSwitch)
        view.addSubview(uploadSwitch)
        view.addSubview(speedDownloadTitleLabel)
        view.addSubview(speedUploadTitleLabel)
        
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.right.equalToSuperview().inset(16)
        }
        themeLabel.snp.makeConstraints {
            $0.centerY.equalTo(segmentControl.snp.centerY)
            $0.left.equalToSuperview().inset(16)
        }
        valueServerLabel.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).inset(-24)
            $0.right.equalToSuperview().inset(16)
        }
        serverTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(valueServerLabel.snp.centerY)
            $0.left.equalToSuperview().inset(16)
        }
        downloadSwitch.snp.makeConstraints {
            $0.top.equalTo(valueServerLabel.snp.bottom).inset(-24)
            $0.right.equalToSuperview().inset(16)
        }
        uploadSwitch.snp.makeConstraints {
            $0.top.equalTo(downloadSwitch.snp.bottom).inset(-24)
            $0.right.equalToSuperview().inset(16)
        }
        speedDownloadTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(downloadSwitch.snp.centerY)
            $0.left.equalToSuperview().inset(16)
        }
        speedUploadTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(uploadSwitch.snp.centerY)
            $0.left.equalToSuperview().inset(16)
        }
    }
}

// MARK: - obj-c

@objc private extension SettingsViewController {
    func selectItemSegmentControl(sender: UISegmentedControl) {
        // Сохранение настройки темы приложения
        UserDefaults.standard.setValue(sender.selectedSegmentIndex, forKey: "theme")
        switch sender.selectedSegmentIndex {
        case 0: navigationController?.overrideUserInterfaceStyle = .light
        case 1: navigationController?.overrideUserInterfaceStyle = .dark
        default: navigationController?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func changeValueDownloadSwitch(sender: UISwitch) {
        // Сохранение настройки чекбокса загруки
        UserDefaults.standard.setValue(sender.isOn, forKey: "isOnDownload")
    }
    
    func changeValueUploadSwitch(sender: UISwitch) {
        // Сохранение настройки чекбокса отдачи
        UserDefaults.standard.setValue(sender.isOn, forKey: "isOnUpload")
    }
}
