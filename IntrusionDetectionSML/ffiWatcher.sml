(* FFI for Windows: monitors multiple folders recursively *)
structure FFIWatcher =
struct
    open EventTypes
    open DataLogger
    open PolicyRules
    open AnomalyDetection

    (* Windows FFI imports *)
    structure FFI = PolyMLFFI

    val kernel32 = FFI.loadLibrary "kernel32.dll"

    val FILE_LIST_DIRECTORY = 1
    val FILE_SHARE_READ = 1
    val FILE_SHARE_WRITE = 2
    val OPEN_EXISTING = 3
    val FILE_NOTIFY_CHANGE_FILE_NAME = 1
    val FILE_NOTIFY_CHANGE_DIR_NAME = 2
    val FILE_NOTIFY_CHANGE_ATTRIBUTES = 4
    val FILE_NOTIFY_CHANGE_SIZE = 8
    val FILE_NOTIFY_CHANGE_LAST_WRITE = 16

    val CreateFileW =
        FFI.buildCall5
            (FFI.loadFunction(kernel32, "CreateFileW"))
            (FFI.c_pointer, FFI.c_int, FFI.c_int, FFI.c_pointer, FFI.c_int)
            FFI.c_pointer

    val ReadDirectoryChangesW =
        FFI.buildCall8
            (FFI.loadFunction(kernel32, "ReadDirectoryChangesW"))
            (FFI.c_pointer, FFI.c_pointer, FFI.c_int, FFI.c_bool, FFI.c_int, FFI.c_pointer, FFI.c_pointer, FFI.c_pointer)
            FFI.c_bool

    val CloseHandle =
        FFI.buildCall1
            (FFI.loadFunction(kernel32, "CloseHandle"))
            (FFI.c_pointer)
            FFI.c_bool

    fun toWString s =
        let
            val bytes = ByteArray.fromString(s ^ "\u0000")
        in
            FFI.allocBytes (ByteArray.length bytes)
        end

    fun watchFolder folder =
        if isAllowed folder then (
            DataLogger.logCSV ("Monitoring: " ^ folder);
            (* Actual watching logic using FFI, simplified for Poly/ML demo *)
            ()
        ) else
            ()
end
