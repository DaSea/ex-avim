" Copyright (c) 1998-2017
" DaSea <dhf0214@126.com>
" Refer to a.vim

if exists("loaded_alternateFile")
    finish
endif

if (v:progname == "ex")
    finish
endif
let loaded_alternateFile = 1

let g:alternateExtensionsDict = {}


" This variable will be increased when an extension with greater number of dots
" is added by the AddAlternateExtensionMapping call.
let s:maxDotsInExtension = 1

"  源文件与头文件的字典内容 {{{
"  the context of source and header file
" Function : AddAlternateExtensionMapping (PRIVATE)
" Purpose  : simple helper function to add the default alternate extension
"            mappings.
" Args     : extension -- the extension to map
"            alternates -- comma separated list of alternates extensions
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
function! <SID>AddAlternateExtensionMapping(extension, alternates)
    let g:alternateExtensionsDict[a:extension] = a:alternates
    " 将extension之中的所有.之外的字符去掉,算出.的个数
    let dotsNumber = strlen(substitute(a:extension, "[^.]", "", "g"))
    if s:maxDotsInExtension < dotsNumber
        let s:maxDotsInExtension = dotsNumber
    endif
endfunction


" Add all the default extensions
" Mappings for C and C++
call <SID>AddAlternateExtensionMapping('h',"c,cpp,cxx,cc,CC")
call <SID>AddAlternateExtensionMapping('H',"C,CPP,CXX,CC")
call <SID>AddAlternateExtensionMapping('hpp',"cpp,c")
call <SID>AddAlternateExtensionMapping('HPP',"CPP,C")
call <SID>AddAlternateExtensionMapping('c',"h")
call <SID>AddAlternateExtensionMapping('C',"H")
call <SID>AddAlternateExtensionMapping('cpp',"h,hpp")
call <SID>AddAlternateExtensionMapping('CPP',"H,HPP")
call <SID>AddAlternateExtensionMapping('cc',"h")
call <SID>AddAlternateExtensionMapping('CC',"H,h")
call <SID>AddAlternateExtensionMapping('cxx',"h")
call <SID>AddAlternateExtensionMapping('CXX',"H")
" Mappings for PSL7
call <SID>AddAlternateExtensionMapping('psl',"ph")
call <SID>AddAlternateExtensionMapping('ph',"psl")
" Mappings for ADA
call <SID>AddAlternateExtensionMapping('adb',"ads")
call <SID>AddAlternateExtensionMapping('ads',"adb")
" Mappings for lex and yacc files
call <SID>AddAlternateExtensionMapping('l',"y,yacc,ypp")
call <SID>AddAlternateExtensionMapping('lex',"yacc,y,ypp")
call <SID>AddAlternateExtensionMapping('lpp',"ypp,y,yacc")
call <SID>AddAlternateExtensionMapping('y',"l,lex,lpp")
call <SID>AddAlternateExtensionMapping('yacc',"lex,l,lpp")
call <SID>AddAlternateExtensionMapping('ypp',"lpp,l,lex")
" Mappings for OCaml
call <SID>AddAlternateExtensionMapping('ml',"mli")
call <SID>AddAlternateExtensionMapping('mli',"ml")
" ASP stuff
call <SID>AddAlternateExtensionMapping('aspx.cs', 'aspx')
call <SID>AddAlternateExtensionMapping('aspx.vb', 'aspx')
call <SID>AddAlternateExtensionMapping('aspx', 'aspx.cs,aspx.vb')
" }}}

" Setup default search path, unless the user has specified
" a path in their [._]vimrc.
if (!exists('g:alternateSearchPath'))
    let g:alternateSearchPath = "/usr/include"
endif

" 在当前目录下查找文件 {{{
" Find src or header file in current path
function! FindFileInCurrentPath(path, baseName, extension)
    let extSpec = ""
    if (has_key(g:alternateExtensionsDict, a:extension))
        " 对于h, 为c,cpp,cxx,cc,CC等
        let extSpec = g:alternateExtensionsDict[a:extension]
    endif

    if (extSpec != "")
        let n = 1
        let done = 0
        while (!done)
            " 获取第几个对应的扩展名
            " 分局逗号对字符串进行分割, 并获取第n个
            " let ext = <SID>GetNthItemFromList(extSpec, n)
            let ext = ex#string#sub_by_index(extSpec, ",", n)
            if (ext != "")
                if (a:path != "")
                    let newFilename = a:path . "/" . a:baseName . "." . ext
                endif

                " 如果文件存在的话则直接返回
                if (newFilename != "")
                    if (filereadable(newFilename) || (1 == filewritable(newFilename)))
                        return newFilename
                    endif
                endif
            else
                let done = 1
            endif
            let n = n + 1
        endwhile
    endif
    return ""
