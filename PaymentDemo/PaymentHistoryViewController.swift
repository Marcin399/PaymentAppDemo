import UIKit
import SwiftUI
import PaymentFramework

class PaymentHistoryViewController: UIViewController {
    private let tableView = UITableView()
    private var transactions: [Payment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Historia"

        setupTableView()
        setupNavigationBar()
        loadTransactions()
    }

    private func setupNavigationBar() {
        let showFormButton = UIBarButtonItem(title: "Nowa płatność", style: .plain, target: self, action: #selector(showPaymentForm))
        navigationItem.rightBarButtonItem = showFormButton
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
    }

    private func loadTransactions() {
        let paymentStorage = PaymentStorage()
        do { try transactions = paymentStorage.getAll().reversed()
        } catch { print("Error loading transactions: \(error)")}
        tableView.reloadData()
    }

    @objc private func showPaymentForm() {
        let config = PaymentUIConfig(primaryColor: Color(UIColor.systemBlue), inputBackground: Color(UIColor.secondarySystemBackground))
        let paymentVC = PaymentViewController(amount: Double.random(in: 10...300), config: config)

        paymentVC.onDismiss = { [weak self] in
            self?.loadTransactions()
        }

        navigationController?.pushViewController(paymentVC, animated: true)
    }
}

extension PaymentHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let payment = transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = String(format: "%.2f zł - %@", payment.amount, payment.status == .success ? "Zaakceptowana" : "Odrzucona")
        config.secondaryText = DateFormatter.localizedString(from: payment.date, dateStyle: .medium, timeStyle: .short)
        config.textProperties.adjustsFontForContentSizeCategory = true
        config.secondaryTextProperties.adjustsFontForContentSizeCategory = true
        cell.contentConfiguration = config

        return cell
    }
}
