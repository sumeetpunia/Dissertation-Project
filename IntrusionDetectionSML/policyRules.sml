(* policyRules.sml *)
structure PolicyRules =
struct
  (* whitelist of allowed prefixes; edit in Poly/ML as needed *)
  val whitelist : string list ref = ref ["C:\\Windows", "C:\\Program Files", "C:\\Users"]

  fun isAllowed path =
    List.exists (fn prefix => String.isPrefix prefix path) (!whitelist)
end