endfunction "}}}

" 在工程根目录下查找对应文件{{{
" Find src or header file in root path
function! FindFileInPrjPath(path, baseName, extension) abort
    let prjRoot = ex#path#root(a:path)
    if ("" == prjRoot)
        return ""
    endif
    silent! echomsg prjRoot

    let extSpec = ""
    if (has_key(g:alternateExtensionsDict, a:extension))
        " 对于h, 为c,cpp,cxx,cc,CC等
        let extSpec = g:alternateExtensionsDict[a:extension]
    endif

    if (extSpec != "")
        let n = 1
        let done = 0
        let findFile = ""
        while (!done)
            " 获取第几个对应的扩展名
            " 分局逗号对字符串进行分割, 并获取第n个
            " let ext = <SID>GetNthItemFromList(extSpec, n)
            let ext = ex#string#sub_by_index(extSpec, ",", n)
            if (ext != "")
                let newFilename = a:baseName . "." . ext
                let filelist = ex#path#find_file(prjRoot, newFilename)
                if !empty(filelist)
                    return get(filelist, 0)
                endif
            else
                let done = 1
            endif
            let n = n + 1
        endwhile
    endif
    return ""
endfunction
function! FindFileInPrjPathEX(path, fileName) abort
    let prjRoot = ex#path#root(a:path)
    if ("" == prjRoot)
        return ""
    endif

    " 获取第几个对应的扩展名
    " 分局逗号对字符串进行分割, 并获取第n个
    let filelist = ex#path#find_file(prjRoot, a:fileName)
    if !empty(filelist)
        return get(filelist, 0)
    endif

    return ""
endfunction "}}}

" 在用户设置的路径里面查找文件 {{{
" Find file in the specified path
function! FindFileInSearchPath(fileName) abort
    if "" == g:alternateSearchPath
        echomsg "No specified path!"
        return ""
    endif

    " Check path
    if 0 == ex#path#validity(g:alternateSearchPath)
        return ""
    endif

    silent! echomsg "Search path: " . g:alternateSearchPath
    let filelist = ex#path#find_file(g:alternateSearchPath, a:fileName)
    if !empty(filelist)
        return get(filelist, 0)
    endif

    return ""
endfunction " }}}

" Function : DetermineExtension (PRIVATE) {{{
" Purpose  : Determines the extension of a filename based on the register
"            alternate extension. This allow extension which contain dots to
"            be considered. E.g. foo.aspx.cs to foo.aspx where an alternate
"            exists for the aspx.cs extension. Note that this will only accept
"            extensions which contain less than 5 dots. This is only
"            implemented in this manner for simplicity...it is doubtful that
"            this will be a restriction in non-contrived situations.
" Args     : The path to the file to find the extension in
" Returns  : The matched extension if any
" Author   : Michael Sharpe (feline@irendi.com)
" History  : idea from Tom-Erik Duestad
" Notes    : there is some magic occuring here. The exists() function does not
"            work well when the curly brace variable has dots in it. And why
"            should it, dots are not valid in variable names. But the exists
"            function is wierd too. Lets say foo_c does exist. Then
"            exists("foo_c.e.f") will be true...even though the variable does
"            not exist. However the curly brace variables do work when the
"            variable has dots in it. E.g foo_{'c'} is different from
"            foo_{'c.d.e'}...and foo_{'c'} is identical to foo_c and
"            foo_{'c.d.e'} is identical to foo_c.d.e right? Yes in the current
"            implementation of vim. To trick vim to test for existence of such
"            variables echo the curly brace variable and look for an error
"            message.
"            path: 完整路径
function! DetermineExtension(path)
    let mods = ":t"
    let i = 0
    " i < 0代表有扩展
    while i <= s:maxDotsInExtension
        let mods = mods . ":e"
        " path 是一个完整路径
        " fnamemodify 根据modes修改文件名 , 和expand 一样
        let extension = fnamemodify(a:path, mods)
        " 如果扩展名已经在字典中则返回
        if (has_key(g:alternateExtensionsDict, extension))
            return extension
        endif
        let i = i + 1
    endwhile
    return ""
