# Week 1 Notes

* The ten-page introduction to Trusted Computing
* Hardware-Based Trusted Computing Architectures for Isolation and Attestation


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
  a) High confidence in state of the local system
    * Configuration, running software, etc.
    * Local attestation?
  b) High confidence in the state of a remote system
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
  a) trusted systems (systems that we trust)
  b) trustworthy systems (systems that deserve our trust)
  c) trustable systems (systems that can be trusted)

* Trusted Computing is probably better defined as Trustable Computing

* Proudler's criteria for system trustworthiness:
  a) unambiguously identifiable
  b) unhindered operation
  c) user has first-hand experience of consistent, good behaviour or trusts
     someone else who attests to this

* How to build an expectation of good behaviour?
  * Proofs of correctness
  * Proofs are more useful in theory than in practice
  * Modern systems are too complex to be totally formally verifiable

* Surrogates for proofs:
  a) Testing
  b) Long-term use experience
  c) Third-party evaluation, certification, etc.

* TCG's definition (not the best):
  * "An entity can be trusted if it always behaves in the expected manner for
    the intended purpose"

## Hardware-Based Trusted Computing Architectures for Isolation and Attestation


