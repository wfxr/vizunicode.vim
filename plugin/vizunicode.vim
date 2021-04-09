if exists('b:loaded_vizunicode')
    finish
endif
let b:loaded_vizunicode = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:VizUnicode() range abort
    setlocal conceallevel=1
    for l:ln in range(a:firstline, a:lastline)
        if get(g:, 'vizunicode_nr2char', 0)
            let code = matchstr(getline(l:ln), '\mnr2char(\s*\zs\S\+\ze\s*)')
            if strlen(code)
                execute 'silent! syntax match VizUnicode /\mnr2char(\s*' . code . '\s*)/hs=s+8,he=e-1 containedin=ALL conceal cchar=' . nr2char(code)
            endif
        endif
        let code = matchstr(getline(l:ln), '\m\c\\u\zs\x\+\ze')
        if strlen(code)
            execute 'silent! syntax match VizUnicode /\m\c\\u' . code . '/ containedin=ALL conceal cchar=' . nr2char(str2nr(code, 16))
        endif
    endfor
endfunction

function! s:VizUnicodeAll() abort
    let currln = line('.')
    let currcol = col('.')
    1,$call s:VizUnicode()
    call cursor(currln, currcol)
endfunction

" define commands
command! -nargs=0 -range -bang VizUnicode      :<line1>,<line2>call <SID>VizUnicode()
command! -nargs=0        -bang VizUnicodeAll   :call <SID>VizUnicodeAll()
command! -nargs=0        -bang VizUnicodeClear :silent! syntax clear VizUnicode

" define keymappings
nnoremap <buffer><unique><silent> <Plug>(VizUnicodeNormal) :<C-u>VizUnicode<CR>
xnoremap <buffer><unique><silent> <Plug>(VizUnicodeVisual) :<C-u>'<,'>VizUnicode<CR>
noremap  <buffer><unique><silent> <Plug>(VizUnicodeClear)  :<C-u>VizUnicodeClear<CR>
nnoremap <buffer><unique><silent> <Plug>(VizUnicodeAll)    :<C-u>VizUnicodeAll<CR>

for [name, keys, kmode] in [
            \ ['Normal', 'vn', 'n'],
            \ ['Visual', 'vn', 'x'],
            \ ['Clear',  'vc', ''],
            \ ['All',    'va', 'n'],
            \]
    let fullname = '<Plug>(VizUnicode' . name . ')'
    if !hasmapto(fullname) && empty(maparg('<leader>' . keys, kmode))
        call execute('' . kmode . 'map <buffer> <unique> <leader>' . keys . ' ' . fullname)
    endif
endfor

let &cpoptions = s:save_cpo
unlet s:save_cpo

if get(g:, 'vizunicode_auto', 0)
    VizUnicodeAll
endif
