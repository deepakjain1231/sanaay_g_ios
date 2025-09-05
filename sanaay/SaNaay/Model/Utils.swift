import UIKit
import Alamofire

//let VIKRITI_PRASHNA = "VikritiPrashna"
//let RESULT_VIKRITI = "ResultVikriti"
let VIKRITI_SPARSHNA = "VikritiSparshna"
//let RESULT_PRAKRITI = "ResultPrakriti"
//let LAST_ASSESSMENT_DATA = "LastAssessmentData"
//let kMenopauseAnswers = "MenopauseAnswers"
//let kRESULT_MENOPAUSE = "MenoPauseResult"
//let kSkippedQuestions = "SkippedQuestions"
//let kPrakritiAnswers = "PrakritiAnswers"
let kPrakritiAnswersToSend = "PrakritiAnswersToSend"
let kVikritiSparshanaCompleted = "VikritiSparshnaCompleted"


class Utils: NSObject {
    
    class func getTopViewController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    class func getVikritiValue() -> String {
        
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0

        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_SPARSHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        let total = kaphaCount + pittaCount + vataCount
        
        var percentKapha = kaphaCount*100.0/total
        var percentPitta = pittaCount*100.0/total
        var percentVata = vataCount*100.0/total
        
        if total == 0 {
            return ""
        }
        
        percentKapha = percentKapha.rounded(.up)
        percentPitta = percentPitta.rounded(.up)
        percentVata = 100 - (percentKapha + percentPitta)
        
        return "\"\(percentKapha.roundToOnePlace)\",\"\(percentPitta.roundToOnePlace)\",\"\(percentVata.roundToOnePlace)\""
    }
    
    class func getCalculateAggrivation() -> CurrentKPVStatus {
        var is_vikrati = false
        var is_prakriti = false
        var doshaType = CurrentKPVStatus.KAPHA
        
        //For Vikrati Sparshn
        var kapha_Sparshna = 0.0
        var pitta_Sparshna = 0.0
        var vata_Sparshna = 0.0
        
        if let str_vikriti = appDelegate.dic_patient_response?.vikriti_prensentage as? String {
            var str_vikritiPrensentage = str_vikriti.replacingOccurrences(of: "[", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "]", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "\"", with: "")

            let arrVikritiScore:[String] = str_vikritiPrensentage.components(separatedBy: ",")
            if  arrVikritiScore.count == 3 {
                is_vikrati = true
                kapha_Sparshna = Double(arrVikritiScore[0].trimed()) ?? 0
                pitta_Sparshna = Double(arrVikritiScore[1].trimed()) ?? 0
                vata_Sparshna = Double(arrVikritiScore[2].trimed()) ?? 0
            }
        }
        
        //For Prakriti
        var kapha_Prakriti = 0.0
        var pitta_Prakriti = 0.0
        var vata_Prakriti = 0.0

