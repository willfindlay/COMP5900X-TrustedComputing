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
  * An environment that has been measured during its initialization
  * Relies upon the RTM to bootstrap trust in the measurement

* Platform Configuration Registers (PCRs)
  * Used in TPM to store the evolving state of an entity
  * PCRs are world-readable but only expose one update operation
  * Update operation, called "Extend" updates the PCR using a combination of the
    hash of its prior state and the hash of the input

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
    a challenge-response nonce -> Quotes are used for remote attestation
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
  * Network of nodes
  * Attacker _cannot_ break crypto primitives
  * Attacker _can_ perform protocol-level attacks
  * Attacker can eavesdrop, intercept, and synthesize network traffic
  * Attacker is computationally bounded, with no access to individual nodes
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



## Lecture 1

* Something he repeated several times, may be important:
  * Secure boot is not part of trusted computing

### Course Overview

* Trusted computing is not that new
  * But it's not so well-known compared to other security domains

* Hardware is evolving -> results in new factors which were not taken into
  account in the original paradigm

* We'll also cover new attack vectors / factors to be considered in this area,
  so we can stay up to date

* We'll be examining the execution of a computer program

* This course is _not_ dedicated to computer security in general -- we are
  focusing specifically on execution security

### Grading Scheme in Detail

* In class test
  * Open-book
  * Basic concepts + understanding of trusted computing
  * Multiple choice + short answer + true or false (CuLearn)

* Assignment
  * A survey paper
  * Just a few pages

* Paper discussion
  * Carefully read and understand selected paper
  * Make a few slides, lasting for at least 30 minutes
  * Explain what the paper is about + your own opinions e.g. strengths and
    drawbacks (Very Important)

* Project
  * Roughly double the number of pages compared to the assignment
  * Research-paper-like writeup

* Participation

### Questions to Answer

1. What is trust?
2. What is a program in execution faced with?
  * What attack vectors?
3. What are the advantages of hardware support?
4. Where is hardware security support still failing?
5. How can we improve trusted computing?

### Trusted Computing vs Endpoint Security

* Scope to protect

* Assumptions
  * E.g. AV tool assumes userland adversary

* How can we bootstrap trust?

### Why Hardware?

* Stronger threat model assumptions
  * Immutability
  * Changing requires physical access
  * Controls everything

### x86 Stuff

* Userland is ring 3, OS is ring 0
  * We say the hypervisor is ring -1, but really it's also ring 0

* SMM -> system management mode
  * We consider this ring -2

* ME -> management engine
  * We consider this ring -3

* Microcode has omniscient view of the system

### Trusted Execution Environment

* Coined by GlobalPlatform

* Properties
  * Hardware support
  * Isolation
  * Measured launch
  * Secure storage
  * Attestation

### TCB

* TCB is the set of hardware/software that is critical to security goals,
  designated as trusted, and always assumed so

* Three properties:
  * TCB compromise must lead to security failure
  * May or may not participate in achieving the security goals
  * Non-TCB compromise must not harm security goals

* This set should be minimal
  * Maintainable
  * Auditable/verifiable

### Static vs Dynamic RTM

* Chain of trust from boot is static

* Dynamic means you can reset RoT at any time (late launch)
  * e.g. in TXT you call the TXT enter instruction

* SRTM PCR values start at -1
* In TXT, this gets reset to 0
* So we can always tell if we are basing our trust on SRTM or DRTM

### Revisiting What TEEs Provide

* Isolation
* Measured launch
* Secure storage
* Sealing
* Attestation



# Week 2

## SafeKeeper: Protecting Web Passwords Using Trusted Execution Environments

Two components:

* Server-side
  * CMAC taken over passwords, backed by keys secured in a TEE
  * Computation of CMAC also occurs in the TEE itself
  * Rate-limiting to defeat guessing attacks
* Client-side
  * Browser extension acts as a remote verifier
  * Signals to the user when the backend server is using SafeKeeper
  * Establishes a secure connected with the backend server

