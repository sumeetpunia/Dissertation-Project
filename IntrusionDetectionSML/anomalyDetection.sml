(* anomalyDetection.sml *)
structure AnomalyDetection =
struct
  type folderState = {minuteBuckets: int list, lastMinuteTotal:int}

  val state : (string * folderState) list ref = ref []

  fun getState folder =
    case List.find (fn (f,_) => f = folder) (!state) of
       NONE => {minuteBuckets = [], lastMinuteTotal = 0}
     | SOME (_, st) => st

  fun replaceState folder st =
    let val others = List.filter (fn (f,_) => f <> folder) (!state)
    in state := (folder, st)::others end

  (* update bucket counts: we record per-minute totals externally by calling rollMinute *)
  fun bumpCount (folder, delta:int) =
    let val st = getState folder
        val newLast = #lastMinuteTotal st + delta
    in replaceState folder {minuteBuckets = #minuteBuckets st, lastMinuteTotal = newLast} end

  (* rollMinute: push lastMinuteTotal onto minuteBuckets and reset lastMinuteTotal *)
  fun rollMinute folder =
    let val st = getState folder
        val newBuckets = List.take (#lastMinuteTotal st :: #minuteBuckets st, 60)
    in replaceState folder {minuteBuckets = newBuckets, lastMinuteTotal = 0} end

  fun countsForStats folder = #minuteBuckets (getState folder)

  (* z-score comparing latest bucket to historical mean/std *)
  fun zScore folder =
    let val buckets = countsForStats folder
        val n = List.length buckets
    in if n < 5 then 0.0 else
       let
         val total = Real.fromInt (List.foldl op+ 0 buckets)
         val mean = total / Real.fromInt n
         (* compute variance correctly *)
         val varsum2 = List.foldl (fn (x, acc) => let val d = Real.fromInt x - mean in acc + d*d end) 0.0 buckets
         val variance = varsum2 / Real.fromInt n
         val stdev = Math.sqrt variance
         val latest = Real.fromInt (hd buckets)
       in if stdev <= 0.0 then 0.0 else (latest - mean) / stdev end
    end
endS