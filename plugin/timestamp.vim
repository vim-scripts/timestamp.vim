" TimeStamp 1.16: Vim plugin for automated time stamping.
" Maintainor:		Gautam Iyer <gautam@math.uchicago.edu>
" Created:		Fri 06 Feb 2004 02:46:27 PM CST
" Last Modified:	Fri 17 Sep 2004 09:52:38 PM CDT
" License:		This file is placed in the public domain.
"
" Credits:		Thanks to Guido Van Hoecke for writing the original
"			vim script "timstamp.vim".
" Discription:
"   When a file is written, and the filename matches "timestamp_automask",
"   this plugin will search the first and last "timestamp_modelines" lines of
"   your file. If it finds the regexp "timestamp_regexp" then it will replace
"   it with a timestamp. The timestamp is computed by first doing a
"   "token_substitution" on "timestamp_rep" and passing the result to
"   "strftime()". See the documentation for details.

" provide load control
if exists("loaded_timestamp")
    finish
endif
let loaded_timestamp = 1

let s:cpo_save = &cpo
set cpo&vim		" line continuation is used

function s:getValue(deflt, globl, ...)
    " helper function to define script variables by using first any specified
    " global value, any non zero value from the optional parameters, and
    " finally if all these fail to provide a value, by using the default value
    if exists(a:globl)
	let work = "let value = " . a:globl
	exe work
	return value
    endif

    let indx = 1
    while indx <= a:0
	let work = "let value = a:" . indx
	exe work
	if value != ""
	    return value
	endif
	let indx = indx + 1
    endwhile
   
    " use default
    return a:deflt 
endfunction

" Default timestamp expressions
let s:timestamp_regexp = s:getValue('\v\C%(<Last %([cC]hanged?|[mM]odified)\s*:\s+)@<=\a+ \d{2} \a+ \d{4} \d{2}:\d{2}:\d{2} [AP]M ?%(\a+)?|TIMESTAMP', 'g:timestamp_regexp')

" %c seems to be different on different systems. Use a full form instead.
let s:timestamp_rep = s:getValue('%a %d %b %Y %I:%M:%S %p %Z', 'g:timestamp_rep')

" Plugin Initialisations.
let s:automask	= s:getValue( '*', 'g:timestamp_automask')
let s:modelines	= s:getValue( &modelines, 'g:timestamp_modelines')

" Get hostname
let s:Hostname	= system('hostname -f | tr -d "\n"')
let s:Hostname	= s:getValue( hostname(), 'g:timestamp_hostname', v:shell_error ? '' : s:Hostname, $HOSTNAME)
let s:hostname	= s:getValue( substitute( s:Hostname, '\..*', '', ''), 'g:timestamp_hostname')

" Get username
let s:username	= system( 'id -un | tr -d "\n"')
if v:shell_error
    let s:username = 'unknown'
endif
let s:username	= s:getValue( s:username, 'g:timestamp_username', $USER, $LOGNAME)

" Get userid
let s:userid	= system( 'id -u | tr -d "\n"')
if v:shell_error && s:username != 'unknown'
    let s:userid = system( 'grep ' . s:username . ' /etc/passwd | cut -f 3 -d : | tr -d "\n"')
    if v:shell_error
	let uid = 'unknown'
    endif
endif
let s:userid	= s:getValue( s:userid, 'g:timestamp_userid')

if has('autocmd')
    let s:autocomm   = "autocmd BufWrite " . s:automask . " :call s:timestamp()"
    augroup TimeStamp
	" this autocommand triggers the update of the requested timestamps
	au!
	exec s:autocomm
    augroup END
else
    echoerr 'Autocommands not enabled. Timestamping will not work'
endif

" Free up memory and delete unused functions / variables
delfunction s:getValue
unlet s:autocomm
unlet s:automask

" Function that does the timestamping
function s:timestamp()
   " Get buffer local patterns -- overriding global ones.
    let   pat	   = exists("b:timestamp_regexp")	? b:timestamp_regexp	: s:timestamp_regexp
    let   rep	   = exists("b:timestamp_rep")		? b:timestamp_rep	: s:timestamp_rep
    let l:hostname = exists("b:timestamp_hostname")	? b:timestamp_hostname	: s:hostname
    let l:Hostname = exists("b:timestamp_Hostname")	? b:timestamp_Hostname	: s:Hostname
    let l:username = exists("b:timestamp_username")	? b:timestamp_username	: s:username
    let l:userid   = exists("b:timestamp_userid")	? b:timestamp_userid	: s:userid

    " Process the replacement pattern
    let rep = strftime(rep)
    let rep = substitute(rep, '\C#f', expand("%:p:t"), "g")
    let rep = substitute(rep, '\C#h', l:hostname, "g")
    let rep = substitute(rep, '\C#H', l:Hostname, "g")
    let rep = substitute(rep, '\C#u', l:username, "g")
    let rep = substitute(rep, '\C#i', l:userid,   "g")

    " Escape forward slashes
    let pat = escape(pat, '/')
    let rep = escape(rep, '/')

    " Get ranges for timestamp to be located
    let l:modelines = exists("b:timestamp_modelines") ? b:timestamp_modelines : s:modelines
    let l:modelines = (l:modelines == '%') ? line('$') : l:modelines

    if line('$') > 2 * l:modelines
	call s:subst(1, l:modelines, pat, rep)
	call s:subst(line('$') + 1 - l:modelines, line('$'), pat, rep)
    else
	call s:subst(1, line('$'), pat, rep)
    endif
endfunction

function s:subst(start, end, pat, rep)
    let lineno = a:start
    while lineno <= a:end
	let curline = getline(lineno)
	if match(curline, a:pat) != -1
	    call setline(lineno, substitute(curline, a:pat, a:rep, ''))
	endif
	let lineno = lineno + 1
    endwhile
endfunction

" Restore compatibility options
let &cpo = s:cpo_save
