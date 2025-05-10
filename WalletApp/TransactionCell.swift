import UIKit

class TransactionCell: UITableViewCell {
    
    let amountLabel = UILabel()
    let dateLabel = UILabel()
    let categoryLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(dateLabel)

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            amountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
        
        amountLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textAlignment = .right
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)    }
}

