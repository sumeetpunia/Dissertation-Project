(* dataLogger.sml *)
structure DataLogger =
struct
  val csvPath = "events.csv"
  val jsonlPath = "events.jsonl"

  (* safe append with retry to avoid sharing violation *)
  fun withAppend (path:string) (line:string) =
    let
      fun tryN 0 = (print ("[ERROR] failed to append to " ^ path ^ "\n"); ())
        | tryN k =
            (case SOME (TextIO.openAppend path) handle _ => NONE of
               NONE => (OS.Process.sleep (Time.fromMilliseconds 80); tryN (k-1))
             | SOME out =>
                 (TextIO.output (out, line ^ "\n");
                  TextIO.flushOut out;
                  TextIO.closeOut out))
    in
      tryN 8
    end

  fun logCSV line = withAppend csvPath line
  fun logJSON line = withAppend jsonlPath line
end