//
//  ViewController.swift
//  RealmExample
//
//  Created by apple on 12.01.2024.
//

import UIKit

final class ViewController: UIViewController{
    
    private let realmMeneger = RealmManager()
    private let storageManager = StorageManager()
    
    var noteIdForImagePicker: String = "" // Для передачи названия id,через алерт ImagePicker, и для установки фотографии в правельное поле
    
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
            
            lazy var actionForBtnSaveNoteText = UIAction { _ in
                if let text = textField.text {
                    self.realmMeneger.updateNote(id: noteId, newTitle: text)
                }
                UIView.animate(withDuration: 0.5) {
                    self.mainCollection.reloadData()
                }
                textField.removeFromSuperview()
                btnSaveNoteText.removeFromSuperview()
            }
            lazy var btnSaveNoteText: UIButton = {
                $0.setTitle("Сохранить текст", for: .normal)
                $0.backgroundColor = .darkGray
                $0.setTitleColor(.blue, for: .normal)
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.layer.cornerRadius = 16
                return $0
            }(UIButton(primaryAction: actionForBtnSaveNoteText))
            self.view.addSubview(btnSaveNoteText)
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
                textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                textField.heightAnchor.constraint(equalToConstant: 200),
                
                btnSaveNoteText.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 50),
                btnSaveNoteText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                btnSaveNoteText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                btnSaveNoteText.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
        
        let imageEditBtn = UIAlertAction(title: "Поменять фотку", style: .default) { _ in
            let alertForImageChange = UIAlertController(title: "Откуда вам нужна фотография", message: nil, preferredStyle: .actionSheet)
            let unSplashUseImageBtn = UIAlertAction(title: "UnSplah", style: .default) { _ in
                print("You use Unsplash")
            }
            let imagePicker = UIAlertAction(title: "UIImagePicker", style: .default) { _ in
                self.noteIdForImagePicker = noteId
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
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
        textField.endEditing(true)
        return true
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let randomValue = Int.random(in: 0...100000) // Тут могут получится совпадения, если будет большое количество фотографии
        let randomName = String(randomValue)
        
        if let image = info[.editedImage] as? UIImage {
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                storageManager.saveImage(imageData: imageData, namePhoto: randomName)
                self.realmMeneger.updateImage(id: self.noteIdForImagePicker, imageName: randomName)
            }
        }
        
        self.mainCollection.reloadData()
        picker.dismiss(animated: true )
    }
}
