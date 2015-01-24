app = require('express.io')()
bodyParser = require 'body-parser'
crypto = require 'crypto'
mysql = require 'mysql'
toobusy = require 'toobusy-js'

app.use(bodyParser.json())
app.http().io()

app.use (req, res, next) ->
	res.header 'Access-Control-Allow-Origin', 'http://horcrux.nwsco.org'
	res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept'
	res.header 'Content-Type', 'application/json; charset=utf-8'

	if toobusy()
		res.send 503, 'Overloaded'

	else next()

# ------------------------------------------------------------------

Limiter = require 'express-rate-limiter'
memdb = require 'express-rate-limiter/lib/memoryStore'
limiter = new Limiter db: new memdb()

# ------------------------------------------------------------------

getDB = ->
	connection = mysql.createConnection
		host: ''
		user: ''
		password: ''
		database: ''

	connection.connect (err) -> throw err if err

	connection

genUserID = (ip) ->
	hash = crypto.createHash('md5').update(ip).digest 'hex'
	hash.substring 0, 7

getRowByID = (table, id, cb, ecb) ->
	sql = "
		SELECT * FROM #{table}
		WHERE id = ?
	"

	cn = getDB()
	cn.query sql, [id], (err, result) ->
		return ecb(err) if err
		cb result

	cn.end()

# ------------------------------------------------------------------

app.get '/notes', (req, res) ->
	sql = '
		SELECT n.*, r.* FROM `notes` AS n
		LEFT JOIN (
			SELECT `note_id`, COUNT(*) AS cc
			FROM `replies`
			GROUP BY `note_id`
		) AS r ON n.id = r.note_id
		WHERE (
			n.`title` IS NOT NULL
			AND n.`copy` IS NOT NULL
		)
		ORDER BY n.`createdate` DESC, `cc` DESC
		LIMIT 99
	'

	cn = getDB()
	cn.query sql, (err, rows) ->
		throw err if err

		for _, r of rows
			rows[_].ip = genUserID r.ip

		res.send rows

	cn.end()

app.get '/note/:noteId', (req, res) ->
	getRowByID 'notes', req.params.noteId, (row) ->
		if (row = row[0])?
			row['ip'] = genUserID row.ip

		res.send row

app.get '/note/:noteId/replies', (req, res) ->
	sql = '
		SELECT * FROM `replies`
		WHERE `note_id` = ?
		GROUP BY `createdate`
	'

	cn = getDB()
	cn.query sql, [req.params.noteId], (err, rows) ->
		throw err if err

		for _, r of rows
			rows[_].ip = genUserID r.ip

		res.send rows

	cn.end()

# ------------------------------------------------------------------

app.post '/addNote', limiter.middleware(), (req, res) ->
	sql = '
		INSERT INTO `notes` (title, copy, ip)
		VALUES (?, ?, ?)
	'

	data = {}
	data.title = req.body.title || 'untitled'
	data.copy = req.body.copy || ''
	data.ip = req.connection.remoteAddress || '127.0.0.1'

	console.log 'adding a new note'

	if data.title isnt '' and data.copy isnt ''
		cn = getDB()
		cn.query sql, [data.title, data.copy, data.ip], (err, row) ->
			throw err if err

			getRowByID 'notes', row.insertId, (row) ->
				row[0].ip = genUserID row[0].ip
				req.io.broadcast 'updateHomepage', row[0]

			res.send 200, 'OK'

		cn.end()

	else res.send 503, 'Failed to insert new note'

app.post '/addReply', limiter.middleware(), (req, res) ->
	sql = '
		INSERT INTO `replies` (note_id, copy, ip)
		VALUES (?, ?, ?)
	'

	data = {}
	data.noteId = req.body.noteId
	data.copy = req.body.copy || ''
	data.ip = req.connection.remoteAddress || '127.0.0.1'

	console.log 'adding a new reply to', data.noteId

	cn = getDB()
	cn.query sql, [data.noteId, data.copy, data.ip], (err, row) ->
		return res.send(503, 'nope') if err

		getRowByID 'replies', row.insertId, (row) ->
			if (row = row[0])?
				row['ip'] = genUserID row['ip']
				req.io.broadcast 'updateReplies', row

		res.send 200, 'OK'

	cn.end()

# ------------------------------------------------------------------

app.listen 3000