// Copyright (c) 2018 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit

protocol ImagePicking {

    /// Displays an action sheet to allow you to pick an image from either the library or (if available) the camera.
    ///
    /// - Parameter editable: True if the image should be editable, false if not
    func showImageSourceSelectionActionSheet(editable: Bool)

    /// Called when an image is actually selected.
    ///
    /// - Parameter image: The image which was returned from the image picker.
    func selectedImage(_ image: UIImage)
}

extension ImagePicking where Self: UIViewController,
                             Self: UIImagePickerControllerDelegate,
                             Self: UINavigationControllerDelegate {

    func showImageSourceSelectionActionSheet(editable: Bool) {
        var actions = [UIAlertAction]()

        actions.append(UIAlertAction(title: Localized.image_picker_library_action_title,
                                     style: .default,
                                     handler: { _ in
                                        self.presentImagePicker(sourceType: .photoLibrary, editable: editable)
                                     })
        )

        // Only add the camera option if there actually is a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actions.append(UIAlertAction(title: Localized.image_picker_camera_action_title,
                                         style: .default,
                                         handler: { _ in
                                            self.presentImagePicker(sourceType: .camera, editable: editable)
                                         })
            )
        }

        actions.append(.cancelAction())

        showActionSheet(title: Localized.image_picker_select_source_title,
                        actions: actions)
    }

    private func presentImagePicker(sourceType: UIImagePickerControllerSourceType, editable: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = editable
        imagePicker.delegate = self

        present(imagePicker, animated: true)
    }

    func dismissImagePicker(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func handlePicker(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        dismissImagePicker(picker)

        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage(editedImage)
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage(originalImage)
        } else {
            assertionFailure("IMAGE PICKING: No edited or original image found!")
        }
    }
}
