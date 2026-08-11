(* alertEngine.sml
   Generates alerts based on anomaly score, entropy, and policy rules
*)

structure AlertEngine =
struct
  open AnomalyDetection
  open MLAnomaly
  open PolicyRules

  datatype alertLevel = INFO | WARN | CRITICAL

  fun levelToString l =
    case l of
        INFO => "INFO"
      | WARN => "WARN"
      | CRITICAL => "CRITICAL"

  (* Main scoring logic based on z-score and entropy *)
  fun evaluate (folder:string, path:string) : alertLevel =
    let
      val z = zScore folder
      val ent = shannonEntropy (countsForStats folder)
      val allowed = isAllowed path
    in
      if not allowed andalso Real.abs z > 3.0 andalso ent > 2.0 then CRITICAL
      else if Real.abs z > 2.0 orelse ent > 3.0 then WARN
      else INFO
    end

  (* Format full alert message *)
  fun makeAlert (timestamp:string, action:string, path:string, folder:string) =
    let
      val level = evaluate (folder, path)
      val message =
        "[ALERT][" ^ levelToString level ^ "] " ^
        timestamp ^ " | " ^ action ^ " | " ^ path ^ " | Folder: " ^ folder
    in
      (level, message)
    end
end
