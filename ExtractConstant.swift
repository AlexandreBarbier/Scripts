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
    var str = "enum \(enumName) : String {\n"
    for (key, _) in value {
        str += "\tcase \(key)\n"
    }
    str += "}\n"
    return str
}

func CreateConstantFile() {
    let storyEnum = createStoryboardEnum()
    var str = createEnum("StoryboardID", value:storyEnum)
    let segueEnum = createSegueEnum()
    let segues = createEnum("SegueID", value:segueEnum)
    str += "\n\n\(segues)"
    let vcEnum = createViewControllerEnum()
    let vcs = createEnum("ViewControllerID", value:vcEnum)
    str += "\n\n\(vcs)"

    do {
        try     str.writeToFile("\(Process.arguments[1])/\(Process.arguments[2])", atomically: true, encoding: NSUTF8StringEncoding)
    }catch {

    }

}


CreateConstantFile()
