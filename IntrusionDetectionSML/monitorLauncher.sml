(*  monitorLauncher.sml *)
structure MonitorLauncher =
struct
fun spawnWatcher folder outfile =
let
val watcher =
case OSDetect.detect() of
OSDetect.Windows => "watcher.exe"
| OSDetect.Linux => "./watcher"
| _ => raise Fail "Unknown OS"


val command = watcher ^ " \"" ^ folder ^ "\" \"" ^ outfile ^ "\""
val status = OS.Process.system command
in
if OS.Process.isSuccess status then ()
else print ("[ERROR] watcher failed for " ^ folder ^ "\n")
end
end