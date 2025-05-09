import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddTransactionDelegate {


@IBOutlet weak var balanceLabel: UILabel!
@IBOutlet weak var tableView: UITableView!

// 🔴 Yeni eklendi: Segmented Control outlet'i
@IBOutlet weak var filterSegment: UISegmentedControl!

var transactions: [WalletTransaction] = []

// 🔴 Yeni eklendi: Filtrelenmiş işlemler
var filteredTransactions: [WalletTransaction] = []

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("ViewController: viewWillAppear çağrıldı.")
    loadTransactions()
    updateBalance()
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("ViewController: numberOfRowsInSection çağrıldı. filteredTransactions.count: \(filteredTransactions.count)")
    return filteredTransactions.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print("ViewController: cellForRowAt çağrıldı. IndexPath: \(indexPath.row)")
    let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
    let tx = filteredTransactions[indexPath.row]
    cell.textLabel?.text = tx.category
    cell.detailTextLabel?.text = "\(tx.isIncome ? "+" : "-")\(tx.amount)₺"
    return cell
}

func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        // 1. Silinecek veriyi belirle
        let transactionToDelete = filteredTransactions[indexPath.row]

        // 2. Core Data context'i al
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // 3. Core Data'dan sil
        context.delete(transactionToDelete)

        do {
            try context.save()
            print("ViewController: İşlem silindi ve context kaydedildi.")
        } catch {
            print("ViewController: Silme işlemi sırasında hata oluştu: \(error)")
        }

        // 4. Tüm veriyi tekrar yükle ve filtre uygula
        loadTransactions()
        updateBalance()
    }
}


func loadTransactions() {
    print("ViewController: loadTransactions çağrıldı.")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request: NSFetchRequest<WalletTransaction> = WalletTransaction.fetchRequest()
    
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false) // En yeniye doğru sıralama
            request.sortDescriptors = [sortDescriptor]

    do {
        transactions = try context.fetch(request)
        print("ViewController: loadTransactions tamamlandı. Çekilen işlem sayısı: \(transactions.count)")
        applyFilter() // 🔴 Filtremizi burada uyguluyoruz
    } catch {
        print("ViewController: Veri çekilemedi: \(error)")
    }
}

func updateBalance() {
    print("ViewController: updateBalance çağrıldı.")
    let balance = transactions.reduce(0.0) { result, tx in
        return tx.isIncome ? result + tx.amount : result - tx.amount
    }
    balanceLabel.text = "Bakiye: \(balance) ₺"
    print("ViewController: Bakiye güncellendi: \(balance)")
}

func didAddTransaction() {
    print("ViewController: didAddTransaction delegate metodu çağrıldı.")
    loadTransactions()
    updateBalance()
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("ViewController: prepare for segue çağrıldı. Identifier: \(segue.identifier ?? "Bilinmiyor")")
    if segue.identifier == "AddTransaction" {
        if let addVC = segue.destination as? AddTransactionViewController {
            addVC.delegate = self
            print("ViewController: AddTransactionViewController'a delegate atandı.")
        }
    }
}
@IBAction func cardsButtonTapped(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowCards", sender: self)
}

// 🔴 Yeni eklendi: Segmented Control değişince çağrılacak
@IBAction func filterChanged(_ sender: UISegmentedControl) {
    applyFilter()
}

// 🔴 Yeni eklendi: Filtremizi uygula
func applyFilter() {
    switch filterSegment.selectedSegmentIndex {
    case 0:
        filteredTransactions = transactions // Tümü
    case 1:
        filteredTransactions = transactions.filter { $0.isIncome } // Gelir
    case 2:
        filteredTransactions = transactions.filter { !$0.isIncome } // Gider
    default:
        filteredTransactions = transactions
    }
    tableView.reloadData()
}


}