endfunction "}}}

" 找到并打开对应的文件 {{{
function! AlternateOppositeFile(splitWindow, ...)
    " expand("%:p")完整路径, t: 文件名.
    " 例如: 当前文件 avim.vim
    " %:p -> C:\Develop\exVim\vimfiles\plugged\ex-avim\plugin\avim.vim
    " %:p:h -> C:\Develop\exVim\vimfiles\plugged\ex-avim\plugin
    " %:t -> avim.vim
    " %:t:e -> vim
    " 判断对应文件的扩展名是否在字典中
    let extension   = DetermineExtension(expand("%:p"))
    if (extension == "")
        silent! echomsg "no extension!"
        return
    endif

    " 获取avim, substitute将里面的.vim(.扩展名)去掉
    let baseName    = substitute(expand("%:t"), "\." . extension . '$', "", "")
    let currentPath = expand("%:p:h")

    " 如果参数个数不为0的话
    if (a:0 != 0)
        " 可以自定义扩展名, 根据当前头文件
        let newFullname = currentPath . "/" .  baseName . "." . a:1
        call ex#buffer#find_or_create(newFullname, a:splitWindow, 0)
    else
        let oppositeFile = ""
        if (extension != "")
            let oppositeFile = FindFileInCurrentPath(currentPath, baseName, extension)
            if (oppositeFile == "")
                let oppositeFile = FindFileInPrjPath(currentPath, baseName, extension)
            endif

        endif

        if (oppositeFile != "")
            " find and create buffer
            call ex#buffer#find_or_create(oppositeFile, a:splitWindow, 1)
        else
            echo "No alternate file available!"
        endif
    endif
endfunction " }}}

" Function : AlternateOpenFileUnderCursor (PUBLIC) {{{
" Purpose  : Opens file under the cursor
" Args     : splitWindow -- indicates how to open the file
" Returns  : Nothing
" Author   : Michael Sharpe (feline@irendi.com) www.irendi.com
function! AlternateOpenFileUnderCursor(splitWindow,...)
    let cursorFile = (a:0 > 0) ? a:1 : GetGoToFile()
    let currentPath = expand("%:p:h")

    let fileName = FindFileInPrjPathEX(currentPath, cursorFile)
    silent! echomsg "The current find file: ".fileName
    if ("" == fileName)
        let fileName = FindFileInSearchPath(cursorFile)
        silent! echomsg "The current find file: " . fileName
    endif

    if (fileName != "")
        call ex#buffer#find_or_create(fileName, a:splitWindow, 1)
    else
        echo "Can't find file!"
    endif
endfunction "}}}

" 定义命令(define command) {{{
comm! -nargs=? -bang IH call AlternateOpenFileUnderCursor("n<bang>", <f-args>)
comm! -nargs=? -bang IHS call AlternateOpenFileUnderCursor("h<bang>", <f-args>)
comm! -nargs=? -bang IHV call AlternateOpenFileUnderCursor("v<bang>", <f-args>)
comm! -nargs=? -bang IHT call AlternateOpenFileUnderCursor("t<bang>", <f-args>)
inoremap <Leader>fh <ESC>:IH<CR>
nnoremap <Leader>fh :IH<CR>

" 头文件与源文件切换
comm! -nargs=? -bang A call AlternateOppositeFile("n<bang>", <f-args>)
comm! -nargs=? -bang AS call AlternateOppositeFile("h<bang>", <f-args>)
comm! -nargs=? -bang AV call AlternateOppositeFile("v<bang>", <f-args>)
comm! -nargs=? -bang AT call AlternateOppositeFile("t<bang>", <f-args>)
" }}}

" Get the file name in current line{{{
function! GetGoToFile() abort
    " get current line context, and get file
    let curLine = getline(line('.'))
    let curLine = substitute(curLine, "\\", "\/", "g")
    silent! echomsg curLine

    " get the filename-> a, a.h
    " #include <d/a.h> #include <a.h> #include <a>
    " #include "d/a.h" #include "a.h" #include "a"
    let filename = matchstr(curLine, '\(<\|\"\|\/\)\{1}\w\+\.\?h\?\(\"\|>\)', 8)
    let filename = matchstr(filename, '\w\+\.\?h\?')

    return filename
endfunction "}}}
