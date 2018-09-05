import UIKit

internal class FirmListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	private static let cellReuseId = "FirmCellId"

	private lazy var tableView: UITableView = {
		let view = UITableView()
		view.delegate = self
		view.dataSource = self
		view.translatesAutoresizingMaskIntoConstraints = false
		view.register(UITableViewCell.self, forCellReuseIdentifier: FirmListVC.cellReuseId)

		return view
	}()
	
	private lazy var firms: [Firm] = [
		Firm(id: "70000001006524124", name: "Kenzo, boutique", floor: "1 Floor"),
		Firm(id: "70000001006532720", name: "Gucci, shoe store", floor: "G Floor"),
		Firm(id: "70000001006524186", name: "Milano, shoe store", floor: "1 Floor"),
		Firm(id: "70000001033296129", name: "Skechers Kids, shop", floor: "2 Floor"),
		Firm(id: "70000001006651455", name: "Vans, shoe store", floor: "2 Floor"),
		Firm(id: "70000001006515831", name: "Ecco, shoe store", floor: "1 Floor"),
		Firm(id: "70000001006524029", name: "Dune London, shoe store", floor: "1 Floor"),
		Firm(id: "70000001033384900", name: "Basketbolista, shop", floor: "2 Floor")
	]

	internal override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationController?.navigationBar.topItem?.title = "Shoe stores"

		self.view.backgroundColor = .white
		self.view.addSubview(self.tableView)

		let margins = self.view.layoutMarginsGuide
		NSLayoutConstraint.activate([
			self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
		])

		if #available(iOS 11, *) {
			let guide = self.view.safeAreaLayoutGuide
			NSLayoutConstraint.activate([
				self.tableView.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.0),
				self.tableView.bottomAnchor.constraintEqualToSystemSpacingBelow(guide.bottomAnchor, multiplier: 1.0),
			])
		} else {
			NSLayoutConstraint.activate([
				self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
				self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
			])
		}
	}

	// MARK:- UITableViewDelegate, UITableViewDataSource

	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.firms.count
	}

	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: FirmListVC.cellReuseId) ?? UITableViewCell()

		if self.firms.indices.contains(indexPath.row) {
			cell.textLabel?.text = self.firms[indexPath.row].name
		}

		return cell
	}

	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let navVC = self.navigationController else { return }
		
		let floorVC = FirmWithFloorVC(firm: self.firms[indexPath.row])
		navVC.pushViewController(floorVC, animated: true)
	}

}
