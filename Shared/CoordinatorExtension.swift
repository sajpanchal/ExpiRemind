//
//  CoordinatorExtension.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-27.
//

import Foundation
extension ScanDateView.Coordinator {
    func getFormattedDate(subString: String) -> (Date,Bool) {
        var subString = subString.filter {
            !$0.isWhitespace && !$0.isPunctuation
        }
        print(subString)
       
        var formattedDate = Date().dayAfter
        var isDateNotFound = true
        var patternArray = [#"^EXP(0[1-9]|1[0-2])[2-9][0-9]$"#, //EXP.MM.YY //0
                            #"^EXP(2[0-9][0-9][0-9])(0[1-9]|1[0-2])$"#, //EXP.YYYY.MM //1
                            #"^EXP(0[1-9]|1[0-2])(2[0-9][0-9][0-9])$"#, //EXP.MM.YYYY //2
                            #"^EXP(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(2[0-9][0-9][0-9])$"#, //EXP.mm.YYYY //3
                            #"^EXP(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(2[0-9][0-9][0-9])$"#, //EXP.mm.YYYY //4
                            #"^EXP(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(2[0-9][0-9][0-9])$"#, //EXP.mm.YYYY //5
                            #"^BB(0[1-9]|1[0-2])(2[0-9][0-9][0-9])$"#, //BB.MM.YYYY //6
                            #"^BB(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(2[0-9][0-9][0-9])$"#, //BB.mm.YYYY //7
                            #"^BB(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(2[0-9][0-9][0-9])$"#, //BB.mm.YYYY  //8
                            #"^BB(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(2[0-9][0-9][0-9])$"#, //BB.mm.YYYY //9
                            #"^[0-9]{2}(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(2[0-9][0-9][0-9])$"#, //DD.mm.YYYY //10
                            #"^[0-9]{2}(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(2[0-9][0-9][0-9])$"#, //DD.mm.YYYY //11
                            #"^[0-9]{2}(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(2[0-9][0-9][0-9])$"#, //DD.mm.YYYY //12
                            #"^[0-9]{2}(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)[2-9][0-9]$"#, //DD.mm.YY //13
                            #"^[0-9]{2}(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)[2-9][0-9]$"#, //DD.mm.YY //14
                            #"^[0-9]{2}(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)[2-9][0-9]$"#, //DD.mm.YY //15
                            #"^(2[0-9][0-9][0-9])(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)[0-9]{2}$"#, //YYYY.mm.DD //16
                            #"^(2[0-9][0-9][0-9])(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)[0-9]{2}$"#, //YYYY.mm.DD //17
                            #"^(2[0-9][0-9][0-9])(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)[0-9]{2}$"#, //YYYY.mm.DD //18
                            #"^(2[0-9][0-9][0-9])(0[1-9]|1[0-2])[0-9]{2}$"#, //YYYY.MM.DD //19
                            #"^(0[1-9]|1[0-2])[0-9]{2}(2[0-9][0-9][0-9])$"#, //MM.DD.YYYY //20
                            #"^(0[1-9]|1[0-2])(2[0-9][0-9][0-9])$"#, //MM.YYYY //21
                            #"^(0[1-9]|1[0-2])[0-9]{2}[2-9][0-9]$"#, //MM.DD.YY //22
                            #"^(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)[0-9][0-9]$"#, //mm.DD //23
                            #"^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)[0-9][0-9]$"#, //mm.DD //24
                            #"^(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)[0-9][0-9]$"#, //mm.DD //25
                            #"^(2[0-9][0-9][0-9])[0-9]{2}(0[1-9]|1[0-2])$"#, //YYYY.DD.MM //26
                            #"^[0-9]{2}(0[1-9]|1[0-2])(2[0-9][0-9][0-9])$"#,//DD.MM.YYYY //27
                            #"^[0-9]{2}(0[1-9]|1[0-2])([0-9][0-9])$"#,//DD.MM.YY //28
                            #"^(0[1-9]|1[0-2])[0-9][0-9]$"#,//MM.DD //29
                            #"^[0-9][0-9](0[1-9]|1[0-2])$"#,//DD.MM //30
                            #"^(0[1-9]|1[0-2])[2-9][0-9]$"#, //MM.YY //31
                            #"^(2[0-9][0-9][0-9])(0[1-9]|1[0-2])$"#, //YYYY.MM //32
                            #"^(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(2[0-9][0-9][0-9])$"#, //mm.YYYY //33
                            #"^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(2[0-9][0-9][0-9])$"#, //mm.YYYY //34
                            #"^(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(2[0-9][0-9][0-9])$"#, //mm.YYYY //35
        ]
      
        var counter = 0
        for pattern in patternArray {
          
            print("Converted month:",subString)
            subString = subString.replacingOccurrences(of: ". ", with: ".")
            subString = subString.replacingOccurrences(of: "- ", with: "-")
            subString = subString.replacingOccurrences(of: "/ ", with: "/")
            
            let regex = try! NSRegularExpression(pattern: pattern)
            if findSubString(regex: regex, subString: subString) != "" {
              
                var dateStr = findSubString(regex: regex, subString: subString)
                dateStr = convertMonth(dateString: dateStr)
                dateStr = splitDateString(counter: counter, dateString:dateStr)
                var dt = dateStr.split {[".","/"," "].contains($0)}
                dt.removeAll(where: { i in
                    if Int(i) == nil {
                        switch i.uppercased() {
                        case "JA","FE","MA","AP","MY","JU","JL","AU","SE","OC","NO","DE":
                            return false
                        case "EXP", "BB","EXPY", "BEST BEFORE" :
                            return true
                        default:
                            return false
                        }
                    }
                    else {
                        return false
                    }
                })
                
                print(dt)
                var newdt: [String] = dt.map { i -> String in
                    switch i.uppercased() {
                    case "JA","JAN","JANUARY":
                        return "01"
                    case "FE","FEB","FEBRUARY":
                        return "02"
                    case "MR","MAR","MARCH":
                        return "03"
                    case "AP","AL","APR","APRIL":
                        return "04"
                    case "MY","MA","MAY":
                        return "05"
                    case "JN","JU","JUN","JUNE":
                        return "06"
                    case "JL","JUL","JULY":
                        return "07"
                    case "AU","AUG","AUGUST":
                        return "08"
                    case "SE","SEP","SEPT","SEPTEMBER":
                        return "09"
                    case "OC","OCT","OCTOBER":
                        return "10"
                    case "NO", "NV","NOV","NOVEMBER":
                        return "11"
                    case "DE","DEC","DECEMBER":
                        return "12"
                    default:
                        return String(i)
                    }
                }
                print("array item index: \(counter)")
                let ddmmyy = arrangeDateArray(dateArr: newdt, counter: counter)
                let myYear: Int = ddmmyy[2]
                let myMonth: Int = ddmmyy[1]
                let myDay: Int = ddmmyy[0]
                let currDate = getMyDate(year: myYear, month: myMonth, day: myDay)
                print(currDate)
               // let dateFormatter = DateFormatter()
                //dateFormatter.dateStyle = .medium
                //formattedDate = dateFormatter.string(from: currDate)
                formattedDate = currDate
                isDateNotFound = false
                print("formatted date:\(formattedDate)")
                break
            }
            counter += 1
        }
         return (formattedDate, isDateNotFound)
    }


