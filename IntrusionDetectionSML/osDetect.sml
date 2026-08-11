(* osDetect.sml
   Detects if the system is Windows or Linux.
*)

structure OSDetect =
struct
  datatype osType = Windows | Linux | Unknown

  fun detect () =
    case OS.Process.getEnv "OS" of
        SOME s => if String.isSubstring "Windows" s then Windows else Linux
      | NONE =>
          (* Fallback for Linux/Mac if $OS not defined *)
          case OS.Process.getEnv "HOME" of
              SOME _ => Linux
            | NONE => Unknown

  fun osName os =
    case os of
        Windows => "Windows"
      | Linux => "Linux"
      | Unknown => "Unknown"

end
