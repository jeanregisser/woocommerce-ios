import UIKit

class LargeImageTableViewCell: UITableViewCell {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = false
    }
}