    func arrangeDateArray(dateArr:[String], counter: Int) -> [Int]{
        var ddmmyy:[Int] = [00,00,00]
        var dateArr = dateArr
        switch counter {
        case 0,31:
            dateArr.insert("01", at: 0)
            ddmmyy[0] = Int(dateArr[0])!
            ddmmyy[1] = Int(dateArr[1])!
            ddmmyy[2] = Int("20"+dateArr[2])!
            return ddmmyy
        case 1,32:
            dateArr.insert("01", at: 0)
            ddmmyy[0] = Int(dateArr[0])!
            ddmmyy[1] = Int(dateArr[2])!
            ddmmyy[2] = Int(dateArr[1])!
            return ddmmyy
        case 2...9,21,33,34,35:
            dateArr.insert("01", at: 0)
            ddmmyy[0] = Int(dateArr[0])!
            ddmmyy[1] = Int(dateArr[1])!
            ddmmyy[2] = Int(dateArr[2])!
            return ddmmyy
        case 10,11,12,27:
            ddmmyy[0] = Int(dateArr[0])!
            ddmmyy[1] = Int(dateArr[1])!
            ddmmyy[2] = Int(dateArr[2])!
            return ddmmyy
        case 13,14,15,28:
            ddmmyy[0] = Int(dateArr[0])!
            ddmmyy[1] = Int(dateArr[1])!
            ddmmyy[2] = Int("20"+dateArr[2])!
            return ddmmyy
        case 16...19:
            ddmmyy[0] = Int(dateArr[2])!
            ddmmyy[1] = Int(dateArr[1])!
            ddmmyy[2] = Int(dateArr[0])!
            return ddmmyy
        case 20:
            ddmmyy[0] = Int(dateArr[1])!
            ddmmyy[1] = Int(dateArr[0])!
            ddmmyy[2] = Int(dateArr[2])!
            return ddmmyy
        case 22:
            ddmmyy[0] = Int(dateArr[1])!
            ddmmyy[1] = Int(dateArr[0])!
            ddmmyy[2] = Int("20"+dateArr[2])!
            return ddmmyy
        case 23...25,29:
            ddmmyy[0] = Int(dateArr[1])!
            ddmmyy[1] = Int(dateArr[0])!
            let components = Calendar.current.dateComponents([.year], from: Date())
            ddmmyy[2] = (components.year)!
            return ddmmyy
        case 26:
            ddmmyy[0] = Int(dateArr[1])!
            ddmmyy[1] = Int(dateArr[2])!
            ddmmyy[2] =  Int(dateArr[0])!
            return ddmmyy
        case 30:
            ddmmyy[0] = Int(dateArr[0])!
            ddmmyy[1] = Int(dateArr[1])!
            let components = Calendar.current.dateComponents([.year], from: Date())
            ddmmyy[2] = (components.year)!
            return ddmmyy
        default:
            return ddmmyy
        }
    }
    func findSubString(regex: NSRegularExpression, subString: String) -> String {
        let matches = regex.matches(in: subString, options: [], range: NSRange(location: 0, length: subString.utf16.count))
        if let match = matches.first {
            let range = match.range(at: 0)
            if let swiftRange = Range(range, in: subString) {
                let result = subString[swiftRange]
               // print("substring is: ",result)
                return String(result)
            }
        }
        return ""
    }

