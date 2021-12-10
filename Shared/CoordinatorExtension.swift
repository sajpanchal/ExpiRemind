//
//  CoordinatorExtension.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-27.
//

import Foundation
extension ScanDateView.Coordinator {
    //a method that takes the scanned text from camera, performs validation by comparing it to regex patterns and converts it to a Date type and returns it.
    func getFormattedDate(scannedText: String) -> (Date,Int) {
        // remove whitespaces and puntuation texts from a string
        var scannedText = scannedText.filter {
            !$0.isWhitespace && !$0.isPunctuation
        }
        print(scannedText)
       
        //var that will hold the Date type to be returned back.
        var formattedDate = Date().dayAfter
        
        //variable that will determine whether a given scanned text is a valid date or not.
        var isDateNotFound = 0
       
        //array of regex to identify valid date format for a scanned text.
        let dateFormatsRegex = [#"^EXP(0[1-9]|1[0-2])[2-9][0-9]$"#, //EXP.MM.YY //0
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
                                #"^(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(0[0-9]|1[0-2])(20[0-9][0-9])$"#, //mm.DD.YYYY 36
                                #"^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(0[0-9]|1[0-2])(20[0-9][0-9])$"#, //mm.DD.YYYY 37
                                #"^(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(0[0-9]|1[0-2])(20[0-9][0-9])$"#, //mm.DD.YYYY 38
        ]
        
        //counter will increment in regex iteration loop until a valid regex is found.
        var counter = 0
        
        //iterate thorugh regex array of date formats.
        for dateFormat in dateFormatsRegex {
          
            print("Converted month:",scannedText)
            
            //remove extra whitespaces from a scanned text if present.
            scannedText = scannedText.replacingOccurrences(of: ". ", with: ".")
            scannedText = scannedText.replacingOccurrences(of: "- ", with: "-")
            scannedText = scannedText.replacingOccurrences(of: "/ ", with: "/")
            scannedText = scannedText.replacingOccurrences(of: ", ", with: ",")
            
            //create a Regular Expression type from regex string.
            let regex = try! NSRegularExpression(pattern: dateFormat)
            
            //a method that will return the matched text by matching a regex with a scanned text.
            if findSubString(regex: regex, subString: scannedText) != "" {
                
                //store validated text
                var validatedScannedText = findSubString(regex: regex, subString: scannedText)
                //replace the month abbreviation with 2 digit month.
                validatedScannedText =  digitizeMonthAbbreviation(dateString: validatedScannedText)
                //format the date with puncuations between date elements.
                validatedScannedText = formatDateString(counter: counter, dateString:validatedScannedText)
                
                //split the validated text by puncuations and create a substring array with date, month and year.
                var dateElementsArraySubString = validatedScannedText.split {[".","/"," "].contains($0)}
                //remove prefixes
                dateElementsArraySubString.removeAll(where: { i in
                    if Int(i) == nil {
                        switch i.uppercased() {
                        case "EXP", "BB","EXPY", "BEST BEFORE" :
                            return true
                        default:
                            return true
                        }
                    }
                    else {
                        return false
                    }
                })
                
                print(dateElementsArraySubString)
                
                //convert [SubString] to [String]
                let dateElementsArrayString: [String] = dateElementsArraySubString.map { i -> String in
                    return String(i)
                }
                print("array item index: \(counter)")
                
                //get the re-arranged array of [Int] having date, month and year digits.
                let ddmmyy = arrangeDateArray(dateArr: dateElementsArrayString, counter: counter)
                
                //extract years, months and days from array.
                let yy: Int = ddmmyy[2]
                let mm: Int = ddmmyy[1]
                let dd: Int = ddmmyy[0]
                
                //convert the date into swift Date type
                formattedDate = getMyDate(year: yy, month: mm, day: dd)
                //set the flag to false as date scanned is valid.
                isDateNotFound = 1
                print("formatted date:\(formattedDate)")
                //jump out of the loop
                break
            }
            else {
                isDateNotFound = 2
            }
            //otherwise continue scanning the loop
            counter += 1
        }
        //return the date and scan valid/invalid result.
         return (formattedDate, isDateNotFound)
    }

