# Key Terms

* Trusted Computing Base (TCB)
  * Components of the system that must be fundamentally trusted to bootstrap
    any form of trust in the rest of the system
  * If the TCB is compromised, the system is totally compromised

* Trusted Platform Module (TPM)
  * Hardware/Software module used to provide root of trust guarantees by integrating
    with the system architecture (via a physically embedded TPM chip)

* Measurement
  * Cryptographic hashing of system software/firmware components
  * Verify component state, integrity

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

* TCG's definition (not the best):
  * "An entity can be trusted if it always behaves in the expected manner for
    the intended purpose"

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

## Hardware-Based Trusted Computing Architectures for Isolation and Attestation


