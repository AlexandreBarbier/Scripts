//
//  ExtractConstant.swift
//  BugTracker
//
//  Created by Alexandre on 10/16/15.
//  Copyright © 2015 ABarbier. All rights reserved.
//
import Foundation

func createStoryboardEnum() -> Dictionary<String, String> {
    let filemanager = NSFileManager()
    let enumerator = filemanager.enumeratorAtPath(Process.arguments[1])
    var resultDictionary = Dictionary<String, String>()
    while let element = enumerator?.nextObject()  {
        if let url = NSURL(string:"\(Process.arguments[1])/\(element)") {
            if url.pathExtension! == "storyboard" {
                let k = url.URLByDeletingPathExtension
                let t = k!.lastPathComponent
                resultDictionary.updateValue(t!, forKey: t!)

            }

        }
    }

    return resultDictionary
}

func createViewControllerEnum() -> Dictionary<String, String> {
    let filemanager = NSFileManager()
    let enumerator = filemanager.enumeratorAtPath(Process.arguments[1])
    var resultDictionary = Dictionary<String, String>()
    while let element = enumerator?.nextObject()  {

        if let url = NSURL(string:"\(Process.arguments[1])/\(element)") {
            if url.pathExtension! == "storyboard" {
                do {
                    let str = try String(contentsOfFile:"\(Process.arguments[1])/\(element)")
                    let regex = try NSRegularExpression(pattern:"storyboardIdentifier=\"([:ALPHA:]*)\"?", options: .CaseInsensitive)
                    let matches = regex.matchesInString(str, options: .ReportProgress, range: NSMakeRange(0,             str.characters.count))

                    for t in matches {
                        let res = (str as NSString).substringWithRange(t.rangeAtIndex(1))
                        resultDictionary.updateValue(res, forKey: res)

                    }
                }
                catch   let error as NSError {
                    print(error)
                }
            }

        }
    }
    return resultDictionary
}

func createSegueEnum() -> Dictionary<String, String> {
    let filemanager = NSFileManager()
    let enumerator = filemanager.enumeratorAtPath(Process.arguments[1])
    var resultDictionary = Dictionary<String, String>()
    while let element = enumerator?.nextObject()  {

        if let url = NSURL(string:"\(Process.arguments[1])/\(element)") {
            if url.pathExtension! == "storyboard" {
                do {
                    let str = try String(contentsOfFile:"\(Process.arguments[1])/\(element)")
                    //<segue destination="PgQ-pD-g1Q" kind="show" identifier="LoginSegue" id="jul-lO-gTy"/>
                    let regex = try NSRegularExpression(pattern:"segue .* identifier=\"([:ALPHA:]*)\"", options: .CaseInsensitive)
                    let matches = regex.matchesInString(str, options: .ReportProgress, range: NSMakeRange(0,             str.characters.count))

                    for t in matches {
                        let res = (str as NSString).substringWithRange(t.rangeAtIndex(1))
                        resultDictionary.updateValue(res, forKey: res)
                    }
                }
                catch   let error as NSError {
                    print(error)
                }
            }

        }
    }

    return resultDictionary
}

func createEnum(enumName:String, value:Dictionary<String, String>)->String {
    var enumGlobal = "/**\n\(enumName) identifiers\n"
    var enumBody = "struct \(enumName)ID {\n"
    for (key, _) in value {
        enumGlobal += "\n- \(key):\t\(key)"
        enumBody += "\t let static k\(key) = \"\(key)\"\n"
    }
    enumGlobal += "\n*/\n"
    enumGlobal += enumBody
    enumGlobal += "}\n"
    return enumGlobal
}

func CreateConstantFile() {
    let storyEnum = createStoryboardEnum()
    var str = ""
    if storyEnum.count > 0 {
        print("storyboard created")
        str = createEnum("Storyboard", value:storyEnum)
    }
    else {
        print("no storyboard found in \(Process.arguments[1])")
        return
    }
    let segueEnum = createSegueEnum()
    if segueEnum.count > 0 {
        print("segue created")
        let segues = createEnum("Segue", value:segueEnum)
        str += "\n\n\(segues)"
    }
    let vcEnum = createViewControllerEnum()
    if vcEnum.count > 0 {
        print("view controllers created")
        let vcs = createEnum("ViewController", value:vcEnum)
        str += "\n\n\(vcs)"
    }


    do {
        try  str.writeToFile("\(Process.arguments[1])/\(Process.arguments[2])", atomically: true, encoding: NSUTF8StringEncoding)
    }catch {
        print ("\(error)")
    }
    return
}


CreateConstantFile()
