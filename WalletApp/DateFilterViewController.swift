import UIKit
import CoreData

class DateFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    // Core Data context
    var managedContext: NSManagedObjectContext!

    // Veritabanından çekilen işlemler
    var filteredTransactions: [WalletTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Core Data context erişimi
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedContext = appDelegate.persistentContainer.viewContext
        
        // TableView setup
        tableView.dataSource = self
        tableView.delegate = self

        setupUI()
        fetchTransactions()  // Verileri çek
    }

    private func setupUI() {
        title = "Tarih Aralığı Filtreleme"
        

        // Tarih ve saat seçimi
        startDatePicker.datePickerMode = .dateAndTime
        endDatePicker.datePickerMode = .dateAndTime
      
        


        filterButton.setTitle("Filter", for: .normal)
        filterButton.layer.cornerRadius = 10
     
    }

    private func fetchTransactions() {
        let fetchRequest: NSFetchRequest<WalletTransaction> = WalletTransaction.fetchRequest()

        do {
            filteredTransactions = try managedContext.fetch(fetchRequest)
            tableView.reloadData()  // TableView'i yenile
        } catch {
            print("Veri çekilemedi: \(error)")
        }
    }

    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let start = startDatePicker.date
        let end = endDatePicker.date

        guard start <= end else {
            showAlert(title: "Geçersiz Tarih", message: "Başlangıç tarihi bitiş tarihinden sonra olamaz.")
            return
        }

        // Tarih aralığına göre filtreleme
        let fetchRequest: NSFetchRequest<WalletTransaction> = WalletTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)

        do {
            filteredTransactions = try managedContext.fetch(fetchRequest)
            tableView.reloadData()  // TableView'i yenile
        } catch {
            print("Veri çekilemedi: \(error)")
        }
    }

    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alertVC, animated: true)
    }

    // MARK: - UITableViewDataSource

    // Kaç hücre olacağını belirtiriz.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)

        let transaction = filteredTransactions[indexPath.row]
        
        // Tarih ve saat formatını ayarlayalım
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        // Hücredeki metni yalnızca tarih ve saati gösterecek şekilde ayarlayalım
        cell.textLabel?.text = formatter.string(from: transaction.date ?? Date())

        // Gelir veya gideri göstermek için + veya - işaretini ekleyelim
        let incomeOrExpense = transaction.isIncome ? "+" : "-"
        
        // Kategori ve gelir/gider bilgilerini detay metninde gösterelim
        let category = transaction.category ?? "Kategori Yok"
        let amount = String(format: "%.2f ₺", transaction.amount)
        cell.detailTextLabel?.text = "\(incomeOrExpense) \(amount) | \(category)"
        
        return cell
    }



    // MARK: - UITableViewDelegate

    // Hücreye tıklanıldığında yapılacak işlemler
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTransaction = filteredTransactions[indexPath.row]
        print("Seçilen işlem: \(selectedTransaction.category ?? "Kategori Yok") - \(selectedTransaction.amount)₺")
    }
}
