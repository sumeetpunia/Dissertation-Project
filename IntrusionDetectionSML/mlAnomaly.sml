(* mlAnomaly.sml *)
structure MLAnomaly =
struct
  fun toProbs counts =
    let val total = Real.fromInt (List.foldl op+ 0 counts)
    in if total <= 0.0 then [] else List.map (fn c => Real.fromInt c / total) counts end

  fun shannonEntropy counts =
    let
      fun safeLog x = if x <= 0.0 then 0.0 else Math.ln x
      val ps = toProbs counts
    in
      List.foldl (fn (p,acc) => acc + (if p <= 0.0 then 0.0 else (~ p) * (safeLog p) / (Math.ln 2.0))) 0.0 ps
    end
end