* Key difference from existing methods:
  * We _don't_ need to identify the remote server
  * We only need to be assured that the _correct software configuration_ (e.g.
    Running a good version of SafeKeeper) is available on the remote server

### Storing Passwords

* SafeKeeper uses CMAC (cipher-based MAC) to add an extra layer of protection to
  password storage

* Without the key, attacker's can't really verify password guesses offline if
  they steal the database

* The key is protected in hardware, so really the attacker is out of options

* Need to defend against online guessing attacks as well
  * Even online attacks mounted from the server side
  * Therefore, enforce rate limiting for a given password within the TEE itself

### Intel SGX

* Software enters an enclave using a special CPU instruction
  * The enclave code goes through a measured launch, measuring code and configuration
  * Measured value is stored as `MRENCLAVE`

* Enclave data is stored primarily in an enclave page cache, only accessible to enclave code
  * When data is paged into DRAM, it is encrypted with a key known only to the CPU

* Data can be sealed via encryption such that it is only accessible from
  enclaves on the same CPU with the same `MRENCLAVE` measured launch value

* Quote operations allow the enclave to produce an `MRENCLAVE` value signed with
  its public key
  * Verifier can validate this quote using Intel Attestation Service (IAS)
  * Then they can establish an encrypted channel directly to the enclave

### Related Work

__How SGX Enclave-Based Solutions Deal with Offline Guessing__

* Most proposals either encrypt or take an HMAC
  * But they all assume a trusted server
  * No consideration for password confidentiality in software (outside of the enclave)

* SafeKeeper is different because it uses a CMAC calculated in the TEE
  * Neither the key nor any information about the key ever leaves the TEE
  * Establishing a secure connection directly to the enclave basically makes the
    rest of the system completely unaware of the actual password

## Bootstrapping Trust in Commodity Computers

* Not looking at trusted computing specifically

* Rather, considering the older area of bootstrapping trust
  * Trusted computing could be considered a newer subset of this area

Some important issues:

* Foundation of trust
* Usability issues w.r.t. conveying computer state to humans

### Secure Boot

* Measure each step in the boot process
  * Abort the boot if we observe an incorrect measurement

* Authorization requires a signature from a public trust authority
  * The authority's public key would be embedded in firmware

* The user can verify that their system booted securely merely by checking
  whether boot was successful

* The remote party can only verify that the computer has been booted into an
  authorized state
  * It cannot learn precise details about that state

### Storage Access Control via Code Identity

* Use case: long-term protection of secrets

* IBM 4758 uses software privilege layers to store data
  * Higher levels cannot access lower levels
  * Physical tampering with the device results in erasure of secrets (presumably
    by discarding an encryption key?)

* TPMs use:
  * Sealing produces a ciphertext that includes PCR state, takes place __on the TPM__
  * Binding produces a ciphertext that does not include PCR state, takes place __outside the TPM__
  * Sealing can be used to verify integrity, binding cannot
  * But both require the correct PCR state in order for decryption to occur

* To prevent replay attacks (on sealed/bound ciphertext), TPM includes
  a monotonic counter, but application developers must take care to use this
  counter properly

### Remote Attestation

* Secure boot model does not capture enough information to inform a remote party
  * TODO: Is this why Viau doesn't consider it a trust trusted computing technology?

* Full co-processors can store historical configuration changes, wiping secrets
  only when an epoch changes
  * TODO: Figure out what the actual difference is when deciding whether an
    update is a configuration change or an epoch change

* TPMs only rely on measurements during the current boot cycle (no information
  from previous boot cycles is preserved)
  * Less flexible

* How TPM attestation works:
  * TPM generates an AIK key pair, with the public portion known to the verifier (e.g. Intel servers)
  * Verifier supplies a nonce to the attestor (prevent replay attacks)
  * Ask the TPM to generate a Quote (digital signature covering the nonce, PCR state)
  * Attestor sends the quote + the PCR state to the verifier
  * Verifier checks the signature against its nonce and the list of known-good PCR states

