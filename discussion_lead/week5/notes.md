# Spectre Paper Notes

# The Basic Idea

- Branch prediction and speculative execution let us cut corners for performance
  - For example, if the destination branch depends on a memory value that is being read, the processor can speculatively execute that branch
  - Either use or discard the result depending on the memory value

- The problem:
  - Attackers can abuse incorrect speculative execution to leak information, even outside of normal program control flows

- Underpins a lot of base security assumptions in:
  - OS process separation
  - Containerization (OS-level virtualization)
  - JIT compilers
  - Access control
  - Countermeasures against other side channels

-  Affects all Intel, AMD, and ARM processors without proper mitigations

- Countering Spectre:
  - Soft processor-specific counter measures
    - In firmware
    - In software (e.g. BPF JIT compiler patch in Linux)
  - A full solution requires making changes to processor designs and ISA specifications
    - Need a standardized model of what CPUs can and cannot leak (i.e. what data is sensitive data? Not a trivial problem to solve)

# Academic Paper Reading (Viau)

- Title: Spectre Attacks: Exploiting Speculative Execution
- Venue: Oakland 2019
- Authors: Kocher, Horn, Fogh, Genkin, Gruss, Haas, Hamburg, Lipp, Mangard, Prescher, Schwarz, Yarom
  - Google, G Data, Academics, Cyberus, Rambus Crypto Research, Data61
  - Large collaborative effort between academia and industry
- Type: Attack Paper

## Goals

## Threat Model

## Well-Motivated?

- Affects a *lot* of existing CPUs
  - TODO: List examples from the paper?
  - Might be cute to have pictures of them all piled up as a figure

## Attack Overview

- *Transient instructions*: Incorrect speculative execution instructions that are discarded
  - Attackers want to find transient instructions that can leak sensitive data
  - Can be done via static or hybrid analysis

- Three components to a Spectre-style attack:
  - Identifying transient instructions that can leak sensitive data
  - Mis-training the CPU branch predictor (involves exercising potentially strange codepaths)
  - Using a side channel to leak information from transient instructions

- Paper covers two main variants:
  1. Conditional branches (if-statements)
    - Train the CPU that the if-statement will be true
    - Then execute with a value that would make it false
    - Use a cache side channel to leak data from the "true" prediction
  2. Indirect branches (ROP-style)
    - Identify gadgets
    - Train CPU to speculatively execute the gadget (BTB: Branch Target Buffer)
    - The gadget itself is now the transient instructions
    - Advantage over ROP: we don't rely on a vulnerability in the victim code (but we do rely on the presence of such a gadget)
  3. Other variants
    - Vary method of achieving speculative execution (training + transient instructions)
    - Vary method used to leak information (e.g. other side channels, such as timing-based)

- Differences with Meltdown:
  1. Meltdown does not use branch prediction
    - Instead, Meltdown relies on out-of-order execution as a result of traps caused by instructions
  2. Meltdown exploits a vulnerability specific to Intel/ARM that allows some speculatively executed instructions to bypass memory protection
- Combining the above two points allows Meltdown to access kernel memory from userspace
  - Access causes a trap, but out-of-order instructions can leak the contents of access memory

- Spectre:
  - Works on a wider range of CPUs
  - Is unaffected by Meltdown-specific mitigations (KAISER)

- Flush+Reload/Evict+Reload side channel attacks:
  - Evict a cache line from the cache, shared with the victim
  - Measure the time it takes to perform a memory read at the address corresponding to the evicted cache line
    - If the victim has accessed the cache since we evicted, it will be in the cache again, and our access will be very fast
    - If not, our access will be slow
  - Primary difference between the two:
    - Flush+Reload uses a dedicated machine instruction to flush the line (100% reliable)
    - Evict+Reload involves forcing contention to coerce the processor to discard the line
  - Good video on flush+reload: https://www.youtube.com/watch?v=UmLB1EWelCw

## Mitigations

- https://software.intel.com/security-software-guidance/api-app/sites/default/files/Intel_Mitigation_Overview_for_Potential_Side-Channel_Cache_Exploits_Linux_white_paper.pdf

## Open Discussion -- How Good / Relevant / Important is the Paper? Issues / Improvements?

- Discussion questions could go here

- Attack scenarios presented are contrived
  - It's easy to see how the presence of shared libraries introduces significant risk, but it would have been nice to see a demonstration on a real victim application nonetheless

## Other Relevant Aspects

- Ethics:
  - Responsible disclosure: authors disclosed vulnerabilities to CPU vendors and other affected companies
  - Embargo of results (CVE from 2017, paper from 2019)
  - Did they do enough?

# Things to Look Into

1. What would be the performance hit if we disabled branch prediction / speculative execution?
  - I expect this would be quite large in practice
2. Find the quote from Linus Torvalds trash talking Intel (and CPU manufacturers in general)
3. BPF JIT mitigations for spectre-class attacks (from Alexei's talk at the BPF summit)
4. Can TC technologies manage the risk associated with Spectre-class attacks? Are they vulnerable to them?
  - My instinct tells me that they can't manage the risk and that they probably are vulnerable (at least the ones which are not based on a TPM chip)
5. Read about Flush+Reload and Evict+Reload cache-based convert channels

TODO: resume reading at "Indirect Branch Poisoning Proof-of-Concept on Windows" on Page 9
TODO: journal article based on this paper: https://dl-acm-org.proxy.library.carleton.ca/doi/pdf/10.1145/3399742
