
import UIKit

final class ImageEditorViewController: UIViewController {

    private let imageView = UIImageView()
    private let originalImage: UIImage
    
    private let brightnessSlider = UISlider()
    private let contrastSlider = UISlider()
    private let saturationSlider = UISlider()
    private let monoSwitch = UISwitch()
    private let shareButton = UIButton(type: .system)

    private var currentCIImage: CIImage?
    private let context = CIContext()

    init(originalImage: UIImage) {
        self.originalImage = originalImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        
        setupImageView()
        setupControls()
        applyFilters() // покажем изначальное изображение

    }

    private func setupImageView() {
        imageView.image = originalImage
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupControls() {
        brightnessSlider.minimumValue = -1
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0

        contrastSlider.minimumValue = 0.5
        contrastSlider.maximumValue = 2.0
        contrastSlider.value = 1

        saturationSlider.minimumValue = 0
        saturationSlider.maximumValue = 2.0
        saturationSlider.value = 1

        [brightnessSlider, contrastSlider, saturationSlider].forEach {
            $0.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        }

        monoSwitch.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        shareButton.setTitle("Поделиться", for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            labeled("Яркость", brightnessSlider),
            labeled("Контраст", contrastSlider),
            labeled("Насыщенность", saturationSlider),
            labeled("Монохром", monoSwitch),
            shareButton
        ])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func labeled(_ text: String, _ control: UIView) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.widthAnchor.constraint(equalToConstant: 120).isActive = true

        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }

    @objc private func sliderChanged() {
        applyFilters()
    }
    
    private func applyFilters() {
        guard let inputCIImage = CIImage(image: originalImage) else { return }

        let colorFilter = CIFilter(name: "CIColorControls")!
        colorFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        colorFilter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        colorFilter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        colorFilter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)

        var outputImage = colorFilter.outputImage

        if monoSwitch.isOn {
            let monoFilter = CIFilter(name: "CIPhotoEffectMono")!
            monoFilter.setValue(outputImage, forKey: kCIInputImageKey)
            outputImage = monoFilter.outputImage
        }

        guard let finalImage = outputImage,
              let cgImage = context.createCGImage(finalImage, from: finalImage.extent) else { return }

        imageView.image = UIImage(cgImage: cgImage)
    }
    
    @objc private func shareTapped() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
