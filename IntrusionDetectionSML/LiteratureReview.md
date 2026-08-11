
# Literature Survey: File-Based Intrusion Detection System using Standard ML and OS-Level Monitoring
---
## 1. Introduction

Intrusion Detection Systems (IDS) play a pivotal role in cybersecurity by identifying unauthorized access, abnormal behavior, or system breaches. This project presents the design, development, and implementation of a **File Integrity Monitoring-based Intrusion Detection System** written entirely in **Standard ML (SML)** with **Windows/Linux OS integration** for real-time event tracking. The goal was to create a fully functional, extensible IDS that:

* Monitors critical folders like `C:\Users` or `/home/username`
* Detects suspicious activity (file creations, deletions, modifications)
* Generates alerts using anomaly detection
* Visualizes alerts
* Works on **both Windows and Linux**
---
## 2. Evolution of the System

### Phase 1: Baseline File Integrity Monitoring (FIM)

* We began with a basic snapshot system (`fimSnapshot.sml`) that recursively traverses directories and calculates **SHA256 hashes** of all files.
* This created a baseline of the folder's structure and integrity.
* We used `OS.FileSys` to navigate and monitor folder structures in a platform-agnostic way.

### Phase 2: Real-Time File Monitoring with OS-Level API

* For **Windows**, we used `ReadDirectoryChangesW` via `winWatcher.c`, compiled to `winWatcher.exe`.
* For **Linux**, we used `inotify` in `linuxWatcher.c`, compiled as `linuxWatcher.so`.
* Both watchers continuously monitored folders and dumped structured logs to `events.jsonl`.

### Phase 3: Stream Processing and Anomaly Detection

* We built a tailing engine (`tailer.sml`) to continuously parse the JSONL logs.
* Parsed lines are classified by action: CREATE, DELETE, MODIFY, RENAME, etc.
* A sliding window model tracks the frequency of changes per folder.
* **Anomaly Detection Methods:**

  * **Z-score-based statistical deviation**
  * **Shannon entropy** (from `mlAnomaly.sml`)
  * **Policy whitelist** enforcement (from `policyRules.sml`)

### Phase 4: Alert Engine and Visualization

* Alerts are evaluated by `alertEngine.sml`, which combines anomaly score + policy rules.
* Alerts are written to:

  * `alerts.jsonl` (for frontend/charting use)
  * `alerts.csv` (for tabular logs)
* `visualExport.sml` handles writing and formatting alerts.

### Phase 5: State Persistence

* Anomaly detection models need historical state.
* We added `statePersistence.sml` to load/save behavior across runs.
* File: `anomaly_state.txt`

### Phase 6: Cross-Platform Support

* `osDetect.sml` detects OS and invokes correct watcher.
* Unified logic is written in `intrusionMain.sml`, which acts as the entrypoint.
---
## 3. Code Structure and Purpose

| File                   | Description                                                 |
| ---------------------- | ----------------------------------------------------------- |
| `eventTypes.sml`       | Type definitions and parsing of file events                 |
| `hashing.sml`          | SHA256 hashing of files using `CertUtil` on Windows         |
| `fimSnapshot.sml`      | Recursive snapshot of folder state                          |
| `tailer.sml`           | Real-time parser and processor of events.jsonl logs         |
| `mlAnomaly.sml`        | Shannon entropy and statistical tools                       |
| `anomalyDetection.sml` | Sliding window z-score model per folder                     |
| `policyRules.sml`      | Whitelisting mechanism                                      |
| `alertEngine.sml`      | Combines policies and anomalies to generate alerts          |
| `dataLogger.sml`       | Handles log writing to CSV/JSONL                            |
| `statePersistence.sml` | Loads/saves anomaly model state                             |
| `visualExport.sml`     | Outputs alerts in readable formats                          |
| `osDetect.sml`         | Detects whether OS is Windows/Linux                         |
| `monitorLauncher.sml`  | Spawns the appropriate watcher subprocess                   |
| `intrusionMain.sml`    | Entry point. Runs snapshot + tailer + watcher + alert logic |
| `winWatcher.c`         | Windows C file monitor using ReadDirectoryChangesW          |
| `linuxWatcher.c`       | Linux C watcher using inotify API                           |
---
## 4. Outputs and Their Meaning

| File                | Purpose                                                 |
| ------------------- | ------------------------------------------------------- |
| `alerts.csv`        | Tabular list of all alerts (folder, severity, message)  |
| `alerts.jsonl`      | Line-by-line JSON for visualization                     |
| `anomaly_state.txt` | Persistent state tracking of folder access patterns     |
| `events.jsonl`      | Raw log of all filesystem changes detected in real time |
---
## 5. How Intrusion Detection Happens

1. `winWatcher.exe` or `linuxWatcher.so` writes to `events.jsonl`
2. `tailer.sml` reads events and updates stats
3. `anomalyDetection.sml` computes z-score or entropy for folder
4. `alertEngine.sml` checks whitelist and anomaly level
5. `visualExport.sml` and `dataLogger.sml` log to `alerts.csv` and `alerts.jsonl`
6. If thresholds crossed → `CRITICAL` or `WARN` alerts generated
---
## 6. Use Cases and Benefits

* Detects ransomware or malware modifying files in real time
* Detects unauthorized additions/deletions
* Maintains forensic audit logs of file activity
* Academic demonstration of anomaly detection + OS-level monitoring
---
## 7. Conclusion

This system is a complete and extensible platform for file-based intrusion detection using a functional programming approach. With strong theoretical foundations (z-score, entropy, whitelist), real-time OS-level hooks, and platform compatibility, it demonstrates practical defense capabilities suitable for research or production monitoring of critical systems.
