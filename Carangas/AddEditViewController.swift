//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

enum CarOperationAction {
    case add_car
    case edit_car
    case get_brands
}

class AddEditViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    // MARK: - Properties
    var car: Car?
    
    var brands: [Brand] = []
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    } ()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if car != nil {
            // modo edicao
            tfBrand.text = car!.brand
            tfName.text = car!.name
            tfPrice.text = "\(car!.price)"
            scGasType.selectedSegmentIndex = car!.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerView
        loadBrands()
    }
    private func editar(){
        AlomofireRest.update(car: car!, onComplete: { (sucess) in
                   self.goBack()
               }, onError: { (carError) in
                   var response: String = ""
                
                   switch carError {
                   case .invalidJSON:
                       response = "invalidJSON"
                   case .noData:
                       response = "noData"
                   case .noResponse:
                       response = "noResponse"
                   case .url:
                       response = "JSON inválido"
                   case .taskError(let error):
                       response = "\(error.localizedDescription)"
                   case .responseStatusCode(let code):
                       if code != 200 {
                           response = "Algum problema com o servidor. :( \nError:\(code)"
                       }
                   }
                   // TODO substituir por um objeto Alerta para exibir para o usuario
                   print(response)
               })
    }
    
    
    // MARK: - IBActions
    fileprivate func salvar() {
        //Alterando do rest para AlamofireRest
        AlomofireRest.save(car: car!, onComplete: { (sucess) in
            self.goBack()
        }, onError: { (carError) in
            var response: String = ""
            
            switch carError {
            case .invalidJSON:
                response = "invalidJSON"
            case .noData:
                response = "noData"
            case .noResponse:
                response = "noResponse"
            case .url:
                response = "JSON inválido"
            case .taskError(let error):
                response = "\(error.localizedDescription)"
            case .responseStatusCode(let code):
                if code != 200 {
                    response = "Algum problema com o servidor. :( \nError:\(code)"
                }
            }
            
            // TODO substituir por um objeto Alerta para exibir para o usuario
            print(response)
        })
    }
    
    @IBAction func addEdit(_ sender: UIButton) {
        
        if car == nil {
            // adicionar carro novo
            car = Car()
        }
        
        car?.name = (tfName?.text)!
        car?.brand = (tfBrand?.text)!
        if tfPrice.text!.isEmpty {
            tfPrice.text = "0"
        }
        car?.price = Double(tfPrice.text!)!
        car?.gasType = scGasType.selectedSegmentIndex
        if(car?._id == nil){
            salvar()
        }else{
            editar()
        }
        
    }
    func goBack() {
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].fipe_name
        cancel()
    }
    
    func loadBrands() {
        
        REST.loadBrands { (brands) in
            guard let brands = brands else {return}
            
            // ascending order
            self.brands = brands.sorted(by: {$0.fipe_name < $1.fipe_name})
            
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
            
        }
    }
    
    func showAlert(withTitle titleMessage: String, withMessage message: String, isTryAgain hasRetry: Bool, operation oper: CarOperationAction) {
        
        if oper != .get_brands {
            DispatchQueue.main.async {
                // ?
            }
        }
        
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
        
        if hasRetry {
            let tryAgainAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: {(action: UIAlertAction) in
                /*
                 switch oper {
                 case .add_car:
                 // ?
                 case .edit_car:
                 // ?
                 case .get_brands:
                     // ?
                 }
                 **/
            })
            alert.addAction(tryAgainAction)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action: UIAlertAction) in
                self.goBack()
            })
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func startLoadingAnimation() {
        self.btAddEdit.isEnabled = false
        self.btAddEdit.backgroundColor = .gray
        self.btAddEdit.alpha = 0.5
        self.loading.startAnimating()
    }
    
    func stopLoadingAnimation() {
        self.btAddEdit.isEnabled = true
        self.btAddEdit.backgroundColor = UIColor(named: "main")
        self.btAddEdit.alpha = 0
        self.loading.stopAnimating()
    }
    
    
}

extension AddEditViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let brand = brands[row]
        return brand.fipe_name
    }
    
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
}

