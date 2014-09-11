internal1 = () ->
	fn = () ->
		console.log 'INTERNAL1'
	caller()
	return

internal2 = () ->
	fn = () ->
		console.log 'INTERNAL2'
	caller()

caller = () ->
	fn()

internal1()
internal2()
