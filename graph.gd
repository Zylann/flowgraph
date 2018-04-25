
var _items = []
var _links = {}


func add_item(item):
	_items.append(item)


func remove_item(item):
	if _links.has(item):
		var link = _links[item]
		for other_item in link:
			if _links.has(other_item):
				var opposite_link = _links[other_item]
				opposite_link.erase(item)
	_items.erase(item)


func add_link(from, to, both=false):
	if _links.has(from):
		var from_links = _links[from]
		if from_links.has(to):
			print("Destination already contained")
			return
		from_links.append(to)
	else:
		_links[from] = [to]
	if both:
		add_link(to, from, false)


func remove_link(from, to, both=false):
	if _links.has(from):
		var from_links = _links[from]
		from_links.erase(to)
	if both:
		remove_link(to, from, false)


func get_links(from):
	return _links[from]

