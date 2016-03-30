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

"uncomment this if you want to call this function
"every time there is a write operation
"autocmd BufWritePre * :call StripTrailingWhitespace()

let g:basedir = "./"
let g:filetype = "*.cpp,*.h,*py"
python << endpython
#common python functions and globals section 
import vim
from string import ascii_letters, digits
cppSpecialChars = '_'
pySpecialChars = '_'
delimChar = "="
delimLine = delimChar * 80

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

#def getSelectedText():
#    myText = vim.eval("expand('@*')")
#    return myText

def getBaseDir():
    eval_val = int(vim.eval('exists("g:basedir")'))
    if eval_val:
        baseDir = vim.eval("g:basedir")
    else:
        baseDir = "./"
    baseDirLastCharPos = len(baseDir) - 1
    if baseDir[baseDirLastCharPos] != '/' :
        baseDir += "/"
    return baseDir

def getFileTypes():
    eval_val = int(vim.eval('exists("g:filetype")'))
    if eval_val:
        fileType = vim.eval("g:filetype")
    else:
        fileType = "*.cpp,*.h,*.py"
    #fileTypes = fileType.split(',')
    return fileType

def getSelectedText():
    buf = vim.current.buffer
    (row1, col1) = buf.mark('<')
    (row2, col2) = buf.mark('>')
    getLineCmd = 'getline( ' + str(row1) + ', ' + str(row2) + ' )'
    lines = vim.eval(getLineCmd)
    if len(lines) == 1:
        lines[0] = lines[0][col1:col2 + 1]
    else:
        lines[0] = lines[0][col1:]
        lines[-1] = lines[-1][:col2 + 1]
    return "\n".join(lines)

endpython

function! MyFindInH()
python << endpython
import vim
import subprocess

baseDir = getBaseDir()
cCppIdentifier = getCCppIdentifier()
myFileName = getMyFileName()
print("looking in " + baseDir + "*.h files for identifier : " + cCppIdentifier + " ..")
print delimLine
sys.stdout.flush()
command = 'find ' + baseDir + ' -name "*.h" | grep -v ' + myFileName + '| xargs grep ' + cCppIdentifier
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

baseDir = getBaseDir()
cCppIdentifier = getCCppIdentifier()
myFileName = getMyFileName()
print("looking in " + baseDir + "*.cpp files for identifier : " + cCppIdentifier + " ..")
print delimLine
sys.stdout.flush()
command = 'find ' + baseDir + ' -name "*.cpp" | grep -v ' + myFileName + '| xargs grep ' + cCppIdentifier
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

baseDir = getBaseDir()
pyIdentifier = getPyIdentifier()
myFileName = getMyFileName()
print("looking in " + baseDir + "*.py files for identifier : " + pyIdentifier + " ..")
print delimLine
sys.stdout.flush()
command = 'find ' + baseDir + ' -name "*.py" | grep -v ' + myFileName + ' | xargs grep ' + pyIdentifier
popenObj = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
out = popenObj.communicate()
tuplen = len(out)
line = 0
while (line < tuplen):
    print out[line]
    line += 1
endpython
endfunction

function! MyFindSelectedText()
python << endpython
import vim
import sys
import subprocess
import time
import os
import ctypes

selectedText = getSelectedText()
baseDir = getBaseDir()
fileTypes = getFileTypes()
fileTypesList = fileTypes.split(",")
print("looking in " + baseDir + fileTypes + " files for text : " + selectedText + " ..")
sys.stdout.flush()
print(delimLine)
sys.stdout.flush()
fileTypesListLen = len(fileTypesList)
if fileTypesListLen == 1:
    command = 'find ' + baseDir + ' - type f -name "' + fileTypesList[0] + '" | xargs grep "' + selectedText + '"'
else:
    command = 'find ' + baseDir + ' -type f \( '
    for type in range(fileTypesListLen - 1):
        command += ' -name "' +  fileTypesList[type] + '" -or '
    command += ' -name "' + fileTypesList[-1] + '" \)'
    command += ' | xargs grep "' + selectedText + '"'
print "Executing: " + command
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
nmap <F6> :call MyFindSelectedText()<CR>
nmap <F2> :call StripTrailingWhitespace()<CR>
map! <F2> :call StripTrailingWhitespace()<CR>
