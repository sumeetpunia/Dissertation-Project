(* statePersistence.sml
   Saves and loads anomaly detection state to/from disk
*)

structure StatePersistence =
struct
  open AnomalyDetection

  val stateFile = "anomaly_state.txt"

  (* Serialize a single folder state into a line *)
  fun serialize (folder, {minuteBuckets, lastMinuteTotal}) =
    folder ^ "|" ^
    String.concatWith "," (List.map Int.toString minuteBuckets) ^ "|" ^
    Int.toString lastMinuteTotal

  (* Deserialize one line *)
  fun deserialize line =
    case String.tokens (fn c => c = #"|") line of
        [folder, bucketsStr, totalStr] =>
          let
            val bucketList =
              case String.tokens (fn c => c = #",") bucketsStr of
                  [] => []
                | xs => List.map (fn s => Option.getOpt (Int.fromString s, 0)) xs
            val total = Option.getOpt (Int.fromString totalStr, 0)
          in
            SOME (folder, {minuteBuckets = bucketList, lastMinuteTotal = total})
          end
      | _ => NONE

  fun save () =
    let
      val out = TextIO.openOut stateFile
      val lines = List.map serialize (!state)
      val _ = List.app (fn line => TextIO.output (out, line ^ "\n")) lines
    in
      TextIO.closeOut out;
      print ("[SAVE] Anomaly state saved to " ^ stateFile ^ "\n")
    end

  fun load () =
    let
      val result =
        (SOME (TextIO.inputAll (TextIO.openIn stateFile)))
        handle _ => NONE
    in
      case result of
          NONE => print "[LOAD] No previous anomaly state found.\n"
        | SOME content =>
            let
              val lines = String.tokens (fn c => c = #"\n") content
              val deserialized = List.mapPartial deserialize lines
              val _ = state := deserialized
            in
              print ("[LOAD] Loaded anomaly state from " ^ stateFile ^ "\n")
            end
    end
end