        if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
            is_prakriti = true
            var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kapha_Prakriti = Double(arrPrashnaScore[0].trimed()) ?? 0
                pitta_Prakriti = Double(arrPrashnaScore[1].trimed()) ?? 0
                vata_Prakriti = Double(arrPrashnaScore[2].trimed()) ?? 0
            }
        }
        
        if is_vikrati &&  is_prakriti {
            
            let kaphaDifferential = kapha_Sparshna - kapha_Prakriti
            let pittaDifferential = pitta_Sparshna - pitta_Prakriti
            let vataDifferential = vata_Sparshna - vata_Prakriti

            if vataDifferential > 5 {
                doshaType = .VATA;
            } else if pittaDifferential > 5 {
                doshaType = .PITTA;
            } else if kaphaDifferential > 5 {
                doshaType = .KAPHA;
            } else {
                doshaType = .BALANCED;
            }
        }
        return doshaType
    }
    
    class func showAlertWithTitleInController(_ title:String , message:String,controller:UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        if appDelegate.window?.rootViewController?.presentedViewController != nil {
            //Present the alert view on the current presented view controller
            appDelegate.window?.rootViewController?.presentedViewController?.present(alertController, animated: true, completion: nil)

        }else {
            controller.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    class func getCustom_Prakriti(k_cout: Int, p_cout: Int, v_cout: Int) -> CurrentPrakritiStatus {
        let kaphaCount = Double(k_cout)
        let pittaCount = Double(p_cout)
        let vataCount = Double(v_cout)

        //3 5 % diff
        if (abs(pittaCount - kaphaCount) <= 5) && (abs(pittaCount - vataCount) <= 5) && (abs(vataCount - kaphaCount) <= 5) {
            // 3 doshas
            return .TRIDOSHIC
        } else {
            if pittaCount >= kaphaCount && pittaCount >= vataCount {
                if (abs(kaphaCount - pittaCount) <= 5) && ((abs(kaphaCount - vataCount) > 5) || (abs(vataCount - pittaCount) > 5)){
                    // Pitta-Kapha
                    return .KAPHA_PITTA
                }
                else  if (abs(vataCount - pittaCount) <= 5) && ((abs(pittaCount - vataCount) > 5) || (abs(kaphaCount - pittaCount) > 5)) {
                    // Vata-Pitta
                    return .VATA_PITTA
                } else {
                    // Pitta
                    return .PITTA
                }
            } else if vataCount >= kaphaCount && vataCount >= pittaCount {
                if (abs(kaphaCount - vataCount) <= 5) && ((abs(kaphaCount - pittaCount) > 5) || (abs(vataCount - pittaCount) > 5)) {
                    // Kapha and Vata
                    return .KAPHA_VATA
                }
                else  if (abs(vataCount - pittaCount) <= 5) && ((abs(pittaCount - vataCount) > 5) || (abs(kaphaCount - pittaCount) > 5)) {
                    // Vata-Pitta
                    return .VATA_PITTA
                } else {
                    // Vata
                    return .VATA
                }
            } else {
                // Kapha
                if (abs(kaphaCount - vataCount) <= 5) && ((abs(kaphaCount - pittaCount) > 5) || (abs(vataCount - pittaCount) > 5)) {
                    // Kapha and Vata
                    return .KAPHA_VATA
                }
                else  if (abs(kaphaCount - pittaCount) <= 5) && ((abs(kaphaCount - vataCount) > 5) || (abs(vataCount - pittaCount) > 5)){
                    // Pitta-Kapha
                    return .KAPHA_PITTA
                } else {
                    // Kapha
                    return .KAPHA
                }
            }
        }
    }
    
    class func getYourCurrentPrakritiStatus() -> CurrentPrakritiStatus {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        
        let strkpvValue = ""//appDelegate.dic_patient_response?.prakriti_ml_reg ?? ""
        if strkpvValue != "" {
            var strPrashna = strkpvValue.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: " ", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaCount += Double(arrPrashnaScore[1].trimed()) ?? 0
                vataCount += Double(arrPrashnaScore[2].trimed()) ?? 0
            }
        }
        
        //3 5 % diff
        if (abs(pittaCount - kaphaCount) <= 5) && (abs(pittaCount - vataCount) <= 5) && (abs(vataCount - kaphaCount) <= 5) {
            // 3 doshas
            return .TRIDOSHIC
        } else {
            if pittaCount >= kaphaCount && pittaCount >= vataCount {
                if (abs(pittaCount - kaphaCount) <= 5) && ((abs(kaphaCount - vataCount) > 5) || (abs(vataCount - pittaCount) > 5)){
                    // Pitta-Kapha
                    return .KAPHA_PITTA
                }
                else  if (abs(vataCount - pittaCount) <= 5) && ((abs(pittaCount - vataCount) > 5) || (abs(kaphaCount - pittaCount) > 5)) {
                    // Vata-Pitta
                    return .VATA_PITTA
                } else {
                    // Pitta
                    return .PITTA
                }
            } else if vataCount >= kaphaCount && vataCount >= pittaCount {
                if (abs(kaphaCount - vataCount) <= 5) && ((abs(kaphaCount - pittaCount) > 5) || (abs(vataCount - pittaCount) > 5)) {
                    // Kapha and Vata
                    return .KAPHA_VATA
                }
                else  if (abs(vataCount - pittaCount) <= 5) && ((abs(pittaCount - vataCount) > 5) || (abs(kaphaCount - pittaCount) > 5)) {
                    // Vata-Pitta
                    return .VATA_PITTA
                } else {
                    // Vata
                    return .VATA
                }
            } else {
                // Kapha
                if (abs(kaphaCount - vataCount) <= 5) && ((abs(kaphaCount - pittaCount) > 5) || (abs(vataCount - pittaCount) > 5)) {
                    // Kapha and Vata
                    return .KAPHA_VATA
                }
                else  if (abs(pittaCount - kaphaCount) <= 5) && ((abs(kaphaCount - vataCount) > 5) || (abs(vataCount - pittaCount) > 5)){
                    // Pitta-Kapha
                    return .PITTA_KAPHA
                } else {
                    // Kapha
                    return .KAPHA
                }
            }
        }
    }
    
    class func getYourCurrentKPVState(isHandleBalanced: Bool = true) -> CurrentKPVStatus {
        let increasedValues = getIncreasedValues()
        if increasedValues.contains(.VATA) && increasedValues.contains(.PITTA) {
            return .VATA
        } else if increasedValues.contains(.VATA) && increasedValues.contains(.KAPHA)  {
            return .VATA
        } else if increasedValues.contains(.PITTA) && increasedValues.contains(.KAPHA)  {
            return .PITTA
        } else if increasedValues.contains(.VATA) {
            return .VATA
        } else if increasedValues.contains(.PITTA) {
            return .PITTA
        } else if increasedValues.contains(.KAPHA) {
            return .KAPHA
        } else {
            if isHandleBalanced {
                if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
                    //prakriti test given
                    let prakritiIncreaseValue = Utils.getPrakritiIncreaseValue()
                    switch prakritiIncreaseValue {
                    case .vata:
                        return .VATA
                    case .pitta:
                        return .PITTA
                    default:
                        return .KAPHA
                    }
                } else {
                    //prakriti test not given
                    let percentage = Utils.getRecommendationTypePercentage()
                    if percentage.vata >= percentage.kapha && percentage.vata >= percentage.pitta {
                        return .VATA
                    } else if percentage.pitta >= percentage.kapha && percentage.pitta >= percentage.vata {
                        return .PITTA
                    } else {
                        return .KAPHA
                    }
                }
            } else {
                return .BALANCED
            }
        }
    }
    
    class func getYourCurrentKPVState_Temp_Cloud(isHandleBalanced: Bool = true) -> CurrentKPVStatus {
        let increasedValues = getIncreasedValues_Cloud_Temp()
        if increasedValues.contains(.VATA) && increasedValues.contains(.PITTA) {
            return .VATA
        } else if increasedValues.contains(.VATA) && increasedValues.contains(.KAPHA)  {
            return .VATA
        } else if increasedValues.contains(.PITTA) && increasedValues.contains(.KAPHA)  {
            return .PITTA
        } else if increasedValues.contains(.VATA) {
            return .VATA
        } else if increasedValues.contains(.PITTA) {
            return .PITTA
        } else if increasedValues.contains(.KAPHA) {
            return .KAPHA
        } else {
            if isHandleBalanced {
                if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
                    //prakriti test given
                    let prakritiIncreaseValue = Utils.getPrakritiIncreaseValue()
                    switch prakritiIncreaseValue {
                    case .vata:
                        return .VATA
                    case .pitta:
                        return .PITTA
                    default:
                        return .KAPHA
                    }
                } else {
                    //prakriti test not given
                    let percentage = Utils.getRecommendationTypePercentage()
                    if percentage.vata >= percentage.kapha && percentage.vata >= percentage.pitta {
                        return .VATA
                    } else if percentage.pitta >= percentage.kapha && percentage.pitta >= percentage.vata {
                        return .PITTA
                    } else {
                        return .KAPHA
                    }
                }
            } else {
                return .BALANCED
            }
        }
    }
    
    //PRAKRITI - FOR YOU
    class func getPrakritiIncreaseValue() -> RecommendationType {
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
            var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaP = Double(arrPrashnaScore[1].trimed()) ?? 0
                vataP = Double(arrPrashnaScore[2].trimed()) ?? 0
                
                if vataP > kaphaP && vataP > pittaP {
                    return .vata
                } else  if pittaP > kaphaP && pittaP > vataP {
                    return .pitta
                } else {
                    return .kapha
                }
            }
        }
        return .kapha
    }
    
    class func getIncreasedValues() -> [KPVType] {
        var increasedValues = [KPVType]()
        
        func setStatus(prakriti: Double, vikriti: Double, kpvType: KPVType) {
            if abs(vikriti - prakriti) <= 5 {
                //if value is less than or equal to 5 then normal
            } else if vikriti > prakriti {
                //If vikriti value is higher than prakriti= aggrevated
                increasedValues.append(kpvType)
            }
        }
        
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
            var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return increasedValues
        }
        
        if let str_vikriti = appDelegate.dic_patient_response?.vikriti_prensentage as? String {
            
            var str_vikritiPrensentage = str_vikriti.replacingOccurrences(of: "[", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "]", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "\"", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.trimed()
            let arrPrashnaScore = str_vikritiPrensentage.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
        
        return increasedValues
    }
    
    class func getIncreasedValues_Cloud_Temp() -> [KPVType] {
        var increasedValues = [KPVType]()
        
        func setStatus(prakriti: Double, vikriti: Double, kpvType: KPVType) {
            if abs(vikriti - prakriti) <= 5 {
                //if value is less than or equal to 5 then normal
            } else if vikriti > prakriti {
                //If vikriti value is higher than prakriti= aggrevated
                increasedValues.append(kpvType)
            }
        }
        
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
            var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return increasedValues
        }
        
        if let str_vikriti = appDelegate.dic_patient_response?.cloud_vikriti_prensentage as? String {
            
            var str_vikritiPrensentage = str_vikriti.replacingOccurrences(of: "[", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "]", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "\"", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.trimed()
            let arrPrashnaScore = str_vikritiPrensentage.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
        
        return increasedValues
    }
    
    
    class func getIncreasedValues_cloud_Temp() -> [KPVType] {
        var increasedValues = [KPVType]()
        
        func setStatus(prakriti: Double, vikriti: Double, kpvType: KPVType) {
            if abs(vikriti - prakriti) <= 5 {
                //if value is less than or equal to 5 then normal
            } else if vikriti > prakriti {
                //If vikriti value is higher than prakriti= aggrevated
                increasedValues.append(kpvType)
            }
        }
        
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
            var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return increasedValues
        }
        
        if let str_vikriti = appDelegate.dic_patient_response?.cloud_vikriti_prensentage as? String {
            
            var str_vikritiPrensentage = str_vikriti.replacingOccurrences(of: "[", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "]", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "\"", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.trimed()
            let arrPrashnaScore = str_vikritiPrensentage.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
        
        return increasedValues
    }
    
    class func getRecommendationTypePercentage() -> (kapha:Double, pitta: Double, vata: Double) {
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_SPARSHNA) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaP += Double(arrPrashnaScore[0]) ?? 0
                pittaP += Double(arrPrashnaScore[1]) ?? 0
                vataP += Double(arrPrashnaScore[2]) ?? 0
                
                let total = kaphaP + pittaP + vataP
                
                let percentKapha = round(kaphaP*100.0/total)
                let percentPitta =  round(pittaP*100.0/total)
                let percentVata =  round(vataP*100.0/total)
        
                return (percentKapha, percentPitta, percentVata)
            }
        }
        return (0,0,0)
    }
    
        
    class func showAlertWithTitleInControllerWithCompletion(_ title: String?, message: String, okTitle:String ,controller: UIViewController, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (_) in
            completionHandler()
        }))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func parseValidValue(string: String) -> String {
        let seprated = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "\"", with: "")
        return seprated
    }
    
    class func getAnswersString(dicAnswers: [Int: Any]) -> String {
        var strAnswers = "["
        for (key, value) in dicAnswers {
            strAnswers += "{\(key),\(value)},"
        }
        strAnswers.removeLast()
        strAnswers += "]"
        return strAnswers
    }
    
    
    class func convertKgToPounds(kg: String) -> String {
        let lb = (Double(kg) ?? 0.0) *  2.20462
        return "\(lb.rounded(.up))"
    }
    
    class func convertPoundsToKg(lb: String) -> String {
        let kg = (Double(lb) ?? 0.0) *  0.45359237
        let kgs = "\(kg)".components(separatedBy: ".")
        return "\(kgs[0])"
    }
    
    class func convertHeightInCms(ft: String, inc: String) -> Double {
        let inches = ((Double(inc) ?? 0) * 2.54)
        return ((Double(ft) ?? 0) * 30.48) + inches
    }
    
    class func convertHeightInFtIn(cms: Double) -> (Int, Int) {
        let feet = cms*0.0328084
        let feetShow = Int(floor(feet)) // 1234
        let feetRest = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100) // 0.56789
        let inches = Int(floor(feetRest * 12))
        return (Int(feetShow), Int(inches))
    }
}

