//
//  MainCell.swift
//  RealmExample
//
//  Created by apple on 12.01.2024.
//

import UIKit

final class MainCell: UICollectionViewCell {
    static let reuseId: String = "MainCell"
    
    private lazy var image: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    private lazy var label: UILabel = {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .black
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var text: UILabel = {
        $0.font = .systemFont(ofSize: 12)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textColor = .black
        return $0
    }(UILabel())
    
    func useImage(image: UIImage) {
        self.image.image = image
    }
    
    func createTextForLabel(note: Note){
        self.label.text = note.title
        self.text.text = note.noteText
        self.image.image = UIImage(named: note.image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.addSubview(label)
        image.addSubview(text)
        addSubview(image)
        clipsToBounds = true
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
        self.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            label.topAnchor.constraint(equalTo: image.topAnchor,constant: 5),
            label.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 10),
            label.heightAnchor.constraint(equalToConstant: 15),
            
            text.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            text.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 10),
            text.trailingAnchor.constraint(equalTo: image.trailingAnchor, constant: -10),
            text.bottomAnchor.constraint(equalTo: image.bottomAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
