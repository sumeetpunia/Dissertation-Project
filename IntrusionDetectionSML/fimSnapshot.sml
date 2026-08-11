(* fimSnapshot.sml *)
structure FIMSnapshot =
struct
  open OS.FileSys
  open Hashing

  fun isDir path =
    (OS.FileSys.isDir path) handle _ => false

  fun listFiles folder =
    let
      val stream = OS.FileSys.openDir folder
      fun loop acc =
        case OS.FileSys.readDir stream of
            NONE => (OS.FileSys.closeDir stream; acc)
          | SOME name =>
              if name = "." orelse name = ".." then loop acc
              else loop (name :: acc)
    in
      loop []
    end

  fun fullPaths folder =
    List.map (fn f => folder ^ "\\" ^ f) (listFiles folder)

  fun hashFileSafe path =
    (SOME (sha256_of_file path)) handle _ => NONE

  fun snapshot folder =
    let
      val files = fullPaths folder
      val hashes = List.map (fn f => (f, hashFileSafe f)) files
    in hashes end

  fun printSnapshot folder =
    let
      val snap = snapshot folder
      fun show (path, NONE) = print ("[FIM] " ^ path ^ " -> <error>\n")
        | show (path, SOME h) = print ("[FIM] " ^ path ^ " -> " ^ h ^ "\n")
    in
      List.app show snap
    end
end