### Reboot Attacks (AKA Reset Attacks)

* Basically a TOCTOU attack
* Physically co-located adversary waits until the verifier receives an
  attestation, then reboots the machine into a malicious software image

* Mitigating this attack requires binding ephemeral keys to currently executing software
  * Rebooting destroys the trusted communication tunnel, preventing the attack

### How to Link Code Identity to Secure Channels

* Include a measurement of the public key in an extend operation
  * Now the public key is also reflected in the TPM's PCRs

### Privacy Concerns

* Binding a unique identity to a piece of hardware results in privacy concerns
  * User does not want to be uniquely identifiable by any third party

#### Identity CAs

* TPM generates an AIK associated with a pseudonym
* Then a trusted third party (Privacy CA) verifies the correctness of the
  user's hardware using the public part of an EK (stored in the TPM's
  hardware) and issues a trust certificate corresponding with the pseudonym

#### Direct Anonymous Attestation (DAA)

* DAA is completely decentralized (unlike privacy CAs)
  * Uses a group signature scheme
  * But with no privileged group manager (anonymity can never be revoked)

* An adversary's credentials can be invalidated without ever learning the
  adversary's identity

* Use zero-knowledge proofs to interact with the verifier

### Knowing Platform State vs Trust

* Just because you know platform state doesn't mean you can trust it
* Systems are complex  and unverifiable
  * There could be lots of buggy software in a given configuration

* OS and application code changes rapidly over time, meaning:
  1. we need to constantly update expected measurements and;
  2. we have no guarantees that updates don't introduce new vulnerabilities

* "State-space explosion"

#### Techniques to Solve This

1. Privilege layering
  * Record the launch of a long-term core (e.g. and SELinux kernel)
  * Bind secrets to the long-term core
  * Now verify that the enforcer is configured with the correct policy
2. Virtualization
  * Virtualize workloads using virtual machines
  * Measure the VMM which launches the VMs
3. Late Launch
  * Start measurement at a later point, for example at the point when a VM is launched
  * A special instruction can reset platform state before measurement
  * This greatly shortens the chain of trust, focuses on more security-relevant code
4. Code Constraints
  * Enforce CFI using inline reference monitors (can be dynamically injected into code)
  * Then measure the integrity of that code
  * We now only need to verify that the inline reference monitors are correct
5. Outsourcing
  * Outsource the problem of interpreting code to a trusted third party
  * E.g. obtain certificates from software providers
  * Include certificates with attestation

### Roots of Trust

* Typical basis for root of trust:
  * Private key stored securely in hardware
  * Trusted third-party is in possession of the public component

### Cuckoo Attack

* When malware on a trusted platform forwards the attestation request to another
  attacker-controlled platform, which "confirms" the request

## Lecture on Discussion Leads / Paper Reading / SafeKeeper

### Assignment

* At least four pages (Individual Work)
* 3 to 8 academic papers to write a survey about
* Topics must be closely related to trusted/secure computing
  * Applications
  * Improvements
  * Academic Proposals
  * Attacks (A bit tricky, make sure that they do fall into one category; the way you survey attack papers is different -- look other aspects besides defence)
* Systematic comparison, analysis, or reasoning
  * This is the purpose, why we need to examine these works
  * Go through each paper briefly, perform an analysis
  * How they achieve their claimed purpose, what can be improved, is there anything interesting
* For full marks, provide some insights
  * Novel opinions, not mentioned or known in the community
* Due Feb. 23 (after Winter break)

__Format__

* At least 4 pages in length
* Single-spaced, single-column, 10-point, margins <= 1 inch
* Title, name, student number

__Plagiarism__

* Copy-and-paste is strictly prohibited
  * This includes figures
* Read/understand first then write own text

### Preprocessing a Paper

