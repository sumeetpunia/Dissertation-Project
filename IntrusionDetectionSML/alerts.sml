structure Alerts = struct
    fun showAlert msg =
        (print ("[ALERT] " ^ msg ^ "\n"))
        handle _ => ();
end;
