set ts=4
set et
set sw=4
set softtabstop=4
syntax on
filetype indent on
au BufNewFile,BufRead SCons* set filetype=scons

let Python2Syntax = 1
let python_highlight_all = 1

function! StripTrailingWhitespace()
    normal mZ
    let l:chars = col("$")
    %s/\s\+$//e
    if (line("'Z") != line(".")) || (l:chars != col("$"))
        echo "Trailing whitespace stripped\n"
    endif
    normal `Z
endfunction

"autocmd BufWritePre * :call StripTrailingWhitespace()

python << endpython
#common python functions and globals section 
import vim
from string import ascii_letters, digits
cppSpecialChars = '_'
pySpecialChars = '_'

def getCCppIdentifier():
    (row, col) = vim.current.window.cursor
    line = vim.current.buffer[row-1] # 0 vs 1 based
    maxCol = len(line)
    i = col
    retVal = ""
    while ((i > 1) and (line[i] in (ascii_letters + digits + cppSpecialChars))):
            i -= 1
    i += 1
    while ((i< maxCol) and (line[i] in (ascii_letters + digits + cppSpecialChars))):
        retVal += line[i]
        i += 1
    return retVal

def getPyIdentifier():
    (row, col) = vim.current.window.cursor
    line = vim.current.buffer[row-1] # 0 vs 1 based
    maxCol = len(line)
    i = col
    retVal = ""
    while ((i > 1) and (line[i] in (ascii_letters + digits + pySpecialChars))):
            i -= 1
    i += 1
    while ((i< maxCol) and (line[i] in (ascii_letters + digits + pySpecialChars))):
        retVal += line[i]
        i += 1
    return retVal

def getMyFileFullName():
    myName = vim.eval("expand('%:p')")
    return myName

def getMyFileName():
    myName = vim.eval("expand('%:t')")
    return myName

def getSelectedText():
    myText = vim.eval("expand('@*')")
    return myText

endpython

function! MyFindInH()
python << endpython
import vim
import subprocess

cCppIdentifier = getCCppIdentifier()
myFileName = getMyFileName()
print("looking in .h files for identifier : " + cCppIdentifier + " ..")
command = 'find . -name "*.h" | grep -v ' + myFileName + '| xargs grep ' + cCppIdentifier
popenObj = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
out = popenObj.communicate()
tuplen = len(out)
line = 0
while (line < tuplen):
    print out[line]
    line += 1
endpython
endfunction

function! MyFindInCpp()
python << endpython
import vim
import subprocess

cCppIdentifier = getCCppIdentifier()
myFileName = getMyFileName()
print("looking in .cpp files for identifier : " + cCppIdentifier + " ..")
command = 'find . -name "*.cpp" | grep -v ' + myFileName + '| xargs grep ' + cCppIdentifier
popenObj = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
out = popenObj.communicate()
tuplen = len(out)
line = 0
while (line < tuplen):
    print out[line]
    line += 1
endpython
endfunction

function! MyFindInPy()
python << endpython
import vim
import subprocess

pyIdentifier = getPyIdentifier()
myFileName = getMyFileName()
print("looking in .py files for identifier : " + pyIdentifier + " ..")
command = 'find . -name "*.py" | grep -v ' + myFileName + ' | xargs grep ' + pyIdentifier
popenObj = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
out = popenObj.communicate()
tuplen = len(out)
line = 0
while (line < tuplen):
    print out[line]
    line += 1
endpython
endfunction

nmap <F3> :call MyFindInH()<CR>
nmap <F4> :call MyFindInCpp()<CR>
nmap <F5> :call MyFindInPy()<CR>
nmap <F2> :call StripTrailingWhitespace()<CR>
map! <F2> :call StripTrailingWhitespace()<CR>
