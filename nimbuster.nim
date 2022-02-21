# Copied the file name and parts of the code from https://github.com/mttaggart/nimbuster
# Check out his stream at https://www.twitch.tv/mttaggart

import std/[
    strformat, 
    httpclient,
    threadpool,
    strutils,
    sequtils,
    net
]
import termstyle

const
  termInfo* = "\e[37m[\u2139] "
  termSuccess* = "\e[32m[\u2713] "
  termWarn* = "\e[33m[\u26A0] "
  termError* = "\e[31m[\u2717] "
  
template addEnd(ss: varargs[string, `$`]): untyped =
  for s in ss:
    result &= s
  result &= termClear
  
proc info*(ss: varargs[string, `$`]): string =
  ## Prepends info symbol and colors text white
  result = termInfo
  addEnd(ss)

proc success*(ss: varargs[string, `$`]): string =
  ## Prepends success symbol and colors text green
  result = termSuccess
  addEnd(ss)

proc warning*(ss: varargs[string, `$`]): string =
  ## Prepends warning symbol and colors text yellow
  result = termWarn
  addEnd(ss)
  
proc error*(ss: varargs[string, `$`]): string =
  ## Prepends error symbol and colors text red
  result = termError
  addEnd(ss)

# Define Types
type ThreadResponse = tuple[code: HttpCode, word: string, done: bool]

proc request(url: string, words: seq[string], channel: ptr Channel[ThreadResponse]) =
    let client: HttpClient = newHttpClient(sslContext=newContext(verifyMode=CVerifyNone))
    
    for i, w in words:
        let status_code = client.get(&"{url}/{w}").code()
        let done = i == words.len - 1
        channel[].send((status_code, w, done))

proc nimbust*(url, wordlist: string, threads: Natural, codes: seq[HttpCode] = @[Http200, Http301, Http302]): seq[string]  =
    
    var wordsdiscovered = newSeq[string]()
    
    # Assign actual number of threads
    var numThreads = threads

    # Initialize wordCount value
    var wordCount: int

    # Get the wordlist
    # Divide it amongst the threads
    let f: File = open(wordlist)
    let words: seq[seq[string]] = block:
    # TODO: does lines() actually work?
        let ws = readAll(f)
        .splitLines()
        .filterIt(
            not(it.startsWith("#")) and it != ""
        )
        wordCount = ws.len
        # Account for edge case where wordlist is smaller than threads
        if numThreads > wordCount:
            numThreads = wordCount
        ws.distribute(numThreads)
    f.close()
     
    var complete: int = 0

    # Build out some channels
    var channels = newSeq[Channel[ThreadResponse]](numThreads)

    # Open channels
    for i, _ in channels:
        open(channels[i])

    # Spawn threads w/ channels
    for t in 0..<numThreads:
        spawn request(url, words[t], channels[t].addr)

    # Track all the statuses (stati?)
    var status = newSeq[bool](numThreads)
    var completeStatus = 0
    # Startup info

    echo info "Starting enumeration..."
    echo info &"URL: {url}"
    echo info &"Wordlist: {wordlist}"
    echo info &"Threads: {numThreads}"
    # Main Loop
    while true:
        for i in 0..<numThreads:
            let r = channels[i].tryRecv()

            # Write out results
            if r.dataAvailable:
                complete += 1

                # Check complete percentage
                let completePct = ((complete / wordCount) * 100).toInt
                
                # Check for previously unknown complete status
                if completeStatus != completePct:
                    # Update status
                    completeStatus = completePct
                    # Print out every 10%
                    if completePct mod 10 == 0 and completePct > 0:
                        echo info &"Status: {completePct}% complete"

                if r.msg.code in codes:
                    echo success &"{r.msg.code}: /{r.msg.word}"
                    wordsdiscovered.add(r.msg.word)

            
                # Update status
                status[i] = r.msg.done
        
        # Check if we're all done...literally
        if status.allIt(it):
            break
    
    for i, _ in channels:
        close(channels[i])

    echo success "Wordlist completed"
    return wordsdiscovered
