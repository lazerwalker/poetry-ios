import Foundation
import SafariServices
import UIKit

class AcknowledgementsViewController : UITableViewController, SFSafariViewControllerDelegate {
    var completionBlock:((Void) -> Void)?

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath),
            let subtitle = cell.detailTextLabel?.text,
            let url = NSURL(string: subtitle) {
                let vc = SFSafariViewController(URL: url)
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    @IBAction func didTapDoneButton(sender: AnyObject) {
        if let cb = completionBlock {
            cb()
        }
    }
    
    //-
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