* Title, Venue, and Authors
* Type of paper:
  * New system/method
  * Attack paper
  * Survey/SoK -> (SoK is more in-depth, more focus on evaluation/opinions)
  * Position paper
* Paper structure:
  * Abstract
  * Threat model / preliminaries
  * Design
  * Implementation
  * Evaluation
  * Related work

### Goals

* Problem statement
* Claims/Contributions
* Mentioned in Introduction/Abstract or a separate section

* For SafeKeeper
  * To protect the secrecy of web passwords
  * Protect against phishing, password database theft, including rogue servers
  * Does not require users to correctly identify the server

### Threat Model

* Trusted

* Not Trusted
  * Malicious
  * Honest But Curious

* Assumptions

### Well-Motivated?

* Why is this proposal needed?
* Related Work
* What can go wrong without it?
* What can go better with it?

### Design/Implementation

### Evaluation/Validation

* Effectiveness
  * Security analysis (reasoning, couple with scope of the paper, threat model)

* Efficiency
  * Overhead compared to base operation of the system
  * Micro- and macro-benchmarking

* User Study (if applicable)
  * Is a user study needed? (Are human factors involved?)
  * Ethical approval

### Attacks? / Improvements?

* Open discussion
* What did the paper do well, and what did it not do so well
* Are there glaring issues with the paper? With the artifact?

### Other Aspects

* Adoptability/How easy it is to migrate

## Lecture on Discussion of Trust / Important Concepts

* When we talk about trust, we may not be talking about the same thing
  * At least __properly define what trust means__

* Viau: Use _trustworthy_ instead of _trusted_ in some cases
  * Instead of "trusted" computing, we really mean "trustworthy" computing

* Trusted means in practice:
  * An entity can be trusted if it always behaves in the expected manner for the
    intended purpose
  * Orthogonal to "secure"

* Trusted can also imply:
  * Having to be trusted (no other choice)
  * Exempted from further checking

* Trustworthy means:
  * Something is _deserving_ of our trust

### Building Blocks for Trustworthiness

* Abstraction
  * Lower-layer advantage
  * Virtualization, OS processes, containerization, interpreted languages

```
------   ------
|    |   |    |   Lower priv
------   ------
---------------
|             |   Higher priv
---------------
```

* Principle when developing a security solution targeting some layer:
  * Go one level down

* Privilege (Access Control)
  * Some other party is enforcing this (not intrinsic like abstractions)
  * Designated level of access
  * E.g. segmentation and x86 protection rings
  * Page table access (MMU)

### Privilege

* Unlike SMM, Intel ME has a dedicated processor, RAM, and I/O
* Enables Intel AMT -> Remote management, runs a full-fledged OS as long as PSU is on (possible MINIX)
* Kind of a double edge sword
  * New security threats

* One more thing on x86
  * ME -> management engine, fully closed
  * IE -> innovation engine, third-party applications

* Application Processor (AP) vs Base Band Processor (BBP)
  * Application code runs in AP
  * Base band is comparable to Intel ME

* Categorization of primitives:
  * Where does the code run
  * Where is the main memory
  * Code storage (LTS), where does it load code from

### Trusting the OS Leads to a Weak Model

* Bloated TCB
  * All kernel code
  * Lots of userspace code
  * Anything running as root, SUID

* What about the compiler?

* What about the web browser?

### Attack Vectors

* A method or pathway through which something can be attacked

* Specific to an attack goal

* How/where can Trusted Computing tech fail?

### Attack Vectors

* Refer to theme figure for this course

* Vector examples:
  * Initial integrity compromise -> Measured launch
  * Memory corruption attacks
  * Rollback attacks
  * Insecure I/O
  * Side channels

### Direct Manipulation

* We should exclude this from our threat model in TC

* Inadequate abstraction

* Design flaw vs implementation error

### Initial Integrity

* Trusted source
  * Hardware (trusted vendor, assumptions?)
  * Software

* Proper loading
  * Measured launch

### Side Channels

* Timing

* Electromagnetic

* Power analysis

* Acoustic