extension Double {
    var roundToOnePlace: Double {
        let str = String(format: "%0.1f", self)
        return Double(str) ?? 0.0
    }
}

extension Utils {
    static var apiCallHeaders: HTTPHeaders {
        get {
            return ["Authorization": Utils.getAuthToken()]
        }
    }
}

//MARK:- Alert Controllers
extension Utils {
    
    class func dismissAnyAlertControllerIfPresent(completion:@escaping () -> Void) {
        guard let window :UIWindow = UIApplication.shared.keyWindow , var topVC = window.rootViewController?.presentedViewController else {
            completion()
            return
        }
        while topVC.presentedViewController != nil  {
            topVC = topVC.presentedViewController!
        }
        topVC.dismiss(animated: false, completion: {
            completion()
        })
    }
    
    class func checkIfAnyAlertControllerIsPresent(completion:@escaping (_ isPresent: Bool) -> Void) {
        guard let window :UIWindow = UIApplication.shared.keyWindow , var topVC = window.rootViewController?.presentedViewController else {
            completion(false)
            return
        }
        while topVC.presentedViewController != nil  {
            topVC = topVC.presentedViewController!
        }
        
        completion(true)
    }
    
    class func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "", message: message , preferredStyle: .alert)
        alertController.dismiss(animated: true, completion: nil)
        let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(actionOk)
        Utils.getTopViewController().present(alertController, animated: true)
    }
    
    class func showAlertMedicalLens(withMessage message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.dismiss(animated: true, completion: nil)
        let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(actionOk)
        Utils.getTopViewController().present(alertController, animated: true)
    }
    
    class func showActionSheet(title: String, message: String, buttons: [String], completion : @escaping (String) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        for btnTitle in buttons {
            alert.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { (action) in
                completion(btnTitle)
            }))
        }
        alert.addAction(cancel)
        Utils.getTopViewController().present(alert, animated: true, completion: nil)
    }
    
    class func showAlertOkController(title: String, message: String, buttons: [String], completion : @escaping (String) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for btnTitle in buttons {
            alert.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { (action) in
                completion(btnTitle)
            }))
        }
        Utils.getTopViewController().present(alert, animated: true, completion: nil)
    }
}

