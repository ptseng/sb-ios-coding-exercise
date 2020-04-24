//
//  ViewController.swift
//  Recommendations
//

import UIKit
import OHHTTPStubs

final class RecommendationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var recommendations: [Recommendation] = [] { didSet { tableView.reloadData() } }
    private var imageCache: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---------------------------------------------------
        // -------- <DO NOT MODIFY INSIDE THIS BLOCK> --------
        // stub the network response with our local ratings.json file
        let stub = Stub()
        stub.registerStub()
        // -------- </DO NOT MODIFY INSIDE THIS BLOCK> -------
        // ---------------------------------------------------
        title = "Top 10 Recommendations"
        tableView.register(UINib(nibName: "RecommendationTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self

        Networking()
            .load(resource: GetRecommendationsResponse.resource()) { [unowned self] data, request, error in
                guard let data = data else { return }
                let arraySlice = data.titles
                    .filter { $0.is_released == true }
                    .filter { !data.skipped.contains($0.title) }
                    .filter { !data.titles_owned.contains($0.title) }
                    .sorted { $0.rating ?? 0.0 > $1.rating ?? 0.0 }
                    .prefix(10)
                let recommendations = Array(arraySlice)
                DispatchQueue.main.async { self.recommendations = recommendations }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageCache = [:]
    }

    private func fetchImage(for recommendation: Recommendation, completion: @escaping (UIImage?) -> Void) {
        if let image = imageCache[recommendation.image] {
            completion(image)
            return
        }
        Networking()
            .loadImage(resource: GetRecommendationsResponse.imageResource(for: recommendation)) { [unowned self] image, error in
                guard let image = image else { return }
                self.imageCache[recommendation.image] = image
                DispatchQueue.main.async { completion(image) }
        }
    }
}

extension RecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension RecommendationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecommendationTableViewCell
        let recommendation = recommendations[indexPath.row]
        cell.configure(with: recommendation)
        cell.onReuse = { Networking().cancelRequest(for: $0.image) }
        fetchImage(for: recommendation) { cell.recommendationImageView.image = $0 }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }
}
