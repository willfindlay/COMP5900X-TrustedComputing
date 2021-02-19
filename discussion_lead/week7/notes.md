# Goals

- Attackers want to use memory corruption techniques to circumvent CFI guarantees (e.g.~code re-use attacks via buffer overflow, ROP, JOP)
- Recall the theme figure for the course -> Memory corruption attacks happen inside the isolation bubble

- Hardware assisted tracing technologies can log complete application control flow
- Designed for offline debugging, but can be re-applied for online CFI
- Intel PT is an example of one such hardware assisted tracing technologies

- Griffin wants to examine how hardware assisted tracing can be used to improve application security by implementing hardware-backed CFI

# Threat Model

# Memory Corruption Attacks

# Control Flow Integrity (CFI)

# Intel Processor Trace

# Design

- coarse-grained policy

- fine-grained policy

- stateful policy

- combination policy

# Implementation

- big problems with JITed languages
  - JITed code can change over time, meaning that Griffin might use outdated basic blocks when constructing control flow
  - to get their system to work, they needed to refactor existing JIT compilers
  - this is a _huge_ drawback for transparency
- modifications they made:
  1. code retirement
    - prevent poisoning of unneeded code (any security implications? why did Firefox do that in the first place?)
    - defer page reclaim on unmapped executable pages
  2. incremental garbage collection
    - make inserted jmp instructions permanent

# Case Studies

# Evaluation: Performance Overhead

# Evaluation: Memory Overhead

# Evaluation: Security

# Alternative Logging Approaches

# Comparison with Related Work

# My Own Thoughts

# Discussion Questions
