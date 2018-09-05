internal struct Response: Codable {
	let result: Result
}

internal struct Result: Codable {
	let items: [Item]
}

internal struct Item: Codable {
	let name: String
	let address_comment: String
}
