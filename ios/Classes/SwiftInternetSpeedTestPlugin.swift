import Flutter
import UIKit



public class SwiftInternetSpeedTestPlugin: NSObject, FlutterPlugin {
    
    var callbackById: [Int: () -> ()] = [:]
    
    let speedTest = SpeedTest()
    static var channel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
         channel = FlutterMethodChannel(name: "internet_speed_test", binaryMessenger: registrar.messenger())
        
        let instance = SwiftInternetSpeedTestPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func mapToCall(result: FlutterResult, arguments: Any?) {
        let argsMap = arguments as! [String: Any]
        let args = argsMap["id"] as! Int
        var fileSize = 200
        if let fileSizeArgument = argsMap["fileSize"] as? Int {
            fileSize = fileSizeArgument
        }
        print("file is of size \(fileSize) Bytes")
        switch args {
        case 0:
            startListening(args: args, flutterResult: result, methodName: "startDownloadTesting", testServer: argsMap["testServer"] as! String, fileSize: fileSize)
            break
        case 1:
            startListening(args: args, flutterResult: result, methodName: "startUploadTesting", testServer: argsMap["testServer"] as! String, fileSize: fileSize)
            break
        default:
            break
        }
    }
    
    func startListening(args: Any, flutterResult: FlutterResult, methodName:String, testServer: String, fileSize: Int) {
        print("Method name is \(methodName)")
        let currentListenerId = args as! Int
        print("id is \(currentListenerId)")

        let fun = {
            if (self.callbackById.contains(where: { (key, _) -> Bool in
                print("does contain key \(key == currentListenerId)")
                return key == currentListenerId
            })) {
                print("inside if")
                switch methodName {
                case "startDownloadTesting" :
                    self.speedTest.runDownloadTest(for: URL(string: testServer)!, size: fileSize, timeout: 20000, current: { (currentSpeed) in
                                var argsMap: [String: Any] = [:]
                                argsMap["id"] = currentListenerId
                                argsMap["transferRate"] = self.getSpeedInBytes(speed: currentSpeed)
                                argsMap["percent"] = 50
                                argsMap["type"] = 2
                                DispatchQueue.main.async {
                                    SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                }
                            }, final: { (resultSpeed) in
                                switch resultSpeed {
                                case .value(let finalSpeed):
                                    var argsMap: [String: Any] = [:]
                                    argsMap["id"] = currentListenerId
                                    argsMap["transferRate"] = self.getSpeedInBytes(speed: finalSpeed)
                                    argsMap["percent"] = 100
                                    argsMap["type"] = 0
                                    DispatchQueue.main.async {
                                        SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                    }
                                case .error(let error):
                                    print("Error is \(error.localizedDescription)")
                                    var argsMap: [String: Any] = [:]
                                    argsMap["id"] = currentListenerId
                                    argsMap["speedTestError"] = error.localizedDescription
                                    argsMap["type"] = 1
                                    DispatchQueue.main.async {
                                        SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                    }
                                }
                            })
                            break
//                        case .error(let error):
//                            print("Error get url  is \(error.localizedDescription)")
//                            var argsMap: [String: Any] = [:]
//                            argsMap["id"] = currentListenerId
//                            argsMap["speedTestError"] = error.localizedDescription
//                            argsMap["type"] = 1
//
//                            SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
//                        }
//                    }
                    
//                    break
                case "startUploadTesting":
                    self.speedTest.runUploadTest(for: URL(string: testServer)!, size: fileSize, timeout: 20000, current: { (currentSpeed) in
                                                    var argsMap: [String: Any] = [:]
                                                    argsMap["id"] = currentListenerId
                                                    argsMap["transferRate"] = self.getSpeedInBytes(speed: currentSpeed)
                                                    argsMap["percent"] = 50
                                                    argsMap["type"] = 2
                                                   DispatchQueue.main.async {
                                                       SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                                   }
                                               }, final: { (resultSpeed) in
                                                   switch resultSpeed {
                                                       
                                                   case .value(let finalSpeed):
                                                        
                                                        var argsMap: [String: Any] = [:]
                                                        argsMap["id"] = currentListenerId
                                                        argsMap["transferRate"] = self.getSpeedInBytes(speed: finalSpeed)
                                                        argsMap["percent"] = 50
                                                        argsMap["type"] = 0
                                                        
                                                       DispatchQueue.main.async {
                                                           SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                                       }
                                                   case .error(let error):
                                                    
                                                       print("Error is \(error.localizedDescription)")
                                                       
                                                       var argsMap: [String: Any] = [:]
                                                       argsMap["id"] = currentListenerId
                                                       argsMap["speedTestError"] = error.localizedDescription
                                                       argsMap["type"] = 1
                                                       DispatchQueue.main.async {
                                                        SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                                       }
                                                   }
                                               })
                    break
                default:
                    break
                }
            }
        }
        callbackById[currentListenerId] = fun
        fun()
    }
    
