//
//  ViewController.swift
//  pullup
//
//  Created by Jun on 2023/05/15.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    let animationView = LottieAnimationView(name: "confetti")
    let daysInYear = 365
    let cellWidth: CGFloat = 2
    let cellHeight: CGFloat = 2
    let horizontalSpacing: CGFloat = 2
    let verticalSpacing: CGFloat = 2
    let collectionViewMargin: CGFloat = 100
    let collectionViewHeight: CGFloat = 200
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    let today = Date()
    var dates: [Date] = []
    
    let label: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.itemSize = CGSize(width:20, height:20)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    let button:UIButton = {
        let btn = UIButton(type:.system)
        
        btn.setTitle("운동 완!", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        btn.backgroundColor = .lightGray
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {

        
        super.viewDidLoad()

        dates.append(today)
        for i in 1..<daysInYear {
            let date = Calendar.current.date(byAdding: .day, value: i, to: today)!
            dates.append(date)
        }

        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        view.addSubview(collectionView)
        view.addSubview(button)
        view.addSubview(label)

        

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: collectionViewMargin).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 50).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        collectionView.delegate = self
    }
    
    @objc func handleButtonTap(_ sender: UIButton) {
        // Get the selected cell index path
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }

        // Change the color of the selected cell to green
        let selectedCell = collectionView.cellForItem(at: selectedIndexPath)
        if(selectedCell!.backgroundColor == .lightGray){
            UIView.animate(withDuration: 0.2) {
                selectedCell?.backgroundColor = .green
            }
            
            
            // Store the date in UserDefaults
            let selectedDate = dates[selectedIndexPath.row]
            let dateString = dateFormatter.string(from: selectedDate)
            UserDefaults.standard.set(true, forKey: dateString)
            view.addSubview(animationView)
            animationView.backgroundColor = .clear

            animationView.frame = self.view.frame
            animationView.contentMode = .scaleAspectFit
            animationView.animationSpeed = 2
            animationView.play(fromProgress: 0, toProgress: 0.8) {
                if($0){
                    if let lastSubview = self.view.subviews.last {
                        lastSubview.removeFromSuperview()
                    }
                }
            }
        }else{
            UIView.animate(withDuration: 0.2) {
                selectedCell?.backgroundColor = .lightGray
            }
            
            // Remove the date from UserDefaults
            let selectedDate = dates[selectedIndexPath.row]
            let dateString = dateFormatter.string(from: selectedDate)
            UserDefaults.standard.removeObject(forKey: dateString)
        }
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInYear
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        let date = dates[indexPath.row]
        let dateString = dateFormatter.string(from: date)
//        cell.dateLabel.text = dateString
        
        
        // Set cell color based on UserDefaults value
        let hasPlantedGrass = UserDefaults.standard.bool(forKey: dateString)
        cell.backgroundColor = hasPlantedGrass ? UIColor.green : UIColor.lightGray

        return cell
    }

    
    
    
}

class CollectionViewCell: UICollectionViewCell {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 1
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // get the selected cell's date based on its index path
        let today = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 13))!
        let date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: today)!
        
        label.text = "\("\(date)".split(separator: " ").first!)"
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            selectedCell.isSelected = true
            
            UIView.animate(withDuration: 0.2) {
                selectedCell.layer.borderWidth = 2
                selectedCell.layer.borderColor = UIColor.darkGray.cgColor
            }
            
            
            for cell in collectionView.visibleCells {
                if !cell.isSelected {
                    cell.layer.borderWidth = 0
                }
            }

        }
        
    }
}
