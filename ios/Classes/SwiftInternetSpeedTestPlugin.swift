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
        let fileSize = argsMap["fileSize"] as! Int
        switch args {
        case 0:
            startListening(args: args, flutterResult: result, methodName: "startDownloadTesting", testServer: argsMap["testServer"] as! String)
            break
        case 1:
            startListening(args: args, flutterResult: result, methodName: "startUploadTesting", testServer: argsMap["testServer"] as! String)
            break
        default:
            break
        }
    }
    
    func startListening(args: Any, flutterResult: FlutterResult, methodName:String, testServer: String) {
        print("Method name is \(methodName)")
        let currentListenerId = args as! Int
        print("id is \(currentListenerId)")

        var fun = {
            if (self.callbackById.contains(where: { (key, _) -> Bool in
                print("does contain key \(key == currentListenerId)")
                return key == currentListenerId
            })) {
                print("inside if")
                switch methodName {
                case "startDownloadTesting" :
//                    self.speedTest.findBestHost(from: 400, timeout: 10000) { (hostResult : Result<(URL, Int), SpeedTestError>) in
//                        switch hostResult {
//                        case .value(let fromUrl, let timeout):
//                            print("timeout is \(timeout)")
                    self.speedTest.runDownloadTest(for: URL(string: testServer)!, size: 1024000, timeout: 20000, current: { (currentSpeed) in
                                var rate = currentSpeed.value
                                if currentSpeed.units == .Kbps {
                                    rate = rate * 1000
                                } else if currentSpeed.units == .Mbps {
                                    rate = rate * 1000 * 1000
                                } else  {
                                    rate = rate * 1000 * 1000 * 1000
                                }
                                var argsMap: [String: Any] = [:]
                                argsMap["id"] = currentListenerId
                                argsMap["transferRate"] = rate
                                argsMap["percent"] = 50
                                argsMap["type"] = 2
                                DispatchQueue.main.async {
                                    SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                }
                            }, final: { (resultSpeed) in
                                switch resultSpeed {
                                    
                                case .value(let finalSpeed):
                                    var rate = finalSpeed.value
                                    if finalSpeed.units == .Kbps {
                                        rate = rate * 1000
                                    } else if finalSpeed.units == .Mbps {
                                        rate = rate * 1000 * 1000
                                    } else  {
                                        rate = rate * 1000 * 1000 * 1000
                                    }
                                    var argsMap: [String: Any] = [:]
                                    argsMap["id"] = currentListenerId
                                    argsMap["transferRate"] = rate
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
                    self.speedTest.runUploadTest(for: URL(string: testServer)!, size: 200, timeout: 20000, current: { (currentSpeed) in
                                                   DispatchQueue.main.async {
                                                       var argsMap: [String: Any] = [:]
                                                       argsMap["id"] = currentListenerId
                                                       argsMap["transferRate"] = currentSpeed.value
                                                       argsMap["percent"] = 50
                                                       argsMap["type"] = 2
                                                       
                                                       SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                                   }
                                               }, final: { (resultSpeed) in
                                                   switch resultSpeed {
                                                       
                                                   case .value(let finalSpeed):
                                                       DispatchQueue.main.async {
                                                           var argsMap: [String: Any] = [:]
                                                           argsMap["id"] = currentListenerId
                                                           argsMap["transferRate"] = finalSpeed.value
                                                           argsMap["percent"] = 50
                                                           argsMap["type"] = 0
                                                           
                                                           SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                                       }
                                                   case .error(let error):
                                                       print("Error is \(error.localizedDescription)")
                                                       
                                                       var argsMap: [String: Any] = [:]
                                                       argsMap["id"] = currentListenerId
                                                       argsMap["speedTestError"] = error.localizedDescription
                                                       argsMap["type"] = 1
                                                       
                                                       SwiftInternetSpeedTestPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                                       
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
