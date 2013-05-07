passwdgen = new PasswdGenerator

chromeext = null

is_chromeext = ->
	if chromeext == null
		chromeext = $('#chromeext').length != 0
	chromeext

notify = (msg) ->
	$('#info').html(msg).show().hide(1500)

debug_on = ->
	$('#dbg').is ':checked'

debug = (msg) ->
	if debug_on()
		$('#dbginfo').append('<p>' + msg + '</p>')

verbose = (msg) ->
	$('#dbginfo').append('<p>' + msg + '</p>')

toggle_debug = ->
	$('#dbginfo').html ''

derive_key_compute_hook = (i) ->
	if i == (1<<8) - 1
		notify 'Key derived'

gather_input = ->
	{
		email: $('#email').val()
		passphrase: $('#passphrase').val()
		itercnt: 1 << Number($('#hashes').val())
		site: $('#site').val()
		generation: $('#generation').val()
		num_symbol: Number($('#num_symbol').val())
		length: Number($('#length').val())
		compute_hook: derive_key_compute_hook
	}

email_update = ->
	if is_chromeext()
		localStorage.email = $('#email').val()
	return

gen_passwd = ->
	if $('#site').val() == ''
		$('#passwd').val ''
		return
	p = passwdgen.generate gather_input()
	$('#passwd').val p
	return

host_is_ip = (host) ->
	parts = host.split '.'
	if parts.length != 4
		return false
	for pt in parts
		if pt.length == 0 || pt.length > 3
			return false
		n = Number(pt)
		if isNaN(n) || n < 0 || n > 255
			return false
	return true

top_level_dm =
	net: true
	org: true
	edu: true
	com: true
	ac: true
	co: true

parse_hostname = (url) ->
	a = document.createElement('a')
	a.href = url
	return a.hostname

host2domain = (host) ->
	if host_is_ip host
		return '' # IP address has no domain
	lastDot = host.lastIndexOf '.'
	if lastDot == -1
		return '' # simple host name has no domain

	parts = host.split '.'
	n = parts.length
	if n > 2 && top_level_dm[parts[n-2]]
		return parts[n-3..n-1].join '.'
	return parts[n-2..n-1].join '.'

parse_site = (url) ->
	if url.substr(0, 9) == 'chrome://'
		return ''
	if url.substr(0, 7) == 'file://'
		return ''
	host2domain(parse_hostname url)

ui_init = ->
	if is_chromeext() && localStorage.email? && localStorage.email != ''
		$('#email').val localStorage.email

# export functions
window.toggle_debug = toggle_debug
window.email_update = email_update
window.gen_passwd = gen_passwd
window.parse_site = parse_site
window.ui_init = ui_init
