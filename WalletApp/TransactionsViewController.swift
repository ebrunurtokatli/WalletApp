import UIKit
import CoreData

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!

    var allTransactions: [WalletTransaction] = []
    var filteredTransactions: [WalletTransaction] = []
    var categories: [String] = []
    var selectedCategory: String?
    @IBAction func backButtonTapped(_ sender: UIButton) {
        // örneğin: bir önceki sayfaya dön
        self.dismiss(animated: true, completion: nil)
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self

        loadTransactions()
    }

    func loadTransactions() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<WalletTransaction> = WalletTransaction.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        do {
            allTransactions = try context.fetch(request)
            categories = Array(Set(allTransactions.map { $0.category ?? "Diğer" })).sorted()
            selectedCategory = categories.first
            filterTransactions()
            pickerView.reloadAllComponents()
        } catch {
            print("Veri yüklenemedi: \(error)")
        }
    }

    func filterTransactions() {
        guard let category = selectedCategory else { return }
        filteredTransactions = allTransactions.filter { $0.category == category }
        tableView.reloadData()

        let incomeTotal = filteredTransactions
            .filter { $0.isIncome }
            .reduce(0.0) { $0 + $1.amount }

        let expenseTotal = filteredTransactions
            .filter { !$0.isIncome }
            .reduce(0.0) { $0 + $1.amount }

        incomeLabel.text = "Incomes: +\(incomeTotal)₺"
        expenseLabel.text = "Expenses: -\(expenseTotal)₺"

        pieChartView.data = [
            (value: CGFloat(incomeTotal), UIColor(hex: "#64E2B7")),
            (value: CGFloat(expenseTotal), UIColor(hex: "#D50B8B"))
        ]
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tx = filteredTransactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        cell.textLabel?.text = tx.category
        cell.detailTextLabel?.text = "\(tx.isIncome ? "+" : "-")\(tx.amount)₺"
        return cell
    }

    // MARK: - PickerView

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        filterTransactions()
    }
}
