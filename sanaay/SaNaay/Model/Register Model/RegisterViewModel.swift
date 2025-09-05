//
//  RouteDetailViewModel.swift
//  Tummoc
//
//  Created by Kiran Nayak on 24/03/23.
//

import Foundation

class RegisterViewModel {
    
    func preRegisterDoctor(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: PreRegisterDoctorModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: PreRegisterDoctorModel.self) { result in
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
    
    func doctorVerify(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: VerifyDoctorModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: VerifyDoctorModel.self) { result in
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
    
    func doctorRegistation(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: RegistationModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: RegistationModel.self) { result in
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

    func doctor_clinic_Registation(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: LoginModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: LoginModel.self) { result in
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
    
    func login_doctor(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: LoginModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: LoginModel.self) { result in
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
    
    func generate_doctor_OTP(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: GenerateOTPModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: GenerateOTPModel.self) { result in
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
    
    //MARK: - Add Patient
    func addPatient_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: AddPatientModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: AddPatientModel.self) { result in
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
    
    //MARK: - Get Patient
    func getPatientList_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: PatientListModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: PatientListModel.self) { result in
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
    
    
    //MARK: - Get Patient
    func deleteAccount_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: PatientListModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: PatientListModel.self) { result in
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
    
    //MARK: - Update FCM Token
    func updateFCMToken_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: UpdateFCMTokenModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: UpdateFCMTokenModel.self) { result in
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
    
    //MARK: - Appointment Slot
    func getPatientAppointmentSlot_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: PatientListModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: PatientListModel.self) { result in
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
    
    
    //MARK: - Cancel Appointment Slot
    func cancelAppointment_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: CancelAppointmentModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: CancelAppointmentModel.self) { result in
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
    
    
    //MARK: - GET Content Data
    func getContent_Data_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: ContentLibraryModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: ContentLibraryModel.self) { result in
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
    
    
    //MARK: - APpoimtment List
    func getAppointmentList_API(body: [String: Any]?, endpoint: APIEndpoints, completion: @escaping (_ status: Status, _ result: PatientListModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: BASE_URL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: PatientListModel.self) { result in
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
