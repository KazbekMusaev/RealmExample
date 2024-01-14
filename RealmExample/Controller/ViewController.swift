//
//  ViewController.swift
//  RealmExample
//
//  Created by apple on 12.01.2024.
//

import UIKit

final class ViewController: UIViewController{

    var textForTextFieldChange: String = "" // пришлось пойти на это, для того, чтобы можно было поменять текст в ячейке
    var imageNameBySaved: String = "" // чтобы сохранить название фотографии, или путь к фотографии
    var imageFromUse: UIImage?
    
    private let realmMeneger = RealmManager()
    
    private lazy var mainCollection : UICollectionView = {
        $0.register(MainCell.self, forCellWithReuseIdentifier: MainCell.reuseId)
        $0.dataSource = self
        $0.delegate = self
        return $0
    }(UICollectionView(frame: view.bounds, collectionViewLayout: layout))
    
    private lazy var layout : UICollectionViewFlowLayout = {
        $0.itemSize = .init(width: view.frame.width - 40, height: 150)
        return $0
    }(UICollectionViewFlowLayout())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainCollection)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.app"), style: .done, target: self, action: #selector(actionForPlusButton(sender: )))
    }
    
    @objc
    func actionForPlusButton(sender : UIBarButtonItem) {
        let allert = UIAlertController(title: "Create note", message: nil, preferredStyle: .alert)
        allert.addTextField { text in
            text.placeholder = "Название заметки"
        }
        allert.addTextField { text in
            text.placeholder = "Текст заметки"
        }
        let saveBtn = UIAlertAction(title: "Save", style: .default) { _ in
            let note = Note()
            if let text = allert.textFields?[0].text {
                note.title = text
            } else {
                print("Вы не добавили текст")
            }
            if let textForNote = allert.textFields?[1].text {
                note.noteText = textForNote
            } else {
                print("Вы не добавили текст ")
            }
            self.realmMeneger.createNote(note: note)
            self.mainCollection.reloadData()
        }
        let closeBtn = UIAlertAction(title: "Close", style: .destructive)
        
        allert.addAction(saveBtn)
        allert.addAction(closeBtn)
        self.present(allert, animated: true)
    }

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let notes = realmMeneger.notes?.count else { return 0 }
        return notes
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: MainCell.reuseId, for: indexPath) as? MainCell {
            if let note = realmMeneger.notes?[indexPath.item] {
                cell.createTextForLabel(note: note)
            }
            if let image = imageFromUse {
                cell.useImage(image: image)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let noteId = realmMeneger.notes?[indexPath.item].id else { return }
        let alert = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        let deleteBtn = UIAlertAction(title: "Удалить", style: .default) { _ in
            UIView.animate(withDuration: 0.5) {
                self.realmMeneger.deleteNote(id: noteId)
                self.mainCollection.deleteItems(at: [indexPath])
            }
        }
        
        let editBtn = UIAlertAction(title: "Изменить", style: .default) { _ in
            let textField = UITextField()
            textField.placeholder = "Введите изменение"
            textField.delegate = self
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.backgroundColor = .lightGray
            textField.layer.cornerRadius = 20
            self.view.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
                textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                textField.heightAnchor.constraint(equalToConstant: 200),
            ])
            self.realmMeneger.updateNote(id: noteId, newTitle: self.textForTextFieldChange)
        }
        
        let imageEditBtn = UIAlertAction(title: "Поменять фотку", style: .default) { _ in
            let alertForImageChange = UIAlertController(title: "Откуда вам нужна фотография", message: nil, preferredStyle: .actionSheet)
            let unSplashUseImageBtn = UIAlertAction(title: "UnSplah", style: .default) { _ in
                print("You use Unsplash")
            }
            let imagePicker = UIAlertAction(title: "UIImagePicker", style: .default) { _ in
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
                self.realmMeneger.updateImage(id: noteId, imageName: self.imageNameBySaved)
            }
            let btnExitFromImageChange = UIAlertAction(title: "Выход", style: .cancel)
            
            alertForImageChange.addAction(unSplashUseImageBtn)
            alertForImageChange.addAction(imagePicker)
            alertForImageChange.addAction(btnExitFromImageChange)
            
            self.present(alertForImageChange, animated: true)
        }
        
        let notBtn = UIAlertAction(title: "Ничего не делать", style: .cancel)
        alert.addAction(deleteBtn)
        alert.addAction(editBtn)
        alert.addAction(imageEditBtn)
        alert.addAction(notBtn)
        self.present(alert, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            self.textForTextFieldChange = text
        }
        UIView.animate(withDuration: 0.5) {
            self.mainCollection.reloadData()
        }
        textField.removeFromSuperview()
        return true
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.imageFromUse = image
        }
        self.mainCollection.reloadData()
        picker.dismiss(animated: true )
    }
}
