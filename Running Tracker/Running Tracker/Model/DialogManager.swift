import Foundation
import UIKit

class DialogManager {
    
    class func showAlert(withTitle title: String?, message: String, withCancelButton: Bool, noDefaultCancelText cancelText: String?, cancelHandler: ((_ action: UIAlertAction?) -> Void)? = nil, withOkButton: Bool, noDefaultOkText okText: String?, okHandler: ((_ action: UIAlertAction?) -> Void)? = nil, viewController vc: UIViewController, tintColor: UIColor) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if withCancelButton {
            let cancelAction = UIAlertAction(title: cancelText ?? "Cancelar", style: .cancel, handler: cancelHandler)
            alert.addAction(cancelAction)
        }
        if withOkButton {
            let okAction = UIAlertAction(title: okText ?? "Aceptar", style: .default, handler: okHandler)
            alert.addAction(okAction)
        }
        alert.view.tintColor = tintColor
        vc.present(alert, animated: true)
    }
    
    class func showActionSheet(withTitle title: String?, withButtonsActions buttonsActions: [UIAlertAction], cancelButton: Bool, viewController vc: UIViewController, tintColor: UIColor, sourceView source: UIView) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for action in buttonsActions {
            alert.addAction(action)
        }
        if cancelButton {
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        alert.view.tintColor = tintColor
        alert.modalPresentationStyle = .popover
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = source
        popPresenter?.sourceRect = source.bounds
        vc.present(alert, animated: true)
    }
}