//MARK:- Validations Regex
extension Utils {
    
    class func isEmailValid(txt: String) -> Bool {
        let Email_REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", Email_REGEX)
        let result =  emailTest.evaluate(with: txt)
        return result
    }
    
    
    class func validate(phoneNumber: String) -> Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
    }
    
    class func isPhoneNumberWithCountryCode(number:String) -> Bool{
        let numberRegEx = "[+0-9]{6,15}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        if numberTest.evaluate(with: number) == true {
            return true
        }
        else {
            return false
        }
    }
    
    class func isPhoneNumber(number:String) -> Bool{
        let numberRegEx = "[+0-9]{10,15}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        if numberTest.evaluate(with: number) == true {
            return true
        }else {
            return false
        }
    }
    
    class func isValidAddress(txt: String) -> Bool {
        let Address_REGEX = "^[.0-9a-zA-Zs,-]+$"
        let addressTest = NSPredicate(format: "SELF MATCHES %@", Address_REGEX)
        let result =  addressTest.evaluate(with: txt)
        return result
    }
    
    class func isValidZipCode(txt: String) -> Bool {
        let zip_REGEX = "{5,6}"
        let zipTest = NSPredicate(format: "SELF MATCHES %@", zip_REGEX)
        let result =  zipTest.evaluate(with: txt)
        return result
    }
    
    
    class func isPassword(txt: String) -> Bool {
        let passwordRegex = "{6,20}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        let result =  passwordTest.evaluate(with: txt)
        return result
    }
    
}

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UILabel {
    func setBulletListedAttributedText(stringList: [String], bullet: String = "•", paragraphSpacing: CGFloat = 0) {
        let capitalizingFirstLetterStringList = stringList.map{ $0.capitalizingFirstLetter() }
        attributedText = NSAttributedString.bulletListedAttributedString(stringList: capitalizingFirstLetterStringList, font: font, bullet: bullet, paragraphSpacing: paragraphSpacing, textColor: textColor, bulletColor: textColor)
    }
}