* __Micro-architectural__

### Covert Channels vs Side Channels

* Side channel means leaking information
* Covert channels means two cooperating parties
  * Establish a covert channel for communication
* Something needs to be introduced by an attacker

### Micro-Architectural Side Channels

* ISA -> Instruction Set Architecture
  * x86, x64, ARM (thumb, regular, etc.), RISC-V

* But what is a _micro_ architecture
  * Specific implementation of an architecture
  * Architecture doesn't specify _everything_: specific implementations may vary a lot

* The side channels here:
  * Because the specification does not specify enough, vendors have the freedom to improveise
  * That part is not properly abstracted away, we can exploit it
  * E.g. cache timing side channel attacks (miss vs hit differs in latency)

* So micro-architectural is sub-architecture

## Notes for me:

Things to look up:

* SMM in more detail
* Intel ME in more detail
* Intel AMT in more detail

# Week 3

* https://www.usenix.org/system/files/conference/osdi16/osdi16-arnautov.pdf

* https://www.usenix.org/system/files/conference/atc17/atc17-tsai.pdf

* https://dl-acm-org.proxy.library.carleton.ca/doi/pdf/10.1145/2660267.2660350

# Week 4

## Lecture: Side Channels

- One of the main attack vectors we have introduced

### Definition

- Originates from a cryptography term
  - Secret extraction from unintended channels
  - Key word is _unintended_
  - Side channels are _out of band_, a separate channel, not intended for communication
  - Created by the adversary -> covert channel

