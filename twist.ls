#!/usr/bin/env lsc
require!{
	cheerio
	request
	child_process:cp
	readline
}
shows = {}
complete = (line) ->
	matches = Object.keys(shows).filter (s) -> s.toLowerCase().startsWith line.toLowerCase()
	[matches,line]
request "https://twist.moe" (err,res,body) ->
	$ = cheerio.load body
	$(".series-title").each (i,el) -> shows[$(el).text().trim()] = "https://twist.moe#{$(el).attr('href')}"
	console.log "Got titles!!"
rl = readline.createInterface input:process.stdin, output: process.stdout,completer: complete, prompt:"Moe>"
rl.on "line" (line) -> 
	for k in Object.keys(shows)
		if k.toLowerCase() == line.toLowerCase().trim()
			request "#{shows[k]}" (err,res,body) !->
				$ = cheerio.load body
				series = JSON.parse $('#series-object').html()
				for e in series["episodes"]
					console.log "Playing episode #{e['number']}"
					cp.spawnSync "mpv" ["https://twist.moe#{e['source']}"]
rl.on "SIGINT" -> 
	rl.write "Exiiting\n"
	rl.close()
