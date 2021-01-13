# Key Terms

* Trusted Computing Base (TCB)
  * Components of the system that must be fundamentally trusted to bootstrap
    any form of trust in the rest of the system
  * If the TCB is compromised, the system is totally compromised

* Trusted Platform Module (TPM)
  * An open standard for a Hardware/Software module used to provide root of
    trust guarantees by integrating with the system architecture (via a physically embedded TPM chip)
  * There are also pure software TPM implementations, with some weaker or missing guarantees

* Measurement
  * Cryptographic hashing of system software/firmware components
  * Verify component state, integrity

* Protected Module Architectures (PMAs)
  * Separate security-critical components into smaller protected modules
  * Since they are separated, they are much simpler and correctness proofs/verification are easier
  * Modules are isolated from the rest of the system to improve tamper-resistance

* Trust Chains
  * TODO

* Root of Trust for Measurement (RTM)
  * Root of trust, basis for first measurement

* Root of Trust for Storage (RTS)
  * Root of trust, basis for secure cryptographic keys
  * Usually holds an asymmetric, private SRK (storage root key)

* Root of Trust for Reporting (RTR)
  * Root of trust, basis for asserting system identity
  * Holds an asymmetric, private EK (endorsement key) which represents a unique
    platform identity

* Storage Root Key (SRK)
  * An asymmetric, private key, stored in the RTS (usually by itself)
  * Used to manage access to a key ring

* Endorsement Key (EK)
  * An asymmetric, private key, stored in the RTR
  * Represents a unique platform identity

* Static RTM (SRTM)
  * TODO

* Dynamic RTM (DRTM)
  * TODO

* Measured Launched Environment
  * TODO

* Platform Configuration Registers (PCRs)
  * TODO

* Attestation Identity Keys (AIKs)
  * TODO

* Direct Anonymous Attestation (DAAs)
  * TODO

* Mobile Trusted Module (MTM)
  * TODO
  * Remote Owner MTM (MTRM)
    * TODO
  * Local Owner MTM (MTLM)
    * TODO

* Secure Boot
  * TODO

* Reference Integrity Metrics (RIMs)
  * TODO

* Root Trust for Verification (RTV)
  * TODO

* Root Trust for Enforcement (RTE)
  * TODO

# Week 1 Notes

Papers:

* The ten-page introduction to Trusted Computing
* Hardware-Based Trusted Computing Architectures for Isolation and Attestation

Supplementary Material:

* https://www.design-reuse.com/articles/47992/rot-the-foundation-of-security.html


## The ten-page introduction to Trusted Computing

* Trusted computing:
  * Re-design of system architecture
  * Discrete components with well-defined characteristics
  * Motivated by an analysis of risks

* The "Trusted Computing Group" (TCG)
  * Industry consortium dedicated to trusted computing research
  * Previous work focused on expensive systems, TCG wants to bring trusted
    computing into everyday devices

* __Two new system characteristics:__
  1. High confidence in state of the local system
    * Configuration, running software, etc.
    * Local attestation?
  2. High confidence in the state of a remote system
    * Remote attestation

* Knowing state is __not enough for establishing trust__, but provides a nice
  basis for informing decisions

* Users are always engaged in informal risk assessment
  * How do I know that when I press "Go" the desired outcome will happen?
  * Do we trust the computer? Is there an alternative to trusting it?

* Users might have misplaced trust in _their own systems_
  * Do you really know what software is on your computer?
  * "System administrator" model for personal computing relies on user expertise
    (often limited)

* Similar issues over a _network_
  * Need to assume that people who manage servers are "wise and good"
  * Wise: won't do anything stupid
  * Good: won't do anything malicious
  * Neither assumption is necessarily valid

### Defining Trust

* _Trusted Computing Base_ (TCB)
  * First formalized in the DoD's "Orange Book" (Trusted Computer Systems Evaluation Criteria)
  * Parts of the system (hardware, software, etc.) that you need to rely upon
  * If any of these parts fail, the system is totally compromised

* We rely on the correct or predictable operation of _trusted systems_
  * Orthogonal to the idea of security
  * Trust on its own does not imply security
  * Use trusted components to build secure systems

* Distinguish the following:
  1. trusted systems (systems that we trust)
  2. trustworthy systems (systems that deserve our trust)
  3. trustable systems (systems that can be trusted)

* Trusted Computing is probably better defined as Trustable Computing

* Proudler's criteria for system trustworthiness:
  1. unambiguously identifiable
  2. unhindered operation
  3. user has first-hand experience of consistent, good behaviour or trusts
     someone else who attests to this

* How to build an expectation of good behaviour?
  * Proofs of correctness
  * Proofs are more useful in theory than in practice
  * Modern systems are too complex to be totally formally verifiable

* Surrogates for proofs:
  1. Testing
  2. Long-term use experience
  3. Third-party evaluation, certification, etc.

