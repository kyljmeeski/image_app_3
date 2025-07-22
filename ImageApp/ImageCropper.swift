import UIKit

final class CropViewController: UIViewController {

    private let image: UIImage
    private let imageView = UIImageView()
    private let cropAreaView = UIView()
    private let cropButton = UIButton(type: .system)
    private var completion: ((UIImage) -> Void)?

    init(image: UIImage, completion: @escaping (UIImage) -> Void) {
        self.image = image
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupImageView()
        setupCropArea()
        setupCropButton()
    }

    private func setupImageView() {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }

    private func setupCropArea() {
        cropAreaView.layer.borderColor = UIColor.red.cgColor
        cropAreaView.layer.borderWidth = 2
        cropAreaView.backgroundColor = .clear
        cropAreaView.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        imageView.addSubview(cropAreaView)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cropAreaView.addGestureRecognizer(pan)
    }

    private func setupCropButton() {
        cropButton.setTitle("Обрезать", for: .normal)
        cropButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        view.addSubview(cropButton)
        cropButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cropButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            cropButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: imageView)
        cropAreaView.center = CGPoint(x: cropAreaView.center.x + translation.x,
                                      y: cropAreaView.center.y + translation.y)
        gesture.setTranslation(.zero, in: imageView)
    }

    @objc private func cropImage() {
        guard let cgImage = image.cgImage else { return }

        // Получаем frame crop области относительно image
        let scale = image.size.width / imageView.frame.width
        let cropFrame = cropAreaView.convert(cropAreaView.bounds, to: imageView)
        let cropRect = CGRect(x: cropFrame.origin.x * scale,
                              y: cropFrame.origin.y * scale,
                              width: cropFrame.width * scale,
                              height: cropFrame.height * scale)

        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
            completion?(croppedImage)
        }

        navigationController?.popViewController(animated: true)
    }
}
