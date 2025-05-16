import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddTransactionDelegate {


@IBOutlet weak var balanceLabel: UILabel!
@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var incomePieChartView: PieChartView!
    @IBOutlet weak var expensePieChartView: PieChartView!


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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let tx = filteredTransactions[indexPath.row]

        // Başlık: Kategori
        cell.textLabel?.text = tx.category ?? "Kategori Yok"

        // Tutar ve Tarih/Saat
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = formatter.string(from: tx.date ?? Date())
        let amountText = String(format: "%@%.2f₺", tx.isIncome ? "+" : "-", tx.amount)

        // Tutar başta, tarih sağda gibi göstermek için string biçimlendirme
        let paddedAmount = String(format: "%-10s", (amountText as NSString).utf8String!)
        cell.detailTextLabel?.text = "\(amountText)     \(dateString)"

        // Renk: Gelir - Yeşil, Gider - Kırmızı
        cell.detailTextLabel?.textColor = tx.isIncome ? UIColor(hex: "#309898") : UIColor(hex: "#E55050")

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
        updatePieChart()
        updatePieChartsByCategory()
        setupLegend()

    } catch {
        print("ViewController: Veri çekilemedi: \(error)")
    }
}

func updateBalance() {
    print("ViewController: updateBalance çağrıldı.")
    let balance = transactions.reduce(0.0) { result, tx in
        return tx.isIncome ? result + tx.amount : result - tx.amount
    }
    // 🔽 Buraya stil ayarlarını ekle
    balanceLabel.textColor = .white
    balanceLabel.font = UIFont.boldSystemFont(ofSize: 20) // Yazı boyutunu isteğine göre ayarla
       
    balanceLabel.text = "Balance: \(balance) ₺"
    print("ViewController: Bakiye güncellendi: \(balance)")
}

func didAddTransaction() {
    print("ViewController: didAddTransaction delegate metodu çağrıldı.")
    loadTransactions()
    updateBalance()
    updatePieChart()
    updatePieChartsByCategory()

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
    func updatePieChart() {
        let incomeTotal = transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
        let expenseTotal = transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }

        var chartData: [(CGFloat, UIColor)] = []
        if incomeTotal > 0 {
            chartData.append((CGFloat(incomeTotal), UIColor(hex: "#64E2B7")))
        }
        if expenseTotal > 0 {
            chartData.append((CGFloat(expenseTotal), UIColor(hex: "#D50B8B")))
        }

        pieChartView.data = chartData
    }
    
    
    func updatePieChartsByCategory() {
        let incomeTransactions = transactions.filter { $0.isIncome }
        let expenseTransactions = transactions.filter { !$0.isIncome }
        let categoryColors: [String: UIColor] = [
            "Salary": UIColor(hex: "#FFB8E0"),
            "Gift": UIColor(hex: "#D3E671"),
            "Investment": UIColor(hex: "#FDAB9E"),
            "Food": UIColor(hex: "#73C7C7"),
            "Transportation": UIColor(hex: "#CB9DF0"),
            "Bill": UIColor(hex: "#FF8A8A"),
            "Other": UIColor(hex: "#667BC6"),
            "Shopping": UIColor(hex: "#F7418F"),
            "Health": UIColor(hex: "#FFDB5C"),
            "Entertainment": UIColor(hex: "#DCFFB7")
        ]



        // Grupla ve topla: kategori bazlı gelir
        let incomeByCategory = Dictionary(grouping: incomeTransactions, by: { $0.category ?? "Diğer" })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }

        // Grupla ve topla: kategori bazlı gider
        let expenseByCategory = Dictionary(grouping: expenseTransactions, by: { $0.category ?? "Diğer" })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }

        var incomeChartData: [(CGFloat, UIColor)] = []
        var expenseChartData: [(CGFloat, UIColor)] = []

        // Renkler rastgele verilebilir veya sabitlenebilir
        for (category, total) in incomeByCategory {
            let color = categoryColors[category] ?? .gray
            incomeChartData.append((CGFloat(total), color))
        }

        for (category, total) in expenseByCategory {
            let color = categoryColors[category] ?? .gray
            expenseChartData.append((CGFloat(total), color))
        }

        incomePieChartView.data = incomeChartData
        expensePieChartView.data = expenseChartData
    }
    
    func setupLegend() {
        let categoryColors: [String: UIColor] = [
            "Salary": UIColor(hex: "#FFB8E0"),
            "Gift": UIColor(hex: "#D3E671"),
            "Investment": UIColor(hex: "#FDAB9E"),
            "Food": UIColor(hex: "#73C7C7"),
            "Transportation": UIColor(hex: "#CB9DF0"),
            "Bill": UIColor(hex: "#FF8A8A"),
            "Other": UIColor(hex: "#667BC6"),
            "Shopping": UIColor(hex: "#F7418F"),
            "Health": UIColor(hex: "#FFDB5C"),
            "Entertainment": UIColor(hex: "#DCFFB7")
        ]
        let sortedCategories = ["Salary", "Gift", "Investment", "Food", "Transportation", "Bill", "Other", "Shopping", "Health", "Entertainment"]



        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        var currentRowStack: UIStackView?

        for (index, category) in sortedCategories.enumerated() {
            if index % 5 == 0 {
                // Yeni satır başlat
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 8
                mainStack.addArrangedSubview(currentRowStack!)
            }

            let colorBox = UIView()
            colorBox.backgroundColor = categoryColors[category]
            colorBox.widthAnchor.constraint(equalToConstant: 20).isActive = true
            colorBox.heightAnchor.constraint(equalToConstant: 20).isActive = true

            let label = UILabel()
            label.text = category
            label.font = UIFont.systemFont(ofSize: 10)

            let legendItem = UIStackView()
            legendItem.axis = .horizontal
            legendItem.spacing = 8
            legendItem.addArrangedSubview(colorBox)
            legendItem.addArrangedSubview(label)

            currentRowStack?.addArrangedSubview(legendItem)
        }

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: pieChartView.bottomAnchor, constant: 16),
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }





}
