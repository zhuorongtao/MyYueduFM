//: Playground - noun: a place where people can play

import UIKit
import ObjectiveC.runtime

var str = "Hello, playground"
print(str)

var array = [1, 2, 3, 9, 6]

let a = (array as NSArray).sortedArrayUsingFunction({ (obj1, obj2, _) -> Int in
    let tem1 = obj1 as! Int
    let tem2 = obj2 as! Int
    
    if tem1 > tem2 {
        return NSComparisonResult.OrderedAscending.rawValue
    }else if tem1 < tem2 {
        return NSComparisonResult.OrderedDescending.rawValue
    }
    return NSComparisonResult.OrderedSame.rawValue
    }, context: nil)

array.sortInPlace{
    return $0 < $1
}

String(format: "%d:%02d", arguments: [6, 20])

var cStr = "54h634"
let rStr = cStr.substringWithRange(cStr.startIndex..<cStr.startIndex.advancedBy(2))

func colorWithHexString(hex: String) -> UIColor {
    
    struct temp {
        static var r: UInt32 = 0
        static var g: UInt32 = 0
        static var b: UInt32 = 0
    }
    
    //去掉前后空格换行符
    var cStr = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    if cStr.characters.count < 6 {
        return UIColor.whiteColor()
    }
    
    if cStr.hasPrefix("0X") {
        if let range = cStr.rangeOfString("0X") {
            cStr = cStr.substringFromIndex(range.endIndex)
        }
    }else if cStr.hasPrefix("#") {
        if let range = cStr.rangeOfString("#") {
            cStr = cStr.substringFromIndex(range.startIndex.advancedBy(1))
        }
    }
    
    if cStr.characters.count != 6 {
        return UIColor.whiteColor()
    }
    
    // Separate into r, g, b substrings
    let cStrStartIndex = cStr.startIndex
    let rStr = cStr.substringWithRange(cStrStartIndex..<cStrStartIndex.advancedBy(2))
    let gStr = cStr.substringWithRange(cStrStartIndex.advancedBy(2)..<cStrStartIndex.advancedBy(4))
    let bStr = cStr.substringWithRange(cStrStartIndex.advancedBy(4)..<cStrStartIndex.advancedBy(6))
    
//    var r: CUnsignedInt = 0
//    var g: CUnsignedInt = 0
//    var b: CUnsignedInt = 0
    
    NSScanner(string: rStr).scanHexInt(&temp.r)
    NSScanner(string: gStr).scanHexInt(&temp.g)
    NSScanner(string: bStr).scanHexInt(&temp.b)
    
    return UIColor(red: CGFloat(Float(temp.r) / 255.0), green: CGFloat(Float(temp.g) / 255.0), blue: CGFloat(Float(temp.b) / 255.0), alpha: 1)
}

colorWithHexString("#00bdee")

func stringWithSeconds(seconds: Int32) -> String {
    var tempSeconds = seconds
    
    if tempSeconds < 0 {
        tempSeconds = 0
    }
    
    let s = tempSeconds % 60 //秒数
    let min = tempSeconds / 60
    let m = min % 60
    let h = min / 60 //小时
    
    var str: String = ""
    if h > 0 {
        str = String(format: "%d:%02d:%02d", arguments: [h, m, s])
    }else {
        str = String(format: "%d:%02d", arguments: [m, s])
    }
    
    return str
    
}

stringWithSeconds(360)

var aa: [[String: Any]] = []

aa.append([
        "11": "ww",
        "22": 22,
        "33": { () -> String in
            let a = "33"
            return a
        }
    ])

let b = aa[0]["33"] as? () -> String
b!()

func adapterImageName(name: String) -> String {
    let preName = (name as NSString).stringByDeletingPathExtension
    let size = UIScreen.mainScreen().bounds.size
    if size.width >= 414 {
        return "\(preName)~5.5@2x"
    }else if size.width >= 375 {
        return "\(preName)~4.7@2x"
    }else if size.width > 480 {
        return "\(preName)~4@2x"
    }else {
        return "\(preName)~3.5@2x"
    }
    
}

NSBundle.mainBundle().pathForResource(adapterImageName("guide1.png"), ofType: "png")

func stringWithFileSize(size: Double) -> String {
    var i = 0
    var tempLength = 0.0
    let formatString = ["%.0lfB", "%.1lfKB", "%.1lfMB", ".2lfGB", "%.2lfTB"]
    tempLength = size
    while tempLength >= 1024 && i < 4 {
        tempLength /= 1024.0
        i += 1
    }
    return String(format: formatString[i], tempLength)
}
stringWithFileSize(3160)

class test {
    var name: String!
    var age: String!
    var pu: Int!
    
}

struct temp {
    static var count: UInt32 = 0
    
}

//extension NSObject {
func getTypeOfProperty(name:String, clazz: AnyObject)->String?
{
    let type: Mirror = Mirror(reflecting:clazz)
    
    for child in type.children {
        if child.label! == name
        {
            return String(child.value.dynamicType)
        }
    }
    return nil
}
//}

func variableMap() {
    let ivars = class_copyIvarList(test.self, &temp.count)
    if ivars != nil {

        for i in 0..<Int(temp.count) {
            let thisIvar: Ivar = ivars[i]
            var key = String(UTF8String: ivar_getName(thisIvar))
            let type = ivar_getTypeEncoding(thisIvar)
            let str1 = NSString(UTF8String: type)
            
            let str = String(CString: type, encoding: NSUTF8StringEncoding)
            
            print("\(key!)")
            print("\(str1!)")
            if key!.hasPrefix("_") {
                let range = key?.rangeOfString("_")
                
                key = key?.substringFromIndex(range!.startIndex)
            }
        }
        free(ivars)
    }
}
variableMap()

class MyObject: test {
    var a: Int?
    var t: String!
    
}

var ivarCount : UInt32 = 0
var ivars : UnsafeMutablePointer<Ivar> = class_copyIvarList(class_getSuperclass(MyObject.self), &ivarCount)

for i in 0..<ivarCount {
    print("Ivar: " + String.fromCString(ivar_getName(ivars[Int(i)]))!)
    print(" " + String.fromCString(ivar_getTypeEncoding(ivars[Int(i)]))!)
}


class c1: NSObject {
        let a = 99.0
        let b = 99
    }

class c2 {
    }

struct s1 {
    }

class t: NSObject {
    let d: Double = 99.0
        let f: Float = 99.0
        let q: Int = 99
        let i: CInt = 99
        let c: Int8 = 99
        let b = true
        let s = ""
        let array = [String]()
        let dict = ["":1]
        let set = Set<String>()
        let w: () -> () = {}
        let x = c1()
        let y = c2()
        let z = s1()
    }

var ic: UInt32 = 0
let ivar = class_copyIvarList( t.self, &ic )
for i in 0..<ic {
    print("\(String.fromCString(ivar_getName(ivar[Int(i)]))!)\n \(String.fromCString(ivar_getTypeEncoding(ivar[Int(i)]))!)")
}

print("11111")

usleep(200 * 1000)

print("22222")
