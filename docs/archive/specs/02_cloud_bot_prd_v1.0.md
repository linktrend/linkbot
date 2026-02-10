# **LiNKbot \- Cloud Bot Product Requirements Document**

## **Strategic Orchestrator Node**

Version: 1.0  
Status: Implementation Contract  
Authority: Subordinate to Overall System PRD \+ Protocol Spec

---

## **1\. Purpose**

The Cloud Bot is the strategic orchestrator of the hybrid autonomous operations system.

It is responsible for:

* planning  
* research  
* task decomposition  
* approval management  
* signed job issuance  
* audit aggregation  
* overnight scheduling  
* health monitoring

It is not responsible for execution of privileged local actions.

The Cloud Bot must assume it is operating in a potentially hostile environment and must never rely on implicit trust.

---

## **2\. Functional Role**

The Cloud Bot acts as:

* operations manager  
* planner  
* research agent  
* scheduler  
* command issuer

It never executes destructive actions.

It never holds Local secrets.

It never bypasses protocol.

It cannot self-authorize unsafe work.

---

## **3\. Core Responsibilities**

### **3.1 Goal Intake**

The Cloud Bot receives human-defined goals.

Goals are immutable unless human-modified.

The Cloud Bot may:

* analyze goals  
* propose strategy  
* decompose into plans

It may not rewrite goals autonomously.

---

### **3.2 Strategy Engine**

The Cloud Bot must generate:

* short-term plans  
* medium-term plans  
* long-term plans

Plans must decompose into:

monthly → weekly → daily tasks

Each task must include:

* risk classification  
* approval tier  
* execution environment  
* skill mapping

---

### **3.3 Research Engine**

Research tasks must:

* run in Cloud zone only  
* sanitize external input  
* strip executable content  
* produce text-only artifacts  
* preserve citations

Research artifacts must never contain executable instructions.

---

### **3.4 Task Classification**

Every task must be labeled:

* safe autonomous  
* approval required  
* forbidden

Classification must follow Overall PRD doctrine.

No implicit assumptions allowed.

---

### **3.5 Approval Gate Manager**

For approval-required tasks:

* queue approval request  
* attach explanation  
* attach recommendation  
* await decision

No execution allowed without approval.

Timeout must pause task.

---

### **3.6 Job Manifest Generator**

The Cloud Bot must:

* generate protocol-compliant job\_manifest  
* sign with cloud\_private key  
* include expiration  
* include checkpoint rules  
* include skill reference

Unsigned jobs forbidden.

---

### **3.7 Scheduling Engine**

The Cloud Bot must support:

* overnight batch execution  
* queue prioritization  
* blocked task isolation  
* dependency tracking

Scheduler must never stall entire queue.

---

### **3.8 Heartbeat Monitor**

Cloud must monitor Local heartbeat.

Missing heartbeat triggers:

* issuance halt  
* alert state  
* human notification

Cloud must not assume Local availability.

---

### **3.9 Audit Aggregation**

Cloud must collect:

* job results  
* summaries  
* failure reports  
* assumption flags

Cloud must store append-only logs.

Cloud logs must exclude secrets.

---

## **4\. Security Constraints**

### **4.1 No Local Secrets**

Cloud must never store:

* Local credentials  
* Local filesystem data  
* Local signing keys

Violation invalidates system.

---

### **4.2 Compromise Assumption**

Cloud is assumed compromisable.

Cloud architecture must assume hostile takeover.

Local must remain safe.

---

### **4.3 Strict Protocol Enforcement**

Cloud must reject:

* malformed responses  
* unsigned messages  
* invalid signatures

Fail closed.

---

## **5\. Skill Model (Cloud)**

Cloud skills include:

* research skill  
* planning skill  
* approval handling  
* scheduling  
* audit aggregation

Cloud skills must never execute:

* filesystem writes to Local  
* shell commands on Local  
* destructive actions

---

## **6\. Reporting Requirements**

Cloud must produce:

* morning summary  
* executive overview  
* flagged assumptions  
* paused tasks  
* failure reports

Reports must be concise.

Full logs stored separately.

---

## **7\. Failure Handling**

If Local rejects job:

* log rejection  
* classify failure  
* retry if safe  
* escalate if unsafe

If repeated failures occur:

* pause task  
* request human review

---

## **8\. Performance Requirements**

Cloud must support:

* long-duration operation  
* queue persistence  
* restart recovery  
* idempotent job issuance

No task loss allowed.

---

## **9\. Phase Plan**

### **Phase 0 — scaffolding**

* repo structure  
* protocol library  
* key management stub

### **Phase 1 — handshake**

* signed job issuance  
* signature verification  
* dummy execution loop

### **Phase 2 — scheduler**

* queue engine  
* overnight loop

### **Phase 3 — research \+ planning**

* research skill  
* strategy decomposition

### **Phase 4 — approval system**

* approval gate  
* escalation flow

### **Phase 5 — audit \+ reporting**

* summary engine  
* log aggregation

Cursor must not implement beyond current phase.

---

## **10\. Acceptance Criteria**

Cloud Bot valid only if:

* signed job verified by Local  
* unsigned job rejected  
* missing heartbeat halts issuance  
* approval gate blocks unsafe tasks  
* scheduler isolates blocked tasks  
* logs intact after restart

---

## **11\. Forbidden Behavior**

Cloud Bot must not:

* execute local commands  
* bypass approval  
* invent goals  
* modify protocol  
* disable logging  
* override doctrine

Violation invalidates system.

---

## **End of Cloud Bot PRD**

---