* TCG's definition:
  * "An entity can be trusted if it always behaves in the expected manner for
    the intended purpose."

### Trusted Computing Platforms

* We require systems to:
  1. Strongly identify themselves (public key crypto with a secret key strongly
     tied to the system)
  2. Strongly identify their current config + running software (cryptographic
     hashes of object code, etc.)

* Privacy concerns: user's don't want others to identify their systems
  * Need a mechanism to prevent abuse of identifying information

* Establishing strong tie to the system:
  * Tamper-resistance or at least tamper-evidence
  * Isolate cryptographic keys, computation from the rest of the system
  * E.g., cryptographic co-processor

* Identifying system state/config:
  * Careful "measurement" of all firmware/software elements of the system
    * BIOS, ROMs, boot loader, configurations, OS kernels, libraries, applications, etc.
  * Here measurement means making a cryptographic hash of the component to verify integrity
  * Not always an easy problem: e.g. optimized assembly will produce an object with a different hash

__Trusted Platform Module (TPM)__

* Need to change the architecture of the PC to achieve our goals above

* For this, we use a TPM
  * Logical bundle of functionality + means of embedding it in the PC architecture
  * Functional behaviour comes from software (running in the TPM)
  * Guarantees like key protection are achieved via hardware
  * TPM is connected to the CPU via the LPC (low pin count) bus

* For TPM functionality, we require a sub-Turing-machine (i.e. without general
  read/write capability for storage locations)

* Need _protected storage_, accessible only through special interfaces

* TPM provides __three roots of trust__:
  1. __Root of Trust for Measurement (RTM)__
    * Trusted implementation of a hash algorithm
    * First measurement of the platform (at boot time or at some point after)
    * Put the system into a trusted state
  1. __Root of Trust for Storage (RTS)__
    * Trusted implementation of a shielded location for secret keys
    * Often just one secret key (storage root key (SRK))
  1. __Root of Trust for Reporting (RTR)__
    * Trusted implementation of a shielded location to hold a secret key for
      uniquely identifying the platform
    * Called the endorsement key (EK)

* The public EK should be signed into a certificate by the manufacturer
* The public part of the SRK is established when a new user takes ownership of the machine
  * May be re-initialized when the platform passes to a new owner

__Building a Chain of Trust from Roots of Trust__

* One approach is authenticated (measured) boot process:
  1. At power on, RTM records its own identity (measurement of its own code, or an identifier)
  2. Before each part of the boot process:
    1. RTM takes a measurement of the next component to execute, passes control to the component
    1. Repeat for every component in the boot processes

* This is called a __static RTM__... Used traditionally, not so great for many reasons
  * Large number of components in the boot chain
  * Components are subject to frequent change (patches, firmware updates)
  * Components might be executed in different order
  * Performance penalty in the early boot process

* Another approach is a __dynamic RTM__:
  * Also known as a late launch of the measured environment
  * A special CPU instruction invokes a major change in platform state
  * This loads a fixed piece of code from a trusted source, stored in a safe place
  * This code then measures and nominates a white-listed piece of software
  * Platform jumps directly into a trusted state (measured launched environment)

* The fixed piece of code is stored in the TPM's "Platform Configuration Registers"
  * Special shielded locations
  * Can be directly read, but no arbitrary writes
  * Expose one write operation, called "Extend"
  * Extend updates a PCR with a hash of input value + previous hash of the PCR

* A particular PCR can be placed into a given state only by a specific sequence
  of extend operations. We want to arrive at a known good value for that PCR

* Just PCR + "Extend" is not enough. We need to protect against spoofing attacks by rogue drivers.
  * "TPM Quote"  operation returns a signed copy of nominated PCR's protected by
    a challenge-response nonce
  * TPM can use asymmetric crypto to "seal" a value and only mark it for
    decryption when PCRs have reached a given state

* Both of the above mechanisms rely on protected storage established using the
  master key in the RTS

__Management of TPM Keys__

* Keys can be migrated between TPMs using protect protocols
  * Required for group work, passing privilege, maintenance, upgrade, etc.

* Some keys can be marked as prohibited from migration or can only be migrated
  under certain conditions such as a special backup procedure

* TPM implements strong key generation capabilities, based on a true random
  number generator

* TPM also includes monotonic counters which can substitute for a real-time clock
  for challenge-response and signature generation

__Remote Attestation and Privacy__

* Remote attestation is based on the RTE (stores a uniquely-identifying private
  key for attestation, the EK)

* Credentials (e.g. certificates) associated with the EK are proof for third
  parties to identify our platform
  * In pure software implementations, these credentials may be missing or offer
    weaker guarantees
  * Note: No central authority here, up to the communicating party to decide
    which credentials are appropriate

* Important note on privacy: The EK can't simply be used to sign each PCR Quote
  operation, or it would be trivial to track all remote interactions from
  a given platform

