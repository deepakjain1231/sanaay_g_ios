import Foundation
import UIKit





struct ValidationExpression {
    static let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let password = "(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$&*])(?=.*[a-z]).{6,}"
    static let characterSpace = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "
    static let numeric = "0123456789"
}

struct staticLengths {
    static let name_chanracted = 50
    static let phoneNo_chanracted = 15
}


struct StaticValues {
    static let Phone_number = "1234567890"
    static let ListingLimit = 30
}

struct Static_Height {
    static let collection_Height = UIScreen.main.bounds.width * 0.44
    static let WithoutData_Height = UIScreen.main.bounds.width * 0.22
}

enum GradientDirection {
    case Right
    case Left
    case Bottom
    case Top
    case TopLeftToBottomRight
    case TopRightToBottomLeft
    case BottomLeftToTopRight
    case BottomRightToTopLeft
}





struct MyStoryboards{
    static let main = "Main"
}

struct SMNotification{
    static let updateUserProfile = "local_noti_update_userProfile"
}

enum KPVType: String {
    case KAPHA
    case PITTA
    case VATA
}

enum RecommendationType: String {
    case kapha
    case pitta
    case vata
}

enum CurrentPrakritiStatus: String {
    
    case TRIDOSHIC
    case KAPHA_VATA
    case KAPHA_PITTA
    case PITTA_KAPHA
    case VATA_PITTA
    case VATA
    case PITTA
    case KAPHA
    
    var stringValue: String {
        switch self {
        case .TRIDOSHIC:
            return "Tridoshic"
        case .KAPHA_VATA:
            return "Kapha"//-Vata"
        case .KAPHA_PITTA:
            return "Kapha"//-Kapha"
        case .PITTA_KAPHA:
            return "PITTA"//-Kapha"
        case .VATA_PITTA:
            return "Vata"//-Pitta"
        case .VATA :
            return"Vata"
        case .PITTA:
            return "Pitta"
        case .KAPHA:
            return "Kapha"
        }
    }
}

struct AppMessage {
    static let appName = "SaNaay"
    static let Ok = "Ok"
    static let Cancel = "Cancel"
    static let firebase_token = "firebase_token"
    static let plzWait = "Please wait..."
    static let no_internet = "No Internet Connection"
    
    static let Authorise_Token = "token"
    static let USER_DATA = "user_data"
    static let USER_LOGIN = "user_login"
}

struct APPDateFormates {
    static let shortYYYYMMDD = "YYYY-MM-dd"
    static let shortDDMMYYYY = "dd-MM-YYYY"
    static let serverFormate = "YYYY-MM-dd HH:mm:ss"
    static let longFormate = "dd-MM-YYYY hh:mm a"
}

struct AppColor {
    static let app_TextGrayColor = #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1) //777777
    static let app_BorderGrayColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1) //AAAAAA
    static let app_TextBlueColor = #colorLiteral(red: 0, green: 0.5411764706, blue: 0.7019607843, alpha: 1) //#008AB3
    static let app_GreenColor = #colorLiteral(red: 0.1803921569, green: 0.4078431373, blue: 0.1725490196, alpha: 1)//#2E682C
    static let app_grayColorDot = #colorLiteral(red: 0.462745098, green: 0.4784313725, blue: 0.5058823529, alpha: 1)//#767A81
    //static let app_DarkGreenColor = #colorLiteral(red: 0.003921568627, green: 0.5764705882, blue: 0.2705882353, alpha: 1) //#019345
}

enum ScreenType {
    case none
    case add_patient
    case cancel_appointment
    case edit_profile
    case send_reminder
    case is_PrikritiAssessment
    case dose
    case duration
    case morning
    case afternoon
    case evening
    case from_facenaadi
    case confirm_appointment
    case is_privacy
    case is_termsCondition
    case about_us
    case from_time
    case to_time
    case patient_Detail
    case bookappointment
    case rescheduleAppointment
    case fromm_suggesttion
    case direct_back
    case retest_now
    case edit_patient
    case edit_prakriti
    case prakriti_sanaay
    case prakriti_doctor
}


struct kScreen_Type_ASper_Questions {
    static let none = ""
    static let Pre_Reading = "pre_reading_question"
    static let Reading_Chapter = "reading_chapter_one_the_new_arrival"
    static let Vocabulary = "vocabulary_review_match"
    static let Fill_TheGap = "fill_the_gap"
    static let SyllableExercise = "syllable_exercise"
    static let TopicalQuestions = "topical_questions"
    static let ComprehensionQuestion = "comprehension_question"
    static let Assessment = "Assessment"
}


struct staticURLs {
    static let google = "https://www.google.com"
    static let become_host_link = "https://www.studiowave.io/become-a-host/"
}

struct sound_file_Name {
    static let none = ""
    static let correct_sound_file_name = "correct_answer_tone.wav"
    static let wrong_sound_file_name = "wrong_answer_tone.wav"
    static let start_sound_file_name = "start_tune.wav"
}



struct appAssets {
}

struct kSocialMediaLoginTypes {
    static let none = ""
    static let kGoogleLogin = "google"
    static let kFacebookLogin = "facebook"
    static let kAppleLogin = "apple"
}




enum D_RegisterFieldType: Int {
    case other
    case name
    case profile
    case mobile
    case email
    case registration_no
    case designation
    case weight
    case height
    case age
    case gender
    case yogasana
    case meditation
    case pranayam
    case kriya
    case mudra
    case consult_reason
    case terms_condition
    case breakfast_food
    case lunch_food
    case dinner_food
    case panchkarma
    case food_preference
}

enum RegistationKey: String {
    case other = ""
    case doctor_name = "doctor_name"
    case register_as = "register_as"
    case doctor_icon = "doctor_icon"
    case doctor_mobile = "doctor_mobile"
    case doctor_email = "doctor_email"
    case doctor_registration = "doctor_registration"
    case countrycode = "countrycode"
    case doctor_status = "doctor_status"
    case sannay_id = "doctor_deviceid"
    case invoice_id = "invoice_id"
    case terms_condition = "terms_condition"
    
    case clinic_icon = "clinic_icon"
    case clinic_address = "clinic_address"
    case clinic_name = "clinic"
    case clinic_number = "clinic_phone"
    case address = "address"
    case city = "city"
    case landmark = "landmark"
    case country = "country"
    
    case patient_name = "patient_name"
    case patient_mobile = "mobile_number"
    case patient_email = "email_id"
    case patient_weight = "weight"
    case patient_weightUnit = "weight_unit"
    case patient_height = "height"
    case patient_heightUnit = "height_unit"
    case patient_age = "patient_age"
    case doc_gender = "gender"
    case food_preference = "food_preference"
 
    //For Suggestion
    case doctor_assessment = "doctor_assessment"
    case food_suggestions = "food_suggestions"
    case lifestyle_suggestions = "lifestyle_suggestions"
    case advice_investigations = "advice_investigations"
    case prescriptions = "health_complaints"
    case yogasana = "yogasana"
    case meditation = "meditation"
    case pranayam = "pranayam"
    case kriya = "kriya"
    case mudra = "mudra"
    
    case breakfast_food = "breakfast_food"
    case lunch_food = "lunch_food"
    case dinner_food = "dinner_food"
    case panchkarma_suggestions = "panchkarma_suggestions"
}

enum D_RegisterIdentified: Int {
    case other
    case textfield
    case textview
    case checkbox_type
    case label
    case button
    case profile
    case height_weightTextfield
    case recommendations
    case recommendations_value
    case recommendations_addNew
    case single_header
    case consult_reason
    case add_prescription
    case autocomplete_suggestion
    case doc_gender
    case view_more
    case food_preferencesField
}

enum HeightWeigtType: String {
    case none = ""
    case kg = "kg"
    case lbs = "lbs"
    case ft = "ft"
    case cm = "cm"
}


enum CurrentKPVStatus: String {
    case KAPHA
    case PITTA
    case VATA
    case BALANCED
    
    var stringValue: String {
        switch self {
        case .KAPHA:
            return "Kapha"
        case .PITTA:
            return "Pitta"
        case .VATA:
            return "Vata"
        case .BALANCED:
            return "Balance"
        }
    }
}

enum ParamType: String {
    case bpm = "bpm"
    case sp = "sp"
    case dp = "dp"
    case bala = "bala"
    case kath = "kath"
    case gati = "gati"
    case rythm = "rhythm"
    case o2r = "o2r"
    case bmi = "bmi"
    case bmr = "bmr"
    case other = "other"
}

enum kConsultReason: String {
    case kMenopause = "menopause"
    case kManopause = "manopause"
    case kPragnanacy = "pregnancy"
}

public enum bordercolor {
    case yellow
    case gray
}
public enum backgroundcolor {
    case white
    case yellowL5
}


enum kPushNotification_Type: String {
    case kAppointment = "appointment"
    case kReschedule = "reschedule-appointment"
    case kCancel_appointment = "cancel-appointment"
    case kvikriti_result = "vikriti_result"
    case kAssessment = "assessment"
}

enum kSearchTypeTag: String {
    case kNone = ""
    case kHealthComplaints = "health_complaints"
    case kPersonalHistory = "personal_history"
    case kFamilyHistory = "family_history"
    case kDailyRoutine = "daily_routine"
    case kInvestigations = "investigations"
    case kSubmitButton = "Submit"
}

enum kFoodPreferencesType: String {
    case kNone = ""
    case kVegetarian = "Vegetarian"
    case kEggetarian = "Eggetarian"
    case kNonVegetarian = "Non-Vegetarian"
}