    // method that takes date string array and re-arrange it to [dd,mm,yy] order and in [Int] format.
    func arrangeDateArray(dateArr:[String], counter: Int) -> [Int] {
        //variable with [Int] type
        var ddmmyy:[Int] = [00,00,00]
        
        //assign let to a new var type
        var dateArr = dateArr
        
        //based on the regex type modify, convert and rearrange [Stribg] type date array to [Int] type date array.
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
        case 36...38:
            ddmmyy[0] = Int(dateArr[1])!
            ddmmyy[1] = Int(dateArr[0])!
            ddmmyy[2] = Int(dateArr[2])!
            return ddmmyy
        default:
            return ddmmyy
        }
    }
    
    //method that will match the scanned Text with a regex and returns matched string.
    func findSubString(regex: NSRegularExpression, subString: String) -> String {
        //return an array of all matches
        let matches = regex.matches(in: subString, options: [], range: NSRange(location: 0, length: subString.utf16.count))
        
        //return the first matched text from the matched texts
        if let match = matches.first {
            //range of the matched text
            let range = match.range(at: 0)
            // create a range instance of Range type for subString
            if let swiftRange = Range(range, in: subString) {
                //return the range of characters from subString
                let result = subString[swiftRange]
                return String(result)
            }
        }
        //if no match found return empty text
        return ""
    }

    //using the day, month and year variables form the Date type and return it.
    func getMyDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
    //replace the month text/abbreviations with 2 digits month equvivalent
    func digitizeMonthAbbreviation(dateString: String) -> String {
        //array of month abbriviations
        let monthAbbreviations = ["JANUARY","JAN","JA","FEBRUARY","FEB","FE","MARCH","MAR","MR", "APRIL","APR","AP","AL","MAY","MY","MA","JUNE","JUN","JU","JN","JULY","JUL","JL","AUGUST","AUG","AU","SEPTEMBER","SEPT","SEP","SE","OCTOBER","OCT","OC","0CTOBER","0CT","0C","NOVEMBER","NOV","NO", "NV","N0VEMBER","N0V","N0","DECEMBER","DEC","DE"]
        //var to be returned after formatting
        var digitizedDateString = ""
        //iterate through all the month abbreviations
forloop: for monthAbbreviation in monthAbbreviations {
            //replace the matched abbreviation with respective 2 digit month equivalent.
            switch monthAbbreviation {
            case "JA","JAN","JANUARY":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "01")
                break
            case "FE","FEB","FEBRUARY":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "02")
                break
            case "MR","MAR","MARCH":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "03")
                break
            case "AP","AL","APR","APRIL":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "04")
                break
            case "MY","MA","MAY":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "05")
                break
            case "JN","JU","JUN","JUNE":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "06")
                break
            case "JL","JUL","JULY":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "07")
                break
            case "AU","AUG","AUGUST":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "08")
                break
            case "SE","SEP","SEPT","SEPTEMBER":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "09")
                break
            case "OC","OCT","OCTOBER","0C","0CT","0CTOBER":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "10")
                break
            case "NO", "NV","NOV","NOVEMBER","N0","N0V","N0VEMBER":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "11")
                break
            case "DE","DEC","DECEMBER":
                digitizedDateString = dateString.replacingOccurrences(of: monthAbbreviation, with: "12")
                break
            default:
                digitizedDateString = dateString
            }
            if digitizedDateString != dateString {
                break forloop
            }
        }
        print("Digitized date string: ",digitizedDateString)
        //return the digitized date string
        return digitizedDateString
    }

    //method that will add puntuations to date string
    func formatDateString(counter: Int, dateString:String) -> String {
        var dateString = dateString
        //match the date String with the regex counter and based on matched result add puncuations to a given index of the string and return it.
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
        case 6...15,20,22,27...31,36...38:
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
