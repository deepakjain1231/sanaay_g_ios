//
//  Credential.swift
//  element3
//
//  Created by Zignuts Technolab on 25/07/19.
//  Copyright © 2019 Zignuts Technolab. All rights reserved.
//

import Foundation
//MARK:- AMAZONE



// Google Map API KEY
let kGOOGLE_MAP_APIKEY = ""



//MARK: - ROZARPAY DEVELOPEMENT KEY
//### DEVELOPMENT KEY
let RAZORPAY_KEY_ID = ""
let RAZORPAY_KEY_SECRET = ""


//MARK: - Common Webview ULRLS
let kTermsAndCondition = "https://www.ayurythm.com/termsandconditions.html"
let kPrivacyPolicy = "https://www.ayurythm.com/privacypolicy.html"
let kAbout_Us = "https://www.sanaay.com/home/"
//***************************************************************//
//***************************************************************//

var URL_prakriti_ml = "https://ayurapi.ayurythm.com/prakriti-ml-reg"
var URL_vikriti_prediction = "https://ayurapi.ayurythm.com/vikriti-dosha-pred-test"
// "https://ayurapi.ayurythm.com/vikriti-dosha-pred"





//MARK: - Social Webview ULRLS




//=====================================================================================//
//=====================================================================================//
//=====================================================================================//
 
 
//MARK: - Developement Server
let is_appLive = false
let kBASE = "https://api.sanaay.com/";
//let BASE_URL = "https://api.sanaay.com/api/v3/apiv2/";
let BASE_URL = "https://dev.ayurythm.com/SanaayG/api/";
//*************************************************************************************//
//*************************************************************************************//
//*************************************************************************************//





/*
//=====================================================================================//
//=====================================================================================//
//=====================================================================================//
//MARK: - Live
/* ** Live API ** */

let BASE_URL = "https://ayurythm.com/Tavisa/";
//*************************************************************************************//
//*************************************************************************************//
//*************************************************************************************//
*/


enum endPoint: String {
    case usergraphspar = "usergraphspar"
    case KprakritiQuestion = "FetchPrakritiQuestionnaireDoctorSide"
    case KmenoPauseQuestion = "FetchMenopauseQuestionnaireDoctorSide"
    
    case kGetPregnancyQuestionnaire = "FetchPregnancyQuestionswithOptionDoctorSide"
    case kSubmitPragnanacyQuestionaire = "SubmitPregnancyResponseDoctorSide"
    
    
    
    
    case kGetFAQ_Data = "GetFAQ"
    
    //Suggestion API
    case kGetAushadiForm = "GetAushadiForm"
    case kAddAushadhiName = "AddAushadhiName"
    case kGetTags = "GetTags"
    
    //Appointment Slot
    case kGetAvailableAppointmentSlotDoctorSide = "GetAvailableAppointmentSlotDoctorSide"
    case kAddPatientApppointment = "AddPatientApppointment"
    case kRescheduleAppointmentDoctorSide = "RescheduleAppointmentDoctorSide"
}

