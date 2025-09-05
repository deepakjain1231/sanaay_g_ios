import Foundation
import Alamofire

public enum RequestMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
    case multiPartForm = "MULTI_PART_FORM"
}


class ServiceCustom: NSObject  {
    
    class var shared : ServiceCustom {
        struct Static {
            static let instance : ServiceCustom = ServiceCustom()
        }
        return Static.instance
    }
    
    fileprivate var alamofireManager: SessionManager?
    fileprivate let cookies = HTTPCookieStorage.shared
    fileprivate var AuthorizationToken = ""
    fileprivate var arrRequest = [DataRequest]()
    fileprivate var isTokenUploaded = false
    
    //MARK: - API CALL
    func requestURL(_ URLString: URLConvertible, Method:RequestMethod, parameters: [String: Any]?,completion: @escaping (([String:Any]?, Bool, Error?, Int) -> Void)){
        
        let headers: HTTPHeaders = getHeaders()
        debugPrint("URL ===> \(URLString)")
        debugPrint("parameters ===> ",parameters as NSDictionary? ?? "No Parameter")
        debugPrint("auth ===>", headers)
        let reqMethod = HTTPMethod(rawValue: Method.rawValue) ?? HTTPMethod.get
        let request = Alamofire.request(URLString, method: reqMethod, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                self.forcefullyLogout(response: response.response)
                let status_code = HTTPURLResponse()
                var resutdict:[String:Any]? = nil
                if response.result.isSuccess {
                    if let values = response.result.value {
                        let json = JSON(values)
                        resutdict = json.dictionaryObject
                    }
                }
                
                DispatchQueue.main.async {
                    completion(resutdict,response.result.isSuccess, response.error, status_code.statusCode)
                }
            }
            .responseString { (responseString) in
                //debugPrint("responseString:-",responseString)
            }
        self.arrRequest.append(request)
    }
    
    func requestURLXML(_ URLString: URLConvertible, Method:RequestMethod, parameters: [String: Any]?,completion: @escaping ((Data?, Error?) -> Void))
    {
        let headers:HTTPHeaders = getHeaders()
        debugPrint("URL ===> \(URLString)")
        debugPrint("parameters ===> ",parameters as NSDictionary? ?? "No Parameter")
        let reqMethod = HTTPMethod(rawValue: Method.rawValue) ?? HTTPMethod.get
        let request = Alamofire.request(URLString, method: reqMethod, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
        request.response { (responseU) in
            if let error = responseU.error{
                debugPrint("requestURLXML error:-->",error)
            }
            completion(responseU.data,responseU.error)
        }
        self.arrRequest.append(request)
    }
    
    func requestDownloadfile(_ URLString: URLConvertible, progressC: @escaping ((Double) -> Void), completion: @escaping ((DefaultDownloadResponse?) -> Void)) {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(
            URLString,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                print("Progress: \(progress.fractionCompleted)")
                progressC(progress.fractionCompleted)
            }).response(completionHandler: { (DefaultDownloadResponse) in
                debugPrint("destination URL:-",DefaultDownloadResponse.destinationURL!)
                completion(DefaultDownloadResponse)
            })
    }
    
    //MARK:- Multi part request with parameters.
    func requestMultiPartWithUrlAndParameters(_ URLString: URLConvertible, Method:String, parameters: [String: Any], fileParameterName: String, fileName:String, fileData : Data?, mimeType : String,completion: @escaping (([String:Any]?, Bool, Error?, Data?) -> Void), failure:@escaping ((Error) -> Void)) {

        let headers: HTTPHeaders = ["Content-type": "multipart/form-data",
                                    "Authorization": Utils.getAuthToken()]

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imgData = fileData {
                multipartFormData.append(imgData, withName: fileParameterName, fileName: fileName, mimeType: mimeType)
            }

            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        }, usingThreshold: UInt64.init(), to: URLString, method: .post, headers: headers) { (responseeee) in
            switch responseeee {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error {
                        DismissProgressHud()
                        debugPrint(err.localizedDescription)
                        return
                    }
                    
                    let status_code = HTTPURLResponse()
                    var resutdict:[String:Any]? = nil
                    if response.result.isSuccess {
                        if let values = response.result.value {
                            let json = JSON(values)
                            resutdict = json.dictionaryObject
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completion(resutdict,response.result.isSuccess, response.error, response.data)
                    }
                    
                }
            case .failure(let error):
                DismissProgressHud()
                print("Error in upload: \(error.localizedDescription)")
                debugPrint(error.localizedDescription)
                failure(error)
            }
        }
    }
    
    
    func cancelrequest(url:String) {
        self.arrRequest.removeAll { (dataRequest) -> Bool in
            if let compareUrl = dataRequest.request?.url?.absoluteString, compareUrl == url{
                dataRequest.cancel()
                return true
            }
            return false
        }
    }
    
    func getHeaders() -> (HTTPHeaders) {
        //        return ["company_id": "21",
        //                "secure_id": UIDevice.current.identifierForVendor!.uuidString,
        //                "Accept": "application/json"]
        return ["Accept": "application/json",
                "Authorization": Utils.getAuthToken()]
    }
    
    func setAuthorizationToken(Token: String) {
        if Token == ""{
            self.isTokenUploaded = false
        }
        AuthorizationToken = Token
    }
    
    func getHTTPMethod(strMethod:String) -> HTTPMethod {
        switch strMethod {
        case "OPTIONS":
            return HTTPMethod.options
        case "GET":
            return HTTPMethod.get
        case "HEAD":
            return HTTPMethod.head
        case "POST":
            return HTTPMethod.post
        case "PUT":
            return HTTPMethod.put
        case "PATCH":
            return HTTPMethod.patch
        case "DELETE":
            return HTTPMethod.delete
        case "TRACE":
            return HTTPMethod.trace
        case "CONNECT":
            return HTTPMethod.connect
        default:
            return HTTPMethod.post
        }
    }
    
    //MARK:- USER HELPER
    
    func forcefullyLogout(response:HTTPURLResponse?) {
        //Logout user forcefully while getting unauthentication from server
        DispatchQueue.main.async {
            if response?.statusCode == 401{
                //Clear local data
                
                //Redirect to the login page
                
                //msg
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.32, execute: {
                    
                })
            }
        }
    }
    
    func updateDevicetoken() ->Void{
        if isTokenUploaded{debugPrint("Token Already uploaded")}
        DispatchQueue.main.async {
            //Cancel previous request if made
            //            ServiceCustom.shared.cancelrequest(url: URL_getInstructorLogtime)
            //            ServiceCustom.shared.requestURL(URL_updateDeviceToken, Method: .post, parameters: ["device_token":currentSession.deviceToken]) { (result, isSuccess, error) in
            //                if let err = error {
            //                    debugPrint("[ServiceCustom] updateDevicetoken:error:-", err)
            //                }else if let strMessage = result?[AppMessage.error] as? String {
            //                    debugPrint("[ServiceCustom] updateDevicetoken:error msg:-", strMessage )
            //                }else{
            //                    self.isTokenUploaded = true
            //                    debugPrint("[ServiceCustom] updateDevicetoken:-", result!)
            //                }
            //            }
        }
    }
}

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

