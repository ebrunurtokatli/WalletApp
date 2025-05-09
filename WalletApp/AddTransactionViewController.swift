import UIKit
import CoreData

protocol AddTransactionDelegate: AnyObject {
func didAddTransaction()
}

class AddTransactionViewController: UIViewController {


@IBOutlet weak var amountTextField: UITextField!
@IBOutlet weak var categoryTextField: UITextField!
@IBOutlet weak var typeSegmentedControl: UISegmentedControl!

weak var delegate: AddTransactionDelegate?

// 🔴 Kategori listesi ve picker tanımı
let categories = ["Maaş", "Yemek", "Ulaşım", "Eğlence", "Alışveriş", "Fatura", "Sağlık", "Diğer"]
let categoryPicker = UIPickerView()

override func viewDidLoad() {
    super.viewDidLoad()
    print("AddTransactionViewController: viewDidLoad çağrıldı.")
    
    // 🔴 Picker ayarları
    categoryPicker.delegate = self
    categoryPicker.dataSource = self
    categoryTextField.inputView = categoryPicker

    // 🔴 Picker için toolbar ekle
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let doneButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(doneTapped))
    toolbar.setItems([doneButton], animated: false)
    categoryTextField.inputAccessoryView = toolbar
}

// 🔴 Picker kapatma işlemi
@objc func doneTapped() {
    categoryTextField.resignFirstResponder()
}

@IBAction func saveTapped(_ sender: UIButton) {
    print("AddTransactionViewController: Kaydet butonuna tıklandı.")

    guard let amountText = amountTextField.text, !amountText.isEmpty,
          let amount = Double(amountText),
          let category = categoryTextField.text, !category.isEmpty else {
        showAlert(message: "Tüm alanları doldurun.")
        return
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let tx = WalletTransaction(context: context)
    tx.amount = amount
    tx.category = category
    tx.date = Date()
    tx.isIncome = (typeSegmentedControl.selectedSegmentIndex == 0)

    print("AddTransactionViewController: Yeni işlem oluşturuldu. Tutar: \(amount), Kategori: \(category), Gelir mi?: \(tx.isIncome)")

    do {
        try context.save()
        print("AddTransactionViewController: İşlem kaydedildi.")
        delegate?.didAddTransaction()
        print("Delegate metodu çağrıldı")
        dismiss(animated: true)
        print("AddTransactionViewController: Görünüm kapatıldı.")
    } catch {
        print("AddTransactionViewController: Kayıt hatası: \(error)")
    }
}

@IBAction func cancelTapped(_ sender: UIButton) {
    print("AddTransactionViewController: İptal butonuna tıklandı.")
    dismiss(animated: true)
    print("AddTransactionViewController: Görünüm kapatıldı.")
}

func showAlert(message: String) {
    let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
    present(alert, animated: true)
    print("AddTransactionViewController: Uyarı gösterildi: \(message)")
}


}

// 🔴 PickerView Delegate ve DataSource uzantısı
extension AddTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
func numberOfComponents(in pickerView: UIPickerView) -> Int {
return 1
}


func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categories.count
}

func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return categories[row]
}

func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    categoryTextField.text = categories[row]
}


}
