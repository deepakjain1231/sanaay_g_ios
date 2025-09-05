//
//  APIEndpoints.swift
//  Tummoc
//
//  Created by Kiran Nayak on 05/01/23.
//

import Foundation

/// This is used to get endpoints of an API
enum APIEndpoints : String {
    case none = ""
    case preRegisterDoc = "PreRegisterDoctorForOTP"
    
    case verify_doctor = "VerifyDoctor"
    case doctor_register = "RegisterDoctor"// "RegisterDoctorForIOS"// "RegisterDoctor"
    case AddClinic = "AddClinic"
    case EditClinic = "EditClinic"
    case LoginDoctor = "LoginDoctor"
    case GenerateOTP = "GenerateLoginOTP"
    case updateFCMToken = "UpdateDoctorFCMToken"
    
    case AddPatient = "SetPatientDetailV1"
    case EdtiPatient = "EditPatientDetail"
    
    case patient_list = "FetchPatientsListV1"
    case patient_history = "FetchPatientVisitsV1"
    
    case appointmentSlot = "CheckBookedAppointmentSlot"
    case cancelAppointment = "DoctorSideCancelAppointment"
    case GetContentLibrary = "GetContentLibrary"
    case ViewMoreContentLibrary = "GetViewMoreContentLibraryData"
    
    case SparshnaResult = "get_sparshna_result"
    case EditProfileDoctor = "EditProfileDoctor"
    case delete_Doctor = "DeleteDoctorAccount"
    
    case GetTags = "GetTags"
    case PatientDiagnosis = "PatientDiagnosis"
    case get_prakriti_questions = "FetchPrakritiQuestionnaire"
    case Ksubmit_prakritiQuestion = "SubmitPrakritiResponse"
    case Ksubmit_vikratiResponse = "SubmitVikritiResponse"
    
    case CheckAppointment = "CheckAppointment"
    case DeletePatientInfo = "DeletePatientInfo"
    case AddPatientApppointment = "AddPatientApppointment"
    case EditPatientAppointment = "EditPatientAppointment"
    
    case AppointmentList = "AppointmentListV1"
    
    case AddSuggetions_Report = "SanayResultsjSON1"
    
    case get_Naadi_questions = "FetchNadiQuestionnaire"
}
