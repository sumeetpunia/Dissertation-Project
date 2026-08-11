(* tailer.sml *)

structure Tailer =
struct
  open EventTypes
  open DataLogger
  open PolicyRules
  open AnomalyDetection
  open MLAnomaly
  open AlertEngine
  open VisualExport

  (* ⬇️ These are now refs, so we can update them dynamically *)
  val csvPath = ref "events.csv"
  val jsonlPath = ref "events.jsonl"

  fun stripBOM s =
    if String.size s >= 3 andalso String.substring(s,0,3) = "\239\187\191" then
      String.substring(s,3, String.size s - 3)
    else s

  fun dropWhile p [] = []
    | dropWhile p (x::xs) = if p x then dropWhile p xs else x::xs

  (* parse one json line and extract action/path/folder/time *)
  fun parseLine line =
    let val ln = String.implode(dropWhile (fn c => c = #" " orelse c = #"\t" orelse c = #"\n" orelse c = #"\r") (String.explode (stripBOM line)))
        val action = EventTypes.extractField(ln, "action")
        val path = EventTypes.extractField(ln, "path")
        val folder = EventTypes.extractField(ln, "folder")
        val timestr = EventTypes.extractField(ln, "time")
    in (timestr, action, path, folder) end

  (* process a JSON line: log, update anomaly counters, print alerts *)
  fun processLine line =
    let
      val (timestr, action, path, folder) = parseLine line
      val allowed = PolicyRules.isAllowed path
      val actionStr = if action = "" then "OTHER" else action

      val csvLine = timestr ^ "," ^ actionStr ^ "," ^ path ^ "," ^ (Bool.toString allowed)
      val jsonLine = "{\"time\":\"" ^ timestr ^ "\",\"action\":\"" ^ actionStr ^ "\",\"path\":\"" ^ path ^ "\",\"folder\":\"" ^ folder ^ "\"}"

      (* ⬇️ Use the dereferenced path refs *)
      val _ = DataLogger.withAppend (!csvPath) csvLine
      val _ = DataLogger.withAppend (!jsonlPath) jsonLine
      val _ = bumpCount (folder, 1)

      val (level, alertMsg) = makeAlert (timestr, actionStr, path, folder)
      val _ = print ("[EVENT] " ^ timestr ^ " | " ^ actionStr ^ " -> " ^ path ^ "\n")
      val _ = print ("   Folder: " ^ folder ^ "\n")
      val _ = print ("   Allowed? " ^ Bool.toString allowed ^ "\n")
      val _ = print ("   Alert: " ^ levelToString level ^ "\n")

      val _ = if level <> INFO then print ("   >>> " ^ alertMsg ^ "\n") else ()

      val _ = VisualExport.write (timestr, actionStr, path, folder)
    in
      ()
    end

  (* tail file: opens file and seeks to end then waits for new lines *)
  fun tail_and_process filename =
    let
      val inOpt = SOME (TextIO.openIn filename) handle _ => NONE
    in
      case inOpt of
        NONE => print ("[ERROR] tailer: cannot open " ^ filename ^ "\n")
      | SOME instream =>
          let
            fun loop () =
              (case TextIO.inputLine instream of
                 NONE => (OS.Process.sleep (Time.fromMilliseconds 200); loop())
               | SOME line => (processLine line; loop()))
            fun drain () =
              (case TextIO.inputLine instream of
                 NONE => ()
               | SOME _ => drain())
          in
            drain ();
            print ("[TAIL] Watching: " ^ filename ^ "\n");
            loop ()
          end
    end
end