    func getMyDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
    func convertMonth(dateString: String) -> String {
        let dateString: String = dateString
        let arrayOfMonths = ["JANUARY","JAN","JA","FEBRUARY","FEB","FE","MARCH","MAR","MR", "APRIL","APR","AP","AL","MAY","MY","MA","JUNE","JUN","JU","JN","JULY","JUL","JL","AUGUST","AUG","AU","SEPTEMBER","SEPT","SEP","SE","OCTOBER","OCT","OC","0CTOBER","0CT","0C","NOVEMBER","NOV","NO", "NV","N0VEMBER","N0V","N0","DECEMBER","DEC","DE"]
        var newString = ""
        forloop: for month in arrayOfMonths {
            switch month {
            case "JA","JAN","JANUARY":
                newString = dateString.replacingOccurrences(of: month, with: "01")
                break
            case "FE","FEB","FEBRUARY":
                newString = dateString.replacingOccurrences(of: month, with: "02")
                break
            case "MR","MAR","MARCH":
                newString = dateString.replacingOccurrences(of: month, with: "03")
                break
            case "AP","AL","APR","APRIL":
                newString = dateString.replacingOccurrences(of: month, with: "04")
                break
            case "MY","MA","MAY":
                newString = dateString.replacingOccurrences(of: month, with: "05")
                break
            case "JN","JU","JUN","JUNE":
                newString = dateString.replacingOccurrences(of: month, with: "06")
                break
            case "JL","JUL","JULY":
                newString = dateString.replacingOccurrences(of: month, with: "07")
                break
            case "AU","AUG","AUGUST":
                newString = dateString.replacingOccurrences(of: month, with: "08")
                break
            case "SE","SEP","SEPT","SEPTEMBER":
                newString = dateString.replacingOccurrences(of: month, with: "09")
                break
            case "OC","OCT","OCTOBER","0C","0CT","0CTOBER":
                newString = dateString.replacingOccurrences(of: month, with: "10")
                break
            case "NO", "NV","NOV","NOVEMBER","N0","N0V","N0VEMBER":
                newString = dateString.replacingOccurrences(of: month, with: "11")
                break
            case "DE","DEC","DECEMBER":
                newString = dateString.replacingOccurrences(of: month, with: "12")
                break
            default:
                newString = dateString
            }
            if newString != dateString {
                break forloop
            }
        }
        print(newString)
        return newString
    }

    func splitDateString(counter: Int, dateString:String) -> String {
        var dateString = dateString
        switch counter {
        case 0,2,3,4,5:
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 3))
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 6))
            print(dateString, " at ", counter)
            return dateString
        case 1:
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 3))
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 8))
            print(dateString, " at ", counter)
            return dateString
        case 6...15,20,22,27,28,29,30,31:
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 2))
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 5))
            print(dateString, " at ", counter)
            return dateString
        case 16...19,26:
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 4))
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 7))
            print(dateString, " at ", counter)
            return dateString
        case 21,23...25,33...35:
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 2))
            print(dateString, " at ", counter)
            return dateString
        case 32:
            dateString.insert(".", at: dateString.index(dateString.startIndex, offsetBy: 4))
            print(dateString, " at ", counter)
            return dateString
        default:
            return dateString
        }
    }
}
