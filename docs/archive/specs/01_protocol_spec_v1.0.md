# **LiNKbot \- Protocol Specification v1.0**

## **Signed Cloud ↔ Local Execution Contract**

Version: 1.0  
Status: Frozen Interface Contract  
Authority: Binding System Interface

---

## **1\. Purpose**

This document defines the communication protocol between the Cloud Bot and Local Bot.

The protocol guarantees:

* authenticity  
* integrity  
* replay protection  
* non-repudiation  
* deterministic parsing  
* auditability

The protocol is designed under the assumption that the Cloud environment may be compromised.

The Local environment must reject unauthorized or malformed instructions.

This protocol is not optional.

No unsigned or invalid message may be executed.

---

## **2\. Transport Layer Requirements**

The protocol must run over an encrypted transport:

Allowed:

* VPN tunnel (preferred)  
* HTTPS/TLS with certificate validation

Forbidden:

* plaintext transport  
* self-signed certificates without pinning  
* unsigned local sockets

Transport encryption does not replace message signing.

Both are required.

---

## **3\. Message Model**

All communication uses structured JSON messages.

Each message must conform to:

{  
  protocol\_version: "1.0",  
  message\_type: "...",  
  message\_id: "...",  
  timestamp: "...",  
  nonce: "...",  
  payload: {...},  
  signature: "..."  
}

Fields are mandatory.

Unknown fields must be ignored but preserved for logging.

Missing required fields invalidate the message.

---

## **4\. Message Types**

### **4.1 job\_manifest**

Issued by Cloud → Local.

Defines a task for execution.

Payload includes:

* job\_id  
* task\_type  
* skill\_name  
* execution\_parameters  
* approval\_tier  
* checkpoint\_required  
* expiration\_time

Local must verify:

* signature valid  
* timestamp within window  
* nonce unused  
* expiration not passed  
* skill allowed

If any fails → reject.

---

### **4.2 job\_ack**

Issued by Local → Cloud.

Confirms receipt.

Payload includes:

* job\_id  
* accepted / rejected  
* rejection\_reason (if any)

---

### **4.3 job\_result**

Issued by Local → Cloud.

Reports completion.

Payload includes:

* job\_id  
* success / partial / failure  
* result\_summary  
* flagged\_assumptions  
* checkpoint\_id  
* logs\_hash  
* artifacts\_reference

Must be signed by Local.

---

### **4.4 heartbeat**

Issued periodically by Local.

Indicates system health.

Payload includes:

* system\_status  
* VM\_status  
* skill\_runner\_status  
* timestamp

Cloud must treat missing heartbeat as fault condition.

---

### **4.5 alert**

Issued by Local.

Indicates critical failure.

Payload includes:

* severity  
* description  
* recommended\_action

Cloud must halt task issuance until resolved.

---

## **5\. Signature Model**

All messages must be signed using Ed25519.

Signing rules:

* signature covers full message except signature field  
* canonical JSON serialization required  
* whitespace differences forbidden  
* deterministic ordering required

Verification failure → message invalid.

---

## **6\. Key Ownership**

Cloud has keypair:

* cloud\_private  
* cloud\_public

Local has keypair:

* local\_private  
* local\_public

Cloud trusts local\_public.  
Local trusts cloud\_public.

Key exchange occurs out-of-band.

Keys are immutable unless rotated by explicit authority.

---

## **7\. Nonce Rules**

Each message must contain a cryptographically random nonce.

Local must maintain a rolling nonce ledger.

Duplicate nonce → reject.

Nonce lifetime window must be configurable.

Default: 24 hours.

---

## **8\. Timestamp Rules**

Each message must include UTC timestamp.

Allowed drift window: ±5 minutes.

Outside window → reject.

This prevents replay.

---

## **9\. Replay Protection**

Replay detection requires:

* nonce uniqueness  
* timestamp validation  
* message\_id uniqueness

All three must pass.

Failure of any → reject.

---

## **10\. Expiration Rules**

job\_manifest messages must include expiration\_time.

Expired jobs must never execute.

Expired messages must be logged.

---

## **11\. Idempotency**

job\_id must be unique.

Local must reject duplicate execution.

Replayed job\_id must return previous result.

This prevents double execution.

---

## **12\. Error Handling**

Invalid messages must produce:

* rejection event  
* logged audit entry  
* alert if suspicious

Local must never attempt to repair invalid messages.

Fail closed.

---

## **13\. Logging Requirements**

Every accepted message must log:

* message\_id  
* signature verification result  
* nonce status  
* timestamp validation  
* execution decision

Logs must exclude payload secrets.

---

## **14\. Compatibility Rules**

protocol\_version mismatch must reject message.

Future versions must maintain backward compatibility through version negotiation.

No silent downgrade allowed.

---

## **15\. Failure Semantics**

If Local cannot verify signature:

* job rejected  
* alert issued  
* Cloud trust considered compromised

If heartbeat missing:

* Cloud halts issuance  
* human intervention required

---

## **16\. Security Assumptions**

The protocol assumes:

* Cloud may be hostile  
* network may be hostile  
* Local must defend itself

Local is the final authority on execution.

Cloud is advisory.

---

## **17\. Change Governance**

Protocol changes require:

* version increment  
* human authorization  
* PRD revision  
* redeployment

Hot patching forbidden.

---

## **End of Protocol Spec v1.0**

---

