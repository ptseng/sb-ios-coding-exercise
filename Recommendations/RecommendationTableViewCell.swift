//
//  RecommendationTableViewCell.swift
//  Recommendations
//

import UIKit

class RecommendationTableViewCell: UITableViewCell {
    @IBOutlet weak var recommendationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    var recommendation: Recommendation!
    var onReuse: ((Recommendation) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?(recommendation)
        recommendation = nil
        recommendationImageView.image = nil
        titleLabel.text = nil
        taglineLabel.text = nil
        ratingLabel.text = nil
    }

    func configure(with recommendation: Recommendation) {
        self.recommendation = recommendation
        titleLabel.text = recommendation.title
        taglineLabel.text = recommendation.tagline

        if let rating = recommendation.rating {
            ratingLabel.text = "Rating: \(rating)"
        } else {
            ratingLabel.text = "Rating: None"
        }
    }
}
