
import UIKit
import PhotosUI

final class StartViewController: UIViewController {
    
    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выбрать фото", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Image Editor"
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(selectImageButton)
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectImageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func selectImageTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension StartViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self,
                  let image = object as? UIImage,
                  error == nil else { return }

            DispatchQueue.main.async {
                let cropVC = CropViewController(image: image) { croppedImage in
                    let editorVC = ImageEditorViewController(originalImage: croppedImage)
                    self.navigationController?.pushViewController(editorVC, animated: true)
                }
                self.navigationController?.pushViewController(cropVC, animated: true)

            }
        }
    }
}
