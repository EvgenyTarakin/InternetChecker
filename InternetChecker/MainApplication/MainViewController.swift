//
//  ViewController.swift
//  InternetChecker
//
//  Created by Евгений Таракин on 07.04.2024.
//

import UIKit
import SnapKit
import SpeedcheckerSDK
import CoreLocation

final class MainViewController: UIViewController {
    
    // MARK: - private property
    // Раздел основных проперти
    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    
    private var isOnDownload = false
    private var isOnUpload = false
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Измерить скорость", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setImage(UIImage(), for:.normal)
        button.addTarget(self, action: #selector(tapCheckButton), for: .touchUpInside)
        button.layer.cornerRadius = 100
        
        return button
    }()
    
    // MARK: - Progress
    // Раздел проперти для отображения процесса
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0.0
        progressView.isHidden = true
        
        return progressView
    }()
    
    private lazy var processLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .systemBlue
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Дождитесь результатов тестирования!"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    // MARK: - Result
    // Раздел проверти для отображения результатов
    private lazy var resultStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleResultLabel, resultDownloadLabel, resultUploadLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private lazy var titleResultLabel: UILabel = {
        let label = UILabel()
        label.text = "Результаты последнего тестирования:"
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 18)
        label.isHidden = (UserDefaults.standard.value(forKey: "speedDownload") == nil && UserDefaults.standard.value(forKey: "speedUpload") == nil)
        
        return label
    }()
    
    private lazy var resultDownloadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .boldSystemFont(ofSize: 20)
        
        let value = UserDefaults.standard.value(forKey: "speedDownload")
        label.isHidden = value == nil
        label.text = "Отправка - \(value ?? 0) mbps"
        
        return label
    }()
    
    private lazy var resultUploadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .boldSystemFont(ofSize: 20)
        
        let value = UserDefaults.standard.value(forKey: "speedUpload")
        label.isHidden = value == nil
        label.text = "Отправка - \(value ?? 0) mbps"
        
        return label
    }()

    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        configurateLocationManager()
    }

}

// MARK: - private func

private extension MainViewController {
    func commonInit() {
        // Верстка и установка кнопки навигации
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Настройки",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(tapRightNavigationButton))
        
        view.addSubview(checkButton)
        view.addSubview(progressView)
        view.addSubview(processLabel)
        view.addSubview(progressLabel)
        view.addSubview(resultStackView)
        
        checkButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(200)
        }
        progressView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(checkButton.snp.width)
        }
        processLabel.snp.makeConstraints {
            $0.bottom.equalTo(progressView.snp.top).inset(-32)
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
        }
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).inset(-32)
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
        }
        resultStackView.snp.makeConstraints {
            $0.bottom.left.right.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    func configurateLocationManager() {
        // Установка менеджера для распознания локации пользователя
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    func clearProcessLabel() {
        // Очистка названия процесса
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            processLabel.text = ""
        }
    }
}

// MARK: - obj-c

@objc private extension MainViewController {
    func tapRightNavigationButton() {
        // Переход в раздел Настройки
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func tapCheckButton() {
        // Отработка основного функциона после нажатия
        isOnDownload = UserDefaults.standard.bool(forKey: "isOnDownload")
        isOnUpload = UserDefaults.standard.bool(forKey: "isOnUpload")
        
        if isOnDownload || isOnUpload {
            // Отработка после проверки чекбоксов
            navigationItem.rightBarButtonItem?.isHidden = true
            
            checkButton.isHidden = true
            progressView.isHidden = false
            progressLabel.isHidden = false
            processLabel.isHidden = false
            
            titleResultLabel.isHidden = true
            resultDownloadLabel.isHidden = true
            resultUploadLabel.isHidden = true
            
            progressView.progress = 0.0
            clearProcessLabel()
            
            UserDefaults.standard.removeObject(forKey: "speedDownload")
            UserDefaults.standard.removeObject(forKey: "speedUpload")
            
            internetTest = nil
            internetTest = InternetSpeedTest(delegate: self)
            internetTest?.startFreeTest { error in
                if (error != .ok) {
                    return print("speedTest did fail: \(error.rawValue)")
                }
            }
        } else {
            // Показ предупреждения в случае если в настройках нет активных чекбоксов
            let alert = UIAlertController(title: nil,
                                          message: "Измените параметры в настройках для вычисления скорости",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понятно", style: .cancel))
            
            present(alert, animated: true)
        }
    }
}

// MARK: - InternetSpeedTestDelegate

extension MainViewController: InternetSpeedTestDelegate {
    func internetTestError(error: SpeedcheckerSDK.SpeedTestError) { }
    
    func internetTestFinish(result: SpeedcheckerSDK.SpeedTestResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            navigationItem.rightBarButtonItem?.isHidden = false
            checkButton.isHidden = false
            progressView.isHidden = true
            progressLabel.isHidden = true
            processLabel.isHidden = true
        }
    }
    
    func internetTestReceived(servers: [SpeedcheckerSDK.SpeedTestServer]) {}
    
    func internetTestSelected(server: SpeedcheckerSDK.SpeedTestServer, latency: Int, jitter: Int) {}
    
    func internetTestDownloadStart() {
        clearProcessLabel()
    }
    
    func internetTestDownloadFinish() {}
    
    func internetTestDownload(progress: Double, speed: SpeedcheckerSDK.SpeedTestSpeed) {
        if isOnDownload {
            processLabel.text = "Загрузка"
            progressView.progress = Float(progress)
            if progress == 1 {

                titleResultLabel.isHidden = false
                resultDownloadLabel.isHidden = false
                resultDownloadLabel.text = "Загрузка - \(speed.mbps) mbps"
                // Сохрание значения скорости загрузки
                UserDefaults.standard.setValue(speed.mbps, forKey: "speedDownload")
                
                if isOnDownload && !isOnUpload {
                    internetTest?.forceFinish({ error in })
                    
                    navigationItem.rightBarButtonItem?.isHidden = false
                    checkButton.isHidden = false
                    progressView.isHidden = true
                    progressLabel.isHidden = true
                    processLabel.isHidden = true
                }
            }
        } else {
            return
        }
    }
    
    func internetTestUploadStart() {
        clearProcessLabel()
    }
    
    func internetTestUploadFinish() {}
    
    func internetTestUpload(progress: Double, speed: SpeedcheckerSDK.SpeedTestSpeed) {
        if isOnUpload {
            processLabel.text = "Отправка"
            progressView.progress = Float(progress)
            if progress == 1 {

                titleResultLabel.isHidden = false
                resultUploadLabel.isHidden = false
                resultUploadLabel.text = "Отдача - \(speed.mbps) mbps"
                // Сохрание значения скорости отдачи
                UserDefaults.standard.setValue(speed.mbps, forKey: "speedUpload")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {}
