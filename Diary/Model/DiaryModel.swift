//
//  DiaryModel.swift
//  Diary
//
//  Created by kamikuo on 2020/10/1.
//

import Foundation

class DiaryModel {
    static let share = DiaryModel()
    private init() {}
    
    private var diaries = [String: JSONDictionary]()
    
    func getDiary(at date: Date) -> JSONDictionary {
        let dateString = Calendar.current.startOfDay(for: date).formattedDate(format: "yyyy-MM-dd")
        
        if let diary = diaries[dateString] {
            return diary
        }
        
        var result = JSONDictionary()
        if let diaryData = SqliteController.main.query("SELECT diary FROM diaries WHERE date=\"\(dateString)\"")?.first?["diary"] as? Data {
            if let diary = try? JSONSerialization.jsonObject(with: diaryData, options: []) as? JSONDictionary {
                result = diary
            }
        }
        diaries[dateString] = result
        
        return result
    }
    
    func getDiaries(from fromDate: Date, to toDate: Date) -> [Date: JSONDictionary] {
        let fromDateString = Calendar.current.startOfDay(for: fromDate).formattedDate(format: "yyyy-MM-dd")
        let toDateString = Calendar.current.startOfDay(for: toDate).formattedDate(format: "yyyy-MM-dd")
        
        var result = [Date: JSONDictionary]()
        SqliteController.main.query("SELECT date, diary FROM diaries WHERE date>=\"\(fromDateString)\" AND date<=\"\(toDateString)\"")?.forEach({ (row) in
            if let diariesData = row["diary"] as? Data, let diary = try? JSONSerialization.jsonObject(with: diariesData, options: []) as? JSONDictionary, let date = Date(string: row["date"] as! String, format: "yyyy-MM-dd") {
                result[date] = diary
                diaries[row["date"] as! String] = diary
            }
        })
        return result
    }
    
    static let updateNotificationName = NSNotification.Name("diaryDidUpdated")
    
    func updateDiary(_ diary: JSONDictionary, at date: Date) {
        let startDate = Calendar.current.startOfDay(for: date)
        let dateString = startDate.formattedDate(format: "yyyy-MM-dd")
        let newDiary = getDiary(at: date).merging(diary, uniquingKeysWith: { $1 })
        diaries[dateString] = newDiary
        if let newDiaryData = try? JSONSerialization.data(withJSONObject: newDiary, options: []) {
            SqliteController.main.upsert(["diary": newDiaryData], to: "diaries", where: ["date": dateString])
        }
        
        NotificationCenter.default.post(name: DiaryModel.updateNotificationName, object: self, userInfo: ["date": startDate, "diary": newDiary])
    }
}
