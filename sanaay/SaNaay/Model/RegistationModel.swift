//
//  ScheduleStationModel.swift
//  Tummoc
//
//  Created by Kiran Nayak on 27/03/23.
//

import Foundation

struct RegistationModel: Codable {
    let status: String?
    let message: String?
    let User_Type: String?
    let Country_Code: String?
    let Mobile: String?
    let Otp: String?
    let Otp_Random_String: String?
    let data: DoctorRegisterDataResponse?
}

struct DoctorRegisterDataResponse: Codable {
    let devicemac: String?
    let doctor_mobile: String?
    let doctor_icon: String?
    let registration_number: String?
    let referral_code: String?
    let token: String?
    let doctor_email: String?
    let doctor_name: String?
    let doctor_password: String?
    let doctor_status: String?
    let countrycode: String?
    let doctor_id: Int?
}


//Pre Register Doctor
struct PreRegisterDoctorModel: Codable {
    let status: String?
    let message: String?
    let User_Type: String?
    let Country_Code: String?
    let Mobile: String?
    let Otp: String?
    let Otp_Random_String: String?
}


//Verify Doctor
struct VerifyDoctorModel: Codable {
    let status: String?
    let message: String?
}


//Clinic Registation
struct AddPatientModel: Codable {
    let status: String?
    let message: String?
    let data: AddPatientDataResponse?
}

struct AddPatientDataResponse: Codable {
    //var id: Int?
    var doctor_id: String?
    var patient_id: String?
    var patient_name: String?
    var patient_mobile: String?
    var patient_email: String?
    var patient_gender: String?
    var patient_measurement: String?
    var patient_age: String?
    var country_code: String?
    //var patient_status: Int?
}


//Generate OTP Model
struct GenerateOTPModel: Codable {
    let status: String?
    let message: String?
    let User_Type: String?
    let Country_Code: String?
    let Mobile: String?
    let Otp: Int?
    let Otp_Random_String: String?
}

//Login Model
struct LoginModel: Codable {
    let status: String?
    let message: String?
    let data: LoginDataResponse?
}

struct LoginDataResponse: Codable {
    let doctor_id: String?
    var doctor_name: String?
    let countrycode: String?
    let doctor_mobile: String?
    let doctor_email: String?
    let registration_number: String?
    let register_nadiyantra: String?
    var doctor_icon: String?
    let address: String?
    let city: String?
    let landmark: String?
    let clinic: String?
    let referral_code: String?
    let register_type: String?
    let devicemac: String?
    let doctor_status: String?
    let clinic_icon: String?
    var token: String?
    
}


//MARK: - Patient List
struct PatientListModel: Codable {
    let status: String?
    let message: String?
    let data: [PatientListDataResponse?]?
}

struct PatientListDataResponse: Codable {
    var id: String?
    var countrycode: String?
    var doctor_id: String?
    var food_preference: String?
    var patient_age: String?
    var patient_email: String?
    var patient_gender: String?
    var patient_id: String?
    var patient_measurement: String?
    var patient_mobile: String?
    var patient_name: String?
    var patient_status: String?
    var visit_time: String?
    var health_complaints: String?
    var personal_history: String?
    var family_history: String?
    var daily_routine: String?
    var patient_investigation: String?
    var prakriti: String?
    var prakriti_value: String?
    var vikriti: String?
    var cloud_vikriti: String?
    var report_link: String?
    //var prakriti_ml_reg: String?
    var vikriti_prensentage: String?
    var cloud_vikriti_prensentage: String?
    var last_assessment_data: String?
    var graph_params: String?
    var pi_index: Double?
    var hr: Int?
    var spo: Int?
    var row_ppg: String?
    let report_id: String?
    let appointment: String?
    let appointment_start: String?
    let appointment_end: String?
    let attended: String?
    let created_at: String?
    let new_patient_id: String?
    let appointment_date: String?
    let appointment_time: String?
    
}

struct general_infoResponse: Codable {
    var address: String?
    var city: String?
    var country: String?
    var postcode: String?
    var id: String?
    var doctor_id: String?
    var patient_id: String?
    var patient_name: String?
    var patient_mobile: String?
    var patient_email: String?
    var patient_gender: String?
    var patient_measurement: String?
    var date_of_birth: String?
    var country_code: String?
    var patient_status: String?
    var reason_for_consultation: String?
}


//MARK: - UPDATE FCM TOKEN MODEL
struct UpdateFCMTokenModel: Codable {
    let status: String?
    let message: String?
}

//MARK: - APPOINTMENT SLOTS
struct CancelAppointmentModel: Codable {
    let status: String?
    let message: String?
    let data: String?
}

//MARK: - Content Library
struct ContentLibraryModel: Codable {
    let status: String?
    let message: String?
    let data: ContentLibraryDataResponse?
}

struct ContentLibraryDataResponse: Codable {
    var kriya: [ContentLibraryKriya?]?
    var mudra: [ContentLibraryKriya?]?
    var meditation: [ContentLibraryKriya?]?
    var pranayam: [ContentLibraryKriya?]?
    var yogasana: [ContentLibraryKriya?]?
    var food: [ContentLibraryFood?]?
    var herbs: [ContentLibraryHerbs?]?
    var panchkarma: [ContentLibraryKriya?]?
}

struct ContentLibraryKriya: Codable {
    var favorite_id: String?
    var content_type: String?
    var type: String?
    var name: String?
    var image: String?
    var ename: String?
}

struct ContentLibraryHerbs: Codable {
    var herb_type: String?
    var herbs_list: String?
}

struct ContentLibraryFood: Codable {
    var day: String?
    var image: String?
    var section: [FoodSection?]?
}

struct FoodSection: Codable {
    var subsection: String?
    var data: [FoodData?]?
}

struct FoodData: Codable {
    var name: String?
}


//MARK: - Content Library
struct AddSuggestionModel: Codable {
    let status: String?
    let message: String?
    let data: [AddDoctorSuggestion?]?
}

struct AddDoctorSuggestion: Codable {
    var report_link: String?
}

//MARK: - Sparshna Response
struct SparshnaResultModel: Codable {
    let status: String?
    let data: [SparshnaDataResponse?]?
}

struct SparshnaDataResponse: Codable {
    var favorite_id: String?
    var title: String?
    var short_description: String?
    var what_does_means: String?
    var aggravation_type: String?
    var parameter: String?
}

//MARK: - Notfication Model
struct NotifcationListModel: Codable {
    let status: String?
    let message: String?
    let data: [NotificationListDataResponse?]?
}

struct NotificationListDataResponse: Codable {
    var id: String?
    var sender_type: String?
    var sender_id: String?
    var receiver_id: String?
    var noti_title: String?
    var noti_body: String?
    var noti_type: String?
    var noti_last_id: String?
    var seen_by_receiver: String?
    var appointment_date: String?
    var created_at: String?
}

//MARK: - Read Unread Notfication
struct Status_NotificationModel: Codable {
    let status: String?
    let message: String?
}


//Prakriti
struct PrakritiML_RegModel: Codable {
    let status: String?
    let reg: String?
}

//Vikriti
struct Vikriti_Prediction_Model: Codable {
    let type: String?
    let agg_kpv: String?
    let xai_result: String?
}
