(* intrusionMain.sml *)
structure IntrusionMain =
struct
  open Tailer
  open MonitorLauncher
  open OSDetect
  open StatePersistence
  open FIMSnapshot

  fun main folders =
    let
      val _ = print "[LOAD] Restoring anomaly state if available...\n"
      val _ = StatePersistence.load ()

      val _ = List.app (fn folder =>
        let
          val _ = print ("[FIM] Taking snapshot of folder: " ^ folder ^ "\n")
          val _ = printSnapshot folder

          val _ = print ("[MONITOR] Spawning watcher for: " ^ folder ^ "\n")
          val jsonl = "events_" ^ String.translate (fn #":" => "_" | #"\\" => "_" | c => str c) folder ^ ".jsonl"
          val _ = spawnWatcher folder jsonl

          val _ = print ("[TAIL] Starting tail and process loop...\n")
          val _ = tail_and_process jsonl
        in
          ()
        end
      ) folders
    in
      ()
    end
end