extension NSAttributedString {
    static func bulletListedAttributedString(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 12,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 0,
             textColor: UIColor = .gray,
             bulletColor: UIColor = .green) -> NSAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }
}


extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

   func truncated(limit: Int = 130, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count >= limit else { return self }

        switch position {
        case .head:
            return leader + self.suffix(limit)
        
        case .middle:
            let halfCount = (limit - leader.count).quotientAndRemainder(dividingBy: 2)
            let headCharactersCount = halfCount.quotient + halfCount.remainder
            let tailCharactersCount = halfCount.quotient
            return String(self.prefix(headCharactersCount)) + leader + String(self.suffix(tailCharactersCount))
        
        case .tail:
            return self.prefix(limit) + leader
        }
    }
    
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func getBoldTextForSharing() -> String {
        return "*" + self + "*"
    }
}

extension UIViewController {
    func setBackButtonTitle() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
}

// MARK: -
extension DispatchQueue {
    static func delay(_ delay: DispatchTimeInterval, closure: @escaping () -> ()) {
        let timeInterval = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: timeInterval, execute: closure)
    }
}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }

}


extension Array {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }

        return String(data: theJSONData, encoding: .utf8)
    }
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }

        return String(data: theJSONData, encoding: .utf8)
    }
}


extension Utils {
    static func doAPICall(endPoint: endPoint,
                   method: HTTPMethod = .post,
                   parameters: Parameters? = nil,
                   encoding: ParameterEncoding = URLEncoding.default,
                   headers: HTTPHeaders? = nil,
                   completion: @escaping (Bool, String, String, JSON?)->Void) {
//#if DEBUG
        print(String(format: ">>> API [%@] PARAM: %@ ", endPoint.rawValue, parameters ?? [:]))
        print(String(format: ">>> API [%@] HEADER: %@ ", endPoint.rawValue, ["Authorization": Utils.getAuthToken()]))
//#endif
        if Connectivity.isConnectedToInternet {
            let urlString = BASE_URL + endPoint.rawValue
            Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON  { response in
                switch response.result {
                case .success(let value):
                    
                    debugPrint("API URL: - \(urlString)\n\nResponse:-\(value)")
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] SUCCESS: ", endPoint.rawValue))
        print(response)
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    let responseJSON = JSON(value)
                    let status = responseJSON["status"].stringValue
                    let message = responseJSON["message"].string ?? responseJSON["Message"].stringValue
                    let isSuccess = status.caseInsensitiveEqualTo("Success")
                    completion(isSuccess, status, message, responseJSON)
                case .failure(let error):
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] FAIL: %@ \nRESPONSE TEXT: %@", endPoint.rawValue, error.localizedDescription, String(data: response.data ?? Data(), encoding: .utf8) ?? ""))
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    completion(false, "", error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, "", AppMessage.no_internet, nil)
        }
    }
    
}
