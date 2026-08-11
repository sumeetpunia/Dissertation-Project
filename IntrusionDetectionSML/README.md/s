#  Intrusion Detection System in Standard ML

A real-time, cross-platform Intrusion Detection System (IDS) built in **Standard ML**, designed for monitoring file activity, detecting anomalies, and raising intelligent alerts using both statistical and ML-inspired techniques.

---

##  Features

* Real-time file activity monitoring using **Windows API** or **Linux inotify**
* Recursive snapshot-based **File Integrity Monitoring (FIM)**
* Sliding window **anomaly detection** with z-score and entropy
* Alert generation with severity levels
* Policy rule enforcement for sensitive folders
* Visualizable logs in `.jsonl`, `.csv`, and snapshot formats

---

##  Folder Structure

```
IntrusionDetectionSML/
├── *.sml                 # All SML modules
├── winWatcher.c          # Windows real-time watcher (C)
├── winWatcher.exe        # Compiled Windows executable
├── linuxWatcher.c        # Linux watcher (inotify-based)
├── linuxWatcher.so       # Shared object for Linux
├── out.jsonl             # Real-time events
├── alerts.jsonl          # Alerts with metadata
├── anomaly_state.txt     # Persistent state file
├── fim_baseline.txt      # Hash snapshot of files
├── events.csv            # Optional structured log
```


---

##  Windows: Running the System

### Navigate the folder

 ```sml
 cd /c/IntrusionDetectionSML
```
### 1.  Compile Watcher

```bash
gcc -municode -o winWatcher.exe winWatcher.c
```

### 2.  Open Poly/ML and Load Modules

```sml
use "eventTypes.sml";
use "dataLogger.sml";
use "policyRules.sml";
use "anomalyDetection.sml";
use "mlAnomaly.sml";
use "hashing.sml";
use "alertEngine.sml";
use "visualExport.sml";
use "osDetect.sml";
use "statePersistence.sml";
use "fimSnapshot.sml";
use "monitorLauncher.sml";
use "tailer.sml";
use "intrusionMain.sml";
```

### 3.  Run the System

```sml
IntrusionMain.main ["C:\\Users"];
```

This starts FIM + real-time monitoring + tailing + alerting.

---

##  Linux: Running the System

### 1.  Compile Linux Watcher

```bash
gcc -o linuxWatcher.so -fPIC -shared linuxWatcher.c
```

### 2.  Load SML Modules (Same as Windows)

Same commands as above inside `poly`.

### 3.  Run the System

```sml
IntrusionMain.main ["/home/yourname"];
```

---

##  Output Files

| File                | Description                                 |
| ------------------- | ------------------------------------------- |
| `out.jsonl`         | Event stream from watcher                   |
| `alerts.jsonl`      | Raised alerts with severity                 |
| `fim_baseline.txt`  | Snapshot of folder (hash-based)             |
| `anomaly_state.txt` | Folder behavior profile (saved across runs) |
| `events.csv`        | Optional event log in CSV                   |

---

##  Alerts Example

```json
{
  "time": "2025-09-02 04:32:12",
  "folder": "C:\\Users",
  "action": "MODIFY",
  "severity": "CRITICAL",
  "reason": "High modification rate + entropy jump"
}
```

---




> 🎓 For academic use, cite as: *"Real-time Cross-platform File-based Intrusion Detection System using Standard ML and C"*.