* Instead, TPM provisions for the creation of any number of "Attestation Identity Keys"
  * These keys are then used as signature keys
  * EK is not allowed to be used directly as a signature key

* To generate AIKs:
  1. Generates a key pair
  2. Runs a protocol with a privacy CA, demonstrating its identity using the EK
  3. The TPM then obtains an AIK certificate, which binds a key to a trusted
     platform, but does not reveal which trusted platform
  4. Fresh AIKs can be generated as often as required

* Another protocol, DAA (Direct Anonymous Attestation) can be used instead, with
  even stronger privacy requirements

### Mobile Phone

### Virtualized Platforms

* Use dynamic RTM to launch a measured VMM (Virtual Machine Monitor)
* Then measure the virtual machine itself before instantiating it
* This dramatically shortens the chain of trust for a given virtual machine

* We run into issues here when we expect a mutating persistent state for a given VM
  * But for applications where the VM is expected to launch in the same state or
    when it is only launched once, this is a good approach

* TPM can also protect the VM from the host OS
  * Assert that VMM can only start, stop and allocate resources for VMs
  * Then the VM itself is protected from a malicious or semi-honest host OS
* This approach can result in additional complexity
  * Virtual TPM must be bound in some way to a physical TPM
  * Virtual machines might also be expected to migrate between hosts

### Impact of Trusted Computing

### State of the Art

### Active Research


## Hardware-Based Trusted Computing Architectures for Isolation and Attestation


### Attacker Model

* Attacker is in control of all software, excluding software in the TCB
  * AFAIK, the TCB here is _not_ the same TCB as we consider in OS security
  * Rather, the TCB is in the context of the secure enclave itself
  * (In addition to some external forces, like other devices connected to the shared LPC bus in TPM)

* Attacker is in control of the communication channel to the device
  * Snooping, modifying traffic
  * Man in the middle attacks
  * This is important for attestation (we need to provide
    spoofing/tampering/replay resistance, e.g. with a nonce or timer)

* Dolev-Yao attacker model
  * Attacker _cannot_ break crypto primitives
  * Attacker _can_ perform protocol-level attacks
  * E.g. an attacker can't defeat the security assumptions of an HMAC but they
    can attack it if it is _used incorrectly in a protocol_

* We ignore DoS attacks (because our PMAs cannot provide availability guarantees)

* Any PMA without memory protection considers physical attacks out of scope
  * But those with memory protection should defend against such attacks

* As with physical attacks, software side channel attacks may or may not be addressed
  * E.g. an attacker can leak information by monitoring memory or cache access patterns of an enclave

### Security Properties of PMAs

__P1. Isolation__

* Hardware-based mechanism
* Provides access control for software and its associated data

* Placing code and data into a protected module -> no other software can
  read/write its runtime state or modify its code
  * This includes the OS running in ring 0

* Execution of isolated code can only happen from a single pre-defined entrypoint
  * Otherwise execution of the memory region is turned off
  * This defeats attacks like ROP and other CFI-related attacks

* Protected modules store secret data as well such as secret keys
  * Other software can't access the PM's state, so these secrets are protected
  * Writes are also prevented from outside the PM, so integrity is preserved

__P2. Attestation__

* Use measurement to assert state of a given entity
  * This measurement can happen during initialization for example
  * Building a chain of trust from boot or dynamically at runtime

* Attestation guarantees should be a superset of integrity guarantees
  * i.e. the integrity of the underlying state must also be guaranteed

__P3. Sealing__

* Wrap confidential code such that it can only be unwrapped under certain circumstances
  * e.g. once an entity has entered into a specific measured state

* Sealed entities can be bound to:
  * Configuration
  * Software state
  * Specific device
  * Some combination of these

* Sealing is usually based on encryption with a key derived from the measurement
  taken during attestation

__P4. Dynamic Roots of Trust__

* Trust chains need to be anchored at a root of trust

* Static RoT can result in long chains and be difficult to implement in practice due to
  variations in execution order, other runtime parameters, and prohibitive runtime cost

* Dynamic RoT helps by measuring a trusted module right before it starts execution
  * This reduces the length of the chain of trust

* Need to protect against TOCTOU vulnerabilities, so this is typically combined
  with isolation (to prevent an attacker from changing module code after it has
  been measured)

__P5. Code Confidentiality__

__P6. Side-Channel Resistance__

__P7. Memory Protection__

### Architectural Features of PMAs

__F1. Lightweight__

__F2. Coprocessor__

__F3. HW-Only TCB__

__F4. Preemption__

__F5. Dynamic Layout__

__F6. Upgradeable TCB__

__F7. Backwards Compatibility__

### Architectures

__AEGIS__

__TPM and TXT__

__TrustZone__

__Bastion__

__SMART__

__Sancus and Soteria__

__SecureBlue++__

__Intel SGX__

__Iso-X__

__TrustLite__

__TyTan__

__Sanctum__
