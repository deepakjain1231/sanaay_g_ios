//
//  PregnancyModel.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 22/05/24.
//

import Foundation

class PregnancyModel {
    
    func getPragnancyTrimester_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: PragnanacyTrismesterDataModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: PragnanacyTrismesterDataModel.self) { result in
            DispatchQueue.main.async {
                completion(Status.loading, nil, nil)
            }
            switch(result) {
            case .success(let s):
                DispatchQueue.main.async {
                    completion(Status.success, s, nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(Status.error, nil, error)
                }
            }
        }
    }
}


    //MARK: - APPOINTMENT SLOTS
struct PragnanacyTrismesterDataModel: Codable {
    let status: String?
    let message: String?
    let data: [TrismesterListDataResponse?]?
}

struct TrismesterListDataResponse: Codable {
    var id: String?
    var title: String?
    var sub_title: String?
}
       
