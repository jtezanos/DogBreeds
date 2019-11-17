import UIKit
import AlamofireImage

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}

extension ImageCell {
    
    func setup(with url: String) {        
        guard let url = URL(string: url) else {
            // TODO: set default image when we have no url
            return
        }
        
        imageView.af_setImage(withURL: url)
    }
}
