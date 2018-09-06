import UIKit
import WebKit

internal class FirmWithFloorVC: UIViewController, WKUIDelegate, WKScriptMessageHandler {

	private static let clickName = "clickListener"

	private var firm: Firm

	private lazy var cardView = Bundle.main.loadNibNamed("CardView", owner: self, options: nil)?.first as! CardView
	private lazy var webView: WKWebView = {
		let webConfiguration = WKWebViewConfiguration()
		webConfiguration.dataDetectorTypes = []
		webConfiguration.userContentController.add(self, name: FirmWithFloorVC.clickName)

		let view = WKWebView(frame: .zero, configuration: webConfiguration)
		view.uiDelegate = self
		view.scrollView.showsVerticalScrollIndicator = false

		return view
	}()


	internal init(firm: Firm) {
		self.firm = firm

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	internal required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	internal override func loadView() {
		super.loadView()

		self.view.addSubview(self.webView)
		self.view.addSubview(self.cardView)
		self.view.backgroundColor = .white

		self.cardView.translatesAutoresizingMaskIntoConstraints = false
		self.webView.translatesAutoresizingMaskIntoConstraints = false

		let margins = self.view.layoutMarginsGuide
		NSLayoutConstraint.activate([
			self.webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			self.webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
			self.cardView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			self.cardView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
			self.cardView.heightAnchor.constraint(equalTo: self.webView.heightAnchor, multiplier: 0.25),
		])

		if #available(iOS 11, *) {
			let guide = self.view.safeAreaLayoutGuide
			NSLayoutConstraint.activate([
				self.webView.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.0),
				self.webView.bottomAnchor.constraintEqualToSystemSpacingBelow(self.cardView.topAnchor, multiplier: 1.0),
				self.cardView.bottomAnchor.constraintEqualToSystemSpacingBelow(guide.bottomAnchor, multiplier: 1.0),
			])
		} else {
			NSLayoutConstraint.activate([
				self.webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
				self.webView.bottomAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 0),
				self.cardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
			])
		}

		self.cardView.layer.shadowColor = UIColor.black.cgColor
		self.cardView.layer.shadowOpacity = 0.1
		self.cardView.layer.shadowOffset = CGSize.zero
		self.cardView.layer.shadowRadius = 2
		self.cardView.layer.masksToBounds = false
	}

	internal override func viewDidLoad() {
		super.viewDidLoad()

		let url = Bundle.main.url(forResource: "WidgetParams", withExtension: "html")!
		var html = String(data: try! Data(contentsOf: url), encoding: .utf8)!
		html = html.replacingOccurrences(of: "INITIAL_FIRM_ID", with: self.firm.id)

		self.webView.loadHTMLString(html, baseURL: nil)

		self.cardView.titleLabel.text = self.firm.name
		self.cardView.floorLabel.text = self.firm.floor
	}

	// MARK:- WKScriptMessageHandler

	internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard message.name == FirmWithFloorVC.clickName,
			let id = (message.body as? [String])?.first else { return }

		print(message.body)
		self.fetchFirmName(for: (id)) {
			[weak self] firm in
			guard let this = self else { return }
			let firm = firm ?? Firm(id: id, name: "Test name", floor: "1 Floor")

			this.firm = firm
			this.cardView.titleLabel.text = firm.name
			this.cardView.floorLabel.text = firm.floor
		}
	}

	// MARK:- Private

	private func fetchFirmName(for id: String, queue: DispatchQueue = .main, completion: @escaping (Firm?) -> ()) {
		guard let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "Catalog Api Key") as? String
			else {
				print("Coudn't find 'Catalog Api Key' param in Info.plist")
				return
		}

		guard let url = URL(string: "http://catalog.api.2gis.ru/2.0/catalog/branch/get?id=\(id)&key=\(apiKey)") else { return }

		URLSession.shared.dataTask(with: url) {
			data, response, error in

			guard error == nil else {
				print(error?.localizedDescription ?? "Error is nil")
				queue.async { completion(nil) }
				return
			}

			guard let data = data else {
				print("Data is nil")
				queue.async { completion(nil) }
				return
			}

			do {
				let response = try JSONDecoder().decode(Response.self, from: data)

				queue.async {
					let name = response.result.items[0].name
					let floor = response.result.items[0].address_comment

					let firm = Firm(id: id, name: name, floor: floor)
					completion(firm)
				}

			} catch let jsonError {
				print(jsonError)
				queue.async { completion(nil) }
				return
			}
		}.resume()
	}
}
