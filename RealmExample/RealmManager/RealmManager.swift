//
//  RealmManager.swift
//  RealmExample
//
//  Created by apple on 12.01.2024.
//

import Foundation
import RealmSwift

final class RealmManager {
    
    let realm = try! Realm()
    var notes: [Note]?
    
    init(){
        readNote()
    }
    
    //1 - create
    func createNote(note: Note) {
        try! realm.write{
            realm.add(note)
        }
        readNote()
    }
    
    //2 - read
    func readNote(){
        let notes = realm.objects(Note.self)
        self.notes = Array(notes)
    }
    
    //3 - update
    func updateNote(id: String, newTitle: String){
        guard let note = realm.object(ofType: Note.self, forPrimaryKey: id) else { print("Нет поля по данному id"); return}
        try! realm.write {
            note.noteText = newTitle
            note.date = Date()
        }
        readNote()
    }
    
    //3.1 - updateImage
    func updateImage(id: String, imageName: String){
        guard let note = realm.object(ofType: Note.self, forPrimaryKey: id) else { print("Нет такого id"); return}
        try! realm.write{
            note.image = imageName
            note.date = Date()
        }
        readNote()
    }
    
    //4 - delete
    func deleteNote(id: String){
        guard let note = realm.object(ofType: Note.self, forPrimaryKey: id) else { print("Нет поля по данному id"); return}
        try! realm.write{
            realm.delete(note)
        }
        readNote() 
    }
}
