// winWatcher.c
#include <windows.h>
#include <stdio.h>

void watchDirectory(const char* folder, const char* outfile) {
    HANDLE hDir = CreateFile(
        folder, FILE_LIST_DIRECTORY,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        NULL, OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED,
        NULL);

    if (hDir == INVALID_HANDLE_VALUE) {
        printf("ERROR: Unable to open directory handle.\n");
        return;
    }

    char buffer[1024];
    DWORD bytesReturned;
    FILE_NOTIFY_INFORMATION* info = (FILE_NOTIFY_INFORMATION*)buffer;
    FILE* out = fopen(outfile, "a");
    if (!out) {
        printf("ERROR: Unable to open output file.\n");
        return;
    }

    while (1) {
        if (ReadDirectoryChangesW(hDir, buffer, sizeof(buffer), TRUE,
            FILE_NOTIFY_CHANGE_FILE_NAME | FILE_NOTIFY_CHANGE_DIR_NAME |
            FILE_NOTIFY_CHANGE_ATTRIBUTES | FILE_NOTIFY_CHANGE_SIZE |
            FILE_NOTIFY_CHANGE_LAST_WRITE | FILE_NOTIFY_CHANGE_CREATION,
            &bytesReturned, NULL, NULL)) {

            char filename[MAX_PATH];
            int len = WideCharToMultiByte(CP_UTF8, 0,
                info->FileName, info->FileNameLength / sizeof(WCHAR),
                filename, sizeof(filename) - 1, NULL, NULL);
            filename[len] = '\0';

            const char* action;
            switch (info->Action) {
                case FILE_ACTION_ADDED: action = "CREATE"; break;
                case FILE_ACTION_REMOVED: action = "DELETE"; break;
                case FILE_ACTION_MODIFIED: action = "MODIFY"; break;
                case FILE_ACTION_RENAMED_OLD_NAME: action = "RENAME"; break;
                case FILE_ACTION_RENAMED_NEW_NAME: action = "RENAME"; break;
                default: action = "OTHER"; break;
            }

            SYSTEMTIME st;
            GetLocalTime(&st);
            fprintf(out,
                "{\"time\":\"%02d:%02d:%02d\",\"action\":\"%s\",\"path\":\"%s\\\\%s\",\"folder\":\"%s\"}\n",
                st.wHour, st.wMinute, st.wSecond, action, folder, filename, folder);
            fflush(out);
        }
    }

    CloseHandle(hDir);
    fclose(out);
}
