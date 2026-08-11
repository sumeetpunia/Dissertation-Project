(* eventTypes.sml *)
structure EventTypes =
struct
  datatype eventType = CREATE | DELETE | MODIFY | RENAME | OTHER

  fun stringToEvent s =
    case String.implode (List.map Char.toUpper (String.explode s)) of
      "CREATE" => CREATE
    | "DELETE" => DELETE
    | "MODIFY" => MODIFY
    | "RENAME" => RENAME
    | _ => OTHER

  (* basic safe substring *)
  fun substringSafe (s:string) (i:int) (len:int) =
    let val n = String.size s
        val i' = Int.max(0, Int.min(i,n))
        val l' = Int.max(0, Int.min(len, n-i'))
    in String.substring(s,i',l') end

  fun dropWhile p [] = []
    | dropWhile p (x::xs) = if p x then dropWhile p xs else x::xs

  (* naive JSON field extractor for small JSON lines like {"time":"...","action":"...","path":"..."} *)
  fun extractField (json:string, field:string) =
    let
      val pat = "\"" ^ field ^ "\":"
      fun findFrom i =
        if i + String.size pat > String.size json then NONE
        else if String.substring(json, i, String.size pat) = pat then SOME i
        else findFrom (i+1)
    in
      case findFrom 0 of
        NONE => ""
      | SOME i =>
          let
            val rest = String.substring(json, i + String.size pat, String.size json - (i + String.size pat))
            (* skip optional whitespace, optional starting quote *)
            val rest2 = String.implode (dropWhile (fn c => c = #" " orelse c = #"\t") (String.explode rest))
            val start = if String.size rest2 > 0 andalso String.sub(rest2,0) = #"\"" then 1 else 0
            val tail = String.substring(rest2, start, String.size rest2 - start)
            val endIdx =
              let
                fun f j =
                  if j >= String.size tail then NONE
                  else if String.sub(tail,j) = #"\"" then SOME j
                  else f (j+1)
              in f 0 end
          in
            case endIdx of NONE => tail
            | SOME j => String.substring(tail,0,j)
          end
    end
end