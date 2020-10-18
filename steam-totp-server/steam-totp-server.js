const SteamTotp = require('steam-totp')
const http = require('http')
const host = '127.0.0.1'
const port = 3000

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

	request.on('end', () => response.end(SteamTotp.generateAuthCode(body)))
}

const server = http.createServer(requestHandler)
server.listen(port, host)

console.log(`server is listening on ${port}`)