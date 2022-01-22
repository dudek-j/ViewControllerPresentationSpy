import UIKit

extension UIAlertController {

    @objc class func qcoMock_swizzle() {
        UIAlertController.qcoMockAlerts_replaceClassMethod(
                #selector(UIAlertController.init(title:message:preferredStyle:)),
                withMethod: #selector(UIAlertController.qcoMock_alertController(title:message:preferredStyle:))
        )

        #if (os(iOS))
            UIAlertController.qcoMockAlerts_replaceInstanceMethod(
                    #selector(getter: UIAlertController.popoverPresentationController),
                    withMethod: #selector(UIAlertController.qcoMock_popoverPresentationController)
            )
        #endif
    }
    
    @objc class func qcoMock_alertController(
            title: String,
            message: String,
            preferredStyle: UIAlertController.Style
    ) -> UIAlertController {
        return UIAlertController.init(qcoMockWithTitle: title, message:message, preferredStyle:preferredStyle)
    } 
    
    /*
+ (instancetype)qcoMock_alertControllerWithTitle:(NSString *)title
                                    message:(NSString *)message
                             preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [[self alloc] initQCOMockWithTitle:title message:message preferredStyle:preferredStyle];
}
     */
}
