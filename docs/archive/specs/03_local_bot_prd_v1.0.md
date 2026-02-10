# **LiNKbot \- Local Bot Product Requirements Document**

## **Hardened Execution Node**

Version: 1.0  
Status: Implementation Contract  
Authority: Subordinate to Overall System PRD \+ Protocol Spec

---

## **1\. Purpose**

The Local Bot is the execution authority of the hybrid system.

It performs:

* filesystem operations  
* drafting  
* skill execution  
* automation bridge actions  
* sandboxed tool usage  
* snapshot \+ rollback  
* completion signing

The Local Bot is designed to remain safe even if the Cloud Bot is compromised.

Local is the final gatekeeper of execution.

---

## **2\. Execution Environment**

The Local Bot must run inside a hardened environment consisting of:

* dedicated OS user  
* Linux virtual machine  
* containerized skill runner  
* virtual filesystem sandbox  
* resource caps  
* signed protocol enforcement

No skill may execute outside this environment.

---

## **3\. Authority Model**

The Local Bot does not trust the Cloud Bot.

It trusts only:

* protocol validity  
* signature verification  
* doctrine compliance  
* skill permissions

Execution is conditional.

Verification precedes action.

---

## **4\. Message Intake Pipeline**

For every incoming job\_manifest:

1. Verify signature  
2. Validate timestamp  
3. Check nonce uniqueness  
4. Confirm expiration  
5. Validate schema  
6. Confirm skill exists  
7. Confirm skill permissions  
8. Check approval tier  
9. Confirm checkpoint rules

If any fails → reject.

No partial execution allowed.

---

## **5\. Skill Execution Architecture**

### **5.1 Skill Isolation**

Each skill runs in:

* ephemeral container  
* restricted filesystem mount  
* restricted network  
* limited CPU \+ RAM  
* time cap  
* clean environment

Container destroyed after execution.

No persistence allowed.

---

### **5.2 Virtual Filesystem (VFS)**

Each skill declares filesystem scope via manifest.

Default: deny-all.

Only declared paths mounted.

Optional read-only mode supported.

Recursive traversal outside mount forbidden.

---

### **5.3 Skill Manifest Requirements**

Each skill must define:

* name  
* purpose  
* allowed paths  
* read/write flags  
* network permissions  
* resource limits  
* checkpoint requirement

Undeclared capability → forbidden.

---

## **6\. Snapshot \+ Rollback System**

Before irreversible operations:

* snapshot target directories  
* generate checkpoint ID  
* verify snapshot integrity  
* encrypt snapshot  
* store offsite

On failure:

* restore snapshot  
* verify restore  
* report rollback

Snapshots must auto-prune by policy.

---

## **7\. Drafting Engine**

Drafting tasks must:

* operate in isolated workspace  
* not access global filesystem  
* not leak external data  
* optionally use local models  
* support critique pass  
* support revision loop

Draft artifacts must be auditable.

---

## **8\. Automation Bridge**

UI automation must be constrained.

Local Bot may:

* execute predefined automation scripts  
* interact only via approved bridge  
* never gain shell authority  
* never escalate OS privileges

Bridge must enforce command whitelist.

Arbitrary shell execution forbidden.

---

## **9\. Signing Authority**

Local Bot must sign:

* job results  
* heartbeats  
* alerts

Signing uses local\_private key.

Keys must be stored in secure enclave / keychain.

Keys never accessible to containers.

---

## **10\. Heartbeat System**

Local must emit heartbeat at fixed interval.

Heartbeat must include:

* VM status  
* skill runner health  
* queue status  
* resource usage

Missing heartbeat indicates fault.

---

## **11\. Failure Ladder**

On execution failure:

1. retry skill (bounded)  
2. rollback \+ retry  
3. partial result  
4. failure alert

Infinite loops forbidden.

---

## **12\. Kill Switch**

Host user must be able to:

* terminate VM  
* cut network  
* stop Local Bot  
* revoke keys

Kill switch must not require Local Bot cooperation.

Human authority overrides system.

---

## **13\. Logging**

Local logs must include:

* decision chain  
* validation results  
* execution result  
* rollback events  
* failures

Logs must exclude secrets.

Logs must be append-only.

---

## **14\. Resource Constraints**

Local Bot must enforce:

* RAM cap  
* CPU cap  
* disk quota  
* container timeouts

No runaway execution allowed.

---

## **15\. Approval Enforcement**

If job requires approval:

Local must confirm approval token exists.

No token → reject.

Cloud cannot bypass this.

---

## **16\. Idempotency Enforcement**

Duplicate job\_id must return prior result.

No duplicate execution allowed.

---

## **17\. Phase Plan**

### **Phase 0 — environment scaffolding**

* VM setup  
* container runner  
* signing key stub

### **Phase 1 — protocol intake**

* signature verification  
* nonce ledger  
* schema validation

### **Phase 2 — skill runner**

* container execution  
* VFS mount  
* resource caps

### **Phase 3 — snapshot system**

* checkpoint creation  
* rollback

### **Phase 4 — drafting engine**

* isolated drafting workspace

### **Phase 5 — automation bridge**

* whitelist command bridge

### **Phase 6 — audit \+ heartbeat**

* signed reports  
* health monitoring

Cursor must not exceed current phase.

---

## **18\. Acceptance Criteria**

Local Bot valid only if:

* rejects unsigned job  
* rejects replay  
* blocks unauthorized filesystem access  
* enforces resource limits  
* restores snapshot correctly  
* kill switch works  
* signing intact  
* containers destroyed after execution

Failure invalidates deployment.

---

## **19\. Forbidden Behavior**

Local Bot must not:

* execute unsigned instructions  
* run arbitrary shell commands  
* expand filesystem scope  
* export private keys  
* disable logging  
* self-modify doctrine

Violation invalidates system.

---

## **End of Local Bot PRD**

---