    func getSpeedInBytes(speed: Speed) -> Double {
        var rate = speed.value
        if speed.units == .Kbps {
            rate = rate * 1000
        } else if speed.units == .Mbps {
            rate = rate * 1000 * 1000
        } else  {
            rate = rate * 1000 * 1000 * 1000
        }
        return rate
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            if (call.method == "getPlatformVersion") {
                result("iOS " + UIDevice.current.systemVersion)
            } else if (call.method == "startListening") {
                mapToCall(result: result, arguments: call.arguments)
            } else if (call.method == "cancelListening") {
//                cancelListening(arguments: call.arguments, result: result)
            }
    }
    
    
    
//
//
//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//
//        if (call.method == "getPlatformVersion") {
//            result("iOS " + UIDevice.current.systemVersion)
//        } else if (call.method == "startListening") {
//            mapToCall(result: result, arguments: call.arguments)
//        } else if (call.method == "cancelListening") {
//            cancelListening(arguments: call.arguments, result: result)
//        }
//        else if (call.method == "getAllImages") {
//
//            DispatchQueue.main.async {
//
//                let imgManager = PHImageManager.default()
//                let requestOptions = PHImageRequestOptions()
//                requestOptions.isSynchronous = true
//                let fetchOptions = PHFetchOptions()
//                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
//
//                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
//                var allImages = [String]()
//
//                var totalIteration = 0
//                print("fetchResult.count : \(fetchResult.count)")
//
//                var savedLocalIdentifiers = [String]()
//
//                for index in 0..<fetchResult.count
//                {
//                    let asset = fetchResult.object(at: index) as PHAsset
//                    let localIdentifier = asset.localIdentifier
//                    savedLocalIdentifiers.append(localIdentifier)
//
//                    imgManager.requestImage(for: asset, targetSize: CGSize(width: 512.0, height: 512.0), contentMode: PHImageContentMode.aspectFit, options: PHImageRequestOptions(), resultHandler:{(image, info) in
//
//                        if image != nil {
//                            var imageData: Data?
//                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
//                                imageData = image!.jpegData(compressionQuality: 0.8)
//                            }
//                            else {
//                                imageData = image!.pngData()
//                            }
//                            let guid = ProcessInfo.processInfo.globallyUniqueString;
//                            let tmpFile = String(format: "image_picker_%@.jpg", guid);
//                            let tmpDirectory = NSTemporaryDirectory();
//                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
//                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
//                                allImages.append(tmpPath)
//                            }
//                        }
//                        totalIteration += 1
//                        if totalIteration == (fetchResult.count) {
//                            result(allImages)
//                        }
//                    })
//                }
//            }
//        } else if (call.method == "getAlbums") {
//            DispatchQueue.main.async {
//                var album:[PhoneAlbum] = [PhoneAlbum]()
//
//                let phResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
//                print("albums counts \(phResult.count)")
//
//                phResult.enumerateObjects({ (collection, _, _) in
//
//                    print("hasAssets \(collection.hasAssets())")
//                    print("photos count \(collection.photosCount)")
//
//                    if (collection.hasAssets()) {
//                        let image = collection.getCoverImgWithSize(CGRect())
//                        if image != nil {
//                            var imageData: Data?
//                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
//                                imageData = image!.jpegData(compressionQuality: 0.8)
//                            }
//                            else {
//                                imageData = image!.pngData()
//                            }
//                            let guid = ProcessInfo.processInfo.globallyUniqueString;
//                            let tmpFile = String(format: "image_picker_%@.jpg", guid);
//                            let tmpDirectory = NSTemporaryDirectory();
//                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
//                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
//                                album.append(PhoneAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "", coverUri: tmpPath, photosCount: collection.photosCount))
//                            }
//                        }
//                    }
//                })
//                album.forEach { (phoneAlbum) in
//                    var string = "[ "
//                    album.forEach { (phoneAlbum) in
//                        string += phoneAlbum.toJson()
//                        if (album.firstIndex(where: {$0 === phoneAlbum}) != album.count - 1) {
//                            string += ", "
//                        }
//                    }
//                    string += "]"
//                    result(string)
//                }
//            }
//        } else if (call.method == "getPhotosOfAlbum") {
//            DispatchQueue.main.async {
//                var album:[PhonePhoto] = [PhonePhoto]()
//
//                let phResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
//                print("albums counts \(phResult.count)")
//
//
//
//                DispatchQueue.main.async {
//                    let fetchOptions = PHFetchOptions()
//                    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//                    if let collection = collection {
//                        self.photos = PHAsset.fetchAssets(in: collection, options: fetchOptions)
//                    } else {
//                        self.photos = PHAsset.fetchAssets(with: fetchOptions)
//                    }
//                    self.collectionView.reloadData()
//                }
//
//
//                phResult.enumerateObjects({ (collection, _, _) in
//
//                    if (collection.hasAssets()) {
//                        let image = collection.getCoverImgWithSize(CGRect())
//                        if image != nil {
//                            var imageData: Data?
//                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
//                                imageData = image!.jpegData(compressionQuality: 0.8)
//                            }
//                            else {
//                                imageData = image!.pngData()
//                            }
//                            let guid = ProcessInfo.processInfo.globallyUniqueString;
//                            let tmpFile = String(format: "image_picker_%@.jpg", guid);
//                            let tmpDirectory = NSTemporaryDirectory();
//                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
//                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
//                                album.append(PhoneAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "", coverUri: tmpPath, photosCount: collection.photosCount))
//                            }
//                        }
//                    }
//                })
//                album.forEach { (phoneAlbum) in
//                    var string = "[ "
//                    album.forEach { (phoneAlbum) in
//                        string += phoneAlbum.toJson()
//                        if (album.firstIndex(where: {$0 === phoneAlbum}) != album.count - 1) {
//                            string += ", "
//                        }
//                    }
//                    string += "]"
//                    result(string)
//                }
//            }
//        }
//    }
//
//    private func fetchImagesFromGallery(collection: PHAssetCollection?) {
//        //        DispatchQueue.main.async {
//        //            let fetchOptions = PHFetchOptions()
//        //            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//        //            if let collection = collection {
//        //                self.photos = PHAsset.fetchAssets(in: collection, options: fetchOptions)
//        //            } else {
//        //                self.photos = PHAsset.fetchAssets(with: fetchOptions)
//        //            }
//        //            self.collectionView.reloadData()
//        //        }
//    }
//
    
    
}
