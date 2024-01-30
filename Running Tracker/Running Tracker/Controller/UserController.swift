import UIKit

let MIN_HEIGHT = 130
let MAX_HEIGHT = 220
let MIN_WEIGHT = 40
let MAX_WEIGHT = 120
let MIN_AGE = 13
let MAX_AGE = 99

class UserController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private weak var flapButton: UIButton!
    @IBOutlet private weak var containeView: UIView!
    @IBOutlet private weak var userPicker: UIPickerView!
    @IBOutlet private weak var genderSegmentedControl: UISegmentedControl!
    private var dataManager: DataManager?
    private var heights: [String]?
    private var weights: [String]?
    private var ages: [String]?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13, *) {
            genderSegmentedControl.selectedSegmentTintColor = UIColor(named: "priamry")
        } else {
            genderSegmentedControl.tintColor = UIColor(named: "priamry")
            flapButton.isHidden = true
        }
        dataManager = DataManager.sharedInstance
        heights = [String]()
        for i in MIN_HEIGHT...MAX_HEIGHT {
            let row = String(format: "%i cms", i)
            heights?.append(row)
        }
        weights = [String]()
        for i in MIN_WEIGHT...MAX_WEIGHT {
            let row = String(format: "%i kgs", i)
            weights?.append(row)
        }
        ages = [String]()
        for i in MIN_AGE...MAX_AGE {
            let row = String(format: "%i años", i)
            ages?.append(row)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SYSTEM_VERSION_LESS_THAN(version: "13.0") {
            containeView.frame = CGRect(x: 0.0, y: 16.0, width: containeView.frame.size.width, height: containeView.frame.size.height)
        }
        genderSegmentedControl.selectedSegmentIndex = dataManager!.getIsUserMale() ? 0 : 1
        userPicker.selectRow(heights!.firstIndex(of: String(format: "%lu cms", UInt(dataManager!.getUserHeight()))) ?? NSNotFound, inComponent: 0, animated: false)
        userPicker.selectRow(weights!.firstIndex(of: String(format: "%lu kgs", UInt(dataManager!.getUserWeight()))) ?? NSNotFound, inComponent: 1, animated: false)
        userPicker.selectRow(ages!.firstIndex(of: String(format: "%lu años", UInt(dataManager!.getUserAge()))) ?? NSNotFound, inComponent: 2, animated: false)
        
    }
    
    // MARK: - Actions
    @IBAction func closeModal(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func genderSelected(_ sender: UISegmentedControl) {
        dataManager!.setIsUserMale(sender.selectedSegmentIndex == 0)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return heights!.count
        case 1:
            return weights!.count
        case 2:
            return ages!.count
        default:
            return 0
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return heights![row]
        case 1:
            return weights![row]
        case 2:
            return ages![row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            dataManager!.setUserHeight(MIN_HEIGHT + row)
        case 1:
            dataManager!.setUserWeight(MIN_WEIGHT + row)
        case 2:
            dataManager!.setUserAge(MIN_AGE + row)
        default:
            break
        }
    }
    
}