- Side channels vs covert channels
  - Side channel means an existing but unintended channel
  - Covert channel means the adversary creates it intentionally (but it's still unintended from the user/vendor/protocol perspective)

- Compare with implementation errors

### Back to Abstractions

- Attenuation of information from a certain interface
  - Expose the minimum needed information

- Creation of new interfaces/artifacts
  - E.g. clflush instruction to flush the cache lines

- E.g. cache memory
  - From the hardware's perspective, it's just very fast memory -> high performance, low capacity
  - Unlike main memory, __we cannot address it__
  - Cache existence is abstracted away (we address main memory, and it might be a cache hit and it might not)
  - Expose the minimum that is needed

- E.g. virtual memory
  - Process has its own view of the address space
  - Can see more memory capacity than we physically have
  - We can even see disk space (swapping, disk I/O) as memory from the process' perspective
  - The exposed new interface is almost the same as the original

- E.g. device drivers
  - Different classes of USB
  - The operating system exposes an interface for interacting with the USB, regardless of model and how it's connected
  - Abstraction can help to avoid extra refactoring (since we agree to comply to an interface specification)

- Specification
  - Define how an interface should act, how we can interact with it

- Recall, unspecified parts of the interface lead to side channels

### Computer Architectures

- Instruction Set Architecture (ISA)
  - A specification of an abstraction (abstraction over the micro-architecture)
  - What we expose to software: instruction set

- CISC vs RISC
  - CISC = complex instruction set computing, can have variable byte length instructions
  - RISC = reduced instruction set computing, simplified

- ISA is the interface between hardware and software
  - Architecture specification defines this interface
  - Registers, instructions, memory addressing

- Micro-architecture
  - The actual specific implementation of an ISA
  - Vendor-specific and model specific
  - Can be _very_ diverse
  - Vendors comply with the ISA, but want to have differences underneath

- The same pattern is reflected in TEE implementations
  - Vendors add special instructions on top of the ISA to support their TEEs
  - E.g. SKINIT and SENTER

- C runtime calls a CPUID instruction implicitly to check for vendors-specific extensions

### Micro-Architectural Attacks

- Root cause:
  - The architecture does not (and cannot) specify everything
  - The missed falls into micro-architectures

- Timing-based attacks are very common in this category

- Not all micro-architectural artifacts pose a threat

- Not all "micro-architectural" attacks involve a "micro-architecture"
  - Could be even lower than the micro-architectures
  - Applies to anything beneath

- Side channels:
  - To steal information (i.e. reads)

- Fault attacks:
  - To affect machine state (i.e. writes)

- Implication: MA side channels imply software-only (also, remotely executable)
  - E.g. cold boot attacks freeze RAM model and plug into another machine
  - This is not micro-architectural, since it's a physical attack
  - Would be weird to call this micro-architectural

### Fault Attacks

- To inject faults into the machine state (in a deterministic manner, under our control)
  - Non-deterministic fault injection would just be a DoS attack

- Rowhammer attacks
  - Flip bits in DRAM by repeatedly accessing adjacent rows
  - Physically influence the adjacent row, triggering some controllable effects
  - Is this micro-architectural? Viau says yes, even though it doesn't directly impact the CPU itself

- Undervolting
  - CPU cores operate at a certain voltage 
  - If we maintain the right voltage, it works, otherwise it might fail
  - There is a threshold in between from working to failure\
  - If we are close to the threshold, the CPU doesn't directly fail, it just faults

### Micro-Architectural Side Channels

- The ISA does not specify timing characteristics

- Generic mitigation for timing side channels
  - Make computation time constant for the same function across all platforms
  - This is would be a huge performance loss

- One stage:
    - Micro-architectural -> Architectural

- Two stage:
    - Channel exposure
    - Micro-architectural -> Architectural

### A Few Start of the Art

- Cache side channels
  - Timing cache access (hits or misses)
  - Prime+Probe, Flush+Reload, Evict+Reload, etc.

- Translation Lookaside Buffer (TLB)
  - Similar to regular cache, but for address translation
  - Caches virtual to physical mappings in the MMU
  - TLBleed

- Execution engine ports
  - Timing the contention latency of execution engine ports
  - Figure out what instructions are being executed
  - PortSmash

- Interrupt handling latency

### How Cache Memory Works

- Set-associative cache
  - Divide cache memory into cache sets, corresponding to the number of blocks in main memory
  - Each memory block corresponds to a cache set, which has a certain number of cache lines

- Main memory is way bigger than cache memory
  - We need to a one to many mapping
  - Certain bits of the address determine which cache sets / lines it goes to

### First Type of Cache Side Channel: Evict and Time

- Prime the cache set by invoking the victim function

- Time the victim function

- Evict the cache set (fill it up)
  - Mapping to different memory blocks
  - Do some operations involving the cache set in our memory block

- Invoke the victim function again and time it
  - Was it slower? If so, was not accessed since when we evicted it

- Pre-condition (invoking the victim function) is not so easy to satisfy

### Second Type of Cache Side Channel: Prime + Probe

- Prime the cache set with your own function

- Wait for the victim to execute (which will evict the set you primed)

- Re-access the address in step 1 and time your own function
  - Lowers the bar for mounting the attack

### Third Type: Flush + Reload

- Flush a cached address (with the clflush instruction)
  - Requires shared memory or memory de-duplication
  - Advantage is that it's very specific (at the granularity of the cache line)

- Wait for the victim function to execute

- Reload the saved address in step 1

### Summary of Requirements

- evict + time
  - function invocation

- prime + probe
  - wait

- Flush + Reload
  - shared memory

### Out of Order Execution

- As long as the programmer can't tell the difference in the end, we have no _architectural effects_

- But these can produce micro-architectural effects
  - Adversary can then use a side channel to convert to architectural

### Speculative Execution

- Branch predictor

- Recorded dynamic history of code executing

- Take a speculated path and correct later if wrong
  - Adversary can mistrain the branch predictor to coerce it to take a certain (incorrect) path

## Jonathan: Meltdown Discussion Lead

- Address is loaded into a register, not accessible but the micro-architecture accesses it still

- Viau: trade-off between performance, security, and cost

- Viau:
  - Limitations on attack papers are expected 
  - We need to fix the root

- Viau: Foreshadow
  - Made a video where they show how they could quickly extract data from the SGX enclave
