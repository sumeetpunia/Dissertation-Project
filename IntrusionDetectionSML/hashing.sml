(* hashing.sml *)
structure Hashing =
struct
  fun sha256_of_file (path:string) =
    let
      val cmd = "certutil -hashfile \"" ^ path ^ "\" SHA256 > tmp_hash.txt 2>&1"
      val _ = OS.Process.system cmd
      val content = (case SOME (TextIO.openIn "tmp_hash.txt") handle _ => NONE of
                        NONE => ""
                      | SOME inS => let val s = TextIO.inputAll inS in TextIO.closeIn inS; s end)
      (* parse the first hex string in file *)
      val tokens = String.tokens (fn c => c = #" " orelse c = #"\t" orelse c = #"\r" orelse c = #"\n") content
      val hash = if List.length tokens >= 1 then List.hd tokens else ""
    in
      hash
    end
end