const SteamTotp = require('steam-totp')
const http = require('http')
const host = '127.0.0.1'
const port = 3330

const requestHandler = (request, response) => {
	if (request.method !== 'POST') {
		request.connection.destroy()
		return
	}

	let body = '';
	request.on('data', (data) => {
		body += data
		if (body.length > 1e6)
			request.connection.destroy()
	})

	request.on('end', () => {
		let data = JSON.parse(body)
		let timeOffset = 0
		if (data.time_indent > 0)
			timeOffset -= data.time_indent * 30

		console.log(data.secret, data.time_indent, timeOffset)
		response.end(SteamTotp.generateAuthCode(data.secret, timeOffset))
	})
}

const server = http.createServer(requestHandler)
server.listen(port, host)

console.log(`server is listening on ${port}`)