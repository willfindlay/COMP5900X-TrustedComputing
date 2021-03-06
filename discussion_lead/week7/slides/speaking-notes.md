# Title Slide

(Skip this I think, it has same info as Paper Overview)

# Paper Overview (1)

- Today I'll be presenting the paper "Griffin: Guarding Control Flows Using Intel
  Processor Trace" which presents a new CFI mechanism based on Intel PT

- The paper was a collaboration between Xinyang Ge and Weidong Cui from Microsoft Research
  and Trent Jaeger from Pennsylvania State University
- The senior author, Trent Jaeger is quite well-known for his work in operating system
  security

- The paper was published at ASPLOS 2017, which is recognized as a flagship conference at
  the intersection between hardware, programming language, and operating system design

# Goals (2)

- The problem that Griffin is trying to solve is that of code reuse attacks, which involve
  attackers abusing memory corruption vulnerabilities to subvert an application's control
  flow

- Control flow integrity or CFI is a common defence against such code reuse attacks

- The vast majority of existing CFI defences are based in software but these are either
  inflexible or perform poorly in practice

- The Griffin authors argue that hardware-backed CFI can offer better security and
  performance while maintaining flexibility

- To rectify the gap in hardware-backed CFI implementations, the authors present Griffin,
  which is the first online CFI implementation backed by Intel Processor Trace hardware
  support

- Thanks to its implementation, the authors argue that Griffin's performance is comparable
  to software CFI mechanisms but with better security and flexibility

- Griffin offers multiple policy granularities for flexibility, providing defenders with
  the ability to choose between performance and security at runtime

- Finally, they discuss how minor changes to Intel PT's design could significantly improve
  performance for online CFI applications

# Threat Model and  Assumptions (3)

- In Griffin's threat model, they assume that the protected programs are trusted but that
  they might contain logic errors or memory corruption vulnerabilities that can be
  exploited by attackers

- They also assume that the operating system, including all ring 0 code is trusted
- Otherwise, an attacker could simply bypass or disable Griffin's enforcement mechanism

- This aspect of the threat model in particular makes the paper quite different from
  others that we've looked at this semester, which have generally assumed a powerful
  adversary with at least some control over the operating system

- What is specifically not trusted is any input into protected applications
- This input could be used to launch a memory corruption attack and, in turn, a code reuse
  attack, which is what Griffin wants to defend

- Finally, Griffin assumes that protected software already implements some form of data
  execution prevention

- In particular, this means that an application cannot modify its own code and that an
  application cannot map pages as both writable an executable

- This assumption precludes a number of attacks, such as code injection, that would
  obviate the need for code reuse and thus bypass Griffin entirely

# Motivation (4)

- The paper's primary motivation stems from the fact that the existing CFI design space is
  dominated primarily by software-only approaches which are typically either very slow or
  very inflexible in practice

- While there has been some academic work on hardware-backed CFI approaches, this area
  hasn't really been explored as much

- Existing hardware-backed proposals also typically incur prohibitive overhead or offer
  incomplete protection compared with their software-based counterparts

- The Griffin authors postulate that the reason for these limitations is that existing
  mechanisms are based on older and less efficient hardware technologies and that there is
  room in the literature to explore newer solutions

- Specifically, Intel Processor Trace is a promising option because it has a very limited
  base overhead of around 5%

- However, Intel PT is typically used for offline debugging and provenance

- Doing online CFI with Intel PT presents very different requirements and challenges and
  requires significant extra work, which is where Griffin comes in

# Memory Corruption / Code Reuse Attacks (5)

- Memory corruption and code reuse attacks are at the core of the problem Griffin is
  trying to solve

- The basic pattern is that an attacker provides some untrusted input to an application
  that triggers a memory corruption vulnerability, such as a buffer overflow or
  a use-after-free

- By corrupting specific regions of memory with specific values, the attacker can then
  subvert normal control flow and reuse specific parts of the application code to achieve
  some malicious goal

- For example, they might try to spawn a root shell, write data to a sensitive file,
  disable OS-level protection mechanisms, or something similar

- When dealing with these kinds of attacks, some defences target the memory corruption
  step, while others target the code reuse step

- In the case of Griffin, we are interested in the code reuse step

# Control Flow Integrity: Overview (6)

- The basic idea of control flow integrity is to identify the correct code paths for an
  application, generate a control flow graph, and enforce that control flow must follow
  the control flow graph at runtime

- Control flow integrity mechanisms can stop many code reuse attacks, depending on the
  sophistication of the attack and the granularity of the CFI policy

- At a bare minimum, they at least significantly raises the bar for attackers

- There are three primary categories for software CFI:
  1. Compile-time instrumentation
  2. Static binary instrumentation
  3. Runtime instrumentation

- I'll be covering the advantages and disadvantages of each in the coming slides.

# Compile-Time Instrumentation (7)

- In compile-time instrumentation, a compiler extension generates the correct CFG for
  compiled programs

- This CFG would then be enforced in the language runtime

- This is more efficient than other methods, and it is easy to capture stateful control
  flow since our instrumentation is tightly coupled with compilation

- However compile-time instrumentation is bound to a specific compiler toolchain

- And enforcement is fixed at compile-time, meaning there is no flexibility in runtime
  enforcement

# Static Binary Instrumentation (8)

- In static binary instrumentation, we use static analysis tools to generate a CFG for an
  existing binary and then binary re-writing for enforcement

- This has similar properties to compile-time instrumentation, but requires no compiler
  support

- Static binary instrumentation works on existing and legacy applications and works across
  multiple languages

- However, like compile-time instrumentation, static binary instrumentation is fixed, with
  no runtime flexibility

- It is also less accurate than compile-time instrumentation, since we can no longer rely
  on information provided directly by the compiler

# Runtime Instrumentation (9)

- In runtime instrumentation, we instrument and enforce the application at runtime

- Control flow policy can be generated or manually crafted, and modified at will

- In terms of benefits, runtime instrumentation is far more flexible than the other two
  categories

- It's possible to enable, disable, and change policy at runtime to balance security and
  performance impact

- Like static binary instrumentation, runtime instrumentation can support legacy binaries
  and would work across multiple languages and compiler toolchains

- However, runtime instrumentation can be orders of magnitude slower in practice

- Implementations that are not very slow tend to offer very limited protection in exchange
  for better performance

# Hardware-Assisted CFI (10)

- Unlike software-only CFI, hardware-assisted CFI can avoid instrumentation altogether by
  using hardware-generated logs to verify control flow

- This approach can avoid many of the limitations of software-only CFI

- Some examples of underlying technologies include Intel's Branch Target Store, Last Branch Record,
  the CPU's PMU, and Intel Processor Trace

- However, existing hardware-based CFI implementations either don't provide complete
  protection or incur unacceptable overhead

- Griffin explores a way to efficiently use Intel Processor Trace for CFI, which can
  achieve more complete protection without sacrificing performance or flexibility

- To achieve these goals Griffin relies on performance optimizations that are made
  possible by Intel PT

# Intel Processor Trace: Overview (11)

- Intel PT is a new hardware tracing feature supported all Intel CPUs manufactured since
  2013

- Originally, it was designed for offline debugging, but Griffin repurposes it for online
  control flow integrity enforcement

- Intel PT works by recording a minimal trace that can be used to reconstruct control flow

- These traces are recorded in a minified format called trace packets

- These trace packets encode indirect branch targets and branch taken indicators, along
  with some bookkeeping information

- For memory-efficiency, branch sources are not recorded, since it's possible to
  reconstruct these by analyzing trace packets in combination with disassembled binaries

- These trace packets are stored in contiguous physical memory regions, which allows Intel
  PT to avoid the cost of address translation in the MMU

# Intel Processor Trace: Trace Packets (12)

- Griffin primarily uses six types of trace packets

- Packet Generation Enable packets mark the start of a tracing sequence and record the
  instruction pointer value when the sequence started

- Similarly, Packet Generation Disable packets mark the end of a tracing sequence

- Taken Not Taken packets are used to mark which direct branches are taken in a sequence
  of direct branches

- For efficiency, these are stored at the granularity of one byte and therefore can store
  data for 6 consecutive branches with 2 bits of metadata

- A value of 1 means that a branch was taken, while a value of 0 means that it was not
  taken

- In order to determine which specific branches were taken, a program consuming the trace
  needs to infer them from walking the code within the region indicated by the PGE and PGD
  packets

# Intel Processor Trace: Trace Packets (13)

- Target Instruction Pointer packets indicate the target instruction pointer for an
  indirect branch, such as invoking a dynamic dispatch function

- As with Taken Not Taken packets, the branch source address would need to be inferred by
  taking the code and the trace together

- Flow Update Packets specify a source address for asynchronous events like the invocation
  of interrupt handlers

- Finally, Packet Stream Boundary packets encode a unique bit pattern that marks
  a location in the trace output

- These packets can be used as a point of synchronization between multiple workers
  processing a trace

# Design Overview (14)

- At its core, Griffin is a new hardware-assisted control flow integrity mechanism using
  Intel PT

- The idea is to trace control flow at runtime using Intel PT and compare it to some
  policy in memory

- To do this, Griffin takes trace packets in physical memory and the program binary as
  input

- At runtime, it disassembles and divides the program up into basic blocks

- which are essentially contiguous regions of code where branches can only be the entry
  point or exit point

- To derive the control flow, Griffin follows the trace packets and matches them with
  basic blocks

- Using a pre-determined control flow policy, Griffin can then verify whether control flow
  integrity has been violated

- The policy data for a given code page is stored at some fixed offset from the code page
  in the process' address space, so that it can be easily looked up in constant time

# Design Overview (15)

- The majority of Griffin's overhead comes from disassembling binaries at runtime and
  processing trace logs

- To help mitigate this, Griffin takes the approach of trading memory usage for
  performance, storing as much state as possible in memory

- Griffin offers four policy enforcement strategies for balancing security and performance
  1. Coarse-grained policy
  2. Fine-grained policy
  3. Stateful policy
  4. Combination policy

- It also supports switching the policy enforcement strategy at runtime to balance
  security and performance

- To do this, it measures the current backlog of unprocessed traces and uses this as
  a proxy for how much it is bottlenecking

- A threshold specifies the amount of trace memory that should be allowed to accumulate
  before switching to less secure policy

- Higher thresholds imply worse performance but better security, while lower thresholds
  imply better performance but worse security

# P1: Coarse-Grained Policy (16)

- Griffin's coarse-grained policy is the simplest out of the four categories, as it's only
  concerned with valid or invalid target addresses for indirect calls

- This means that there is no need to reconstruct control flow at all. A target IP value
  is simply marked as being valid or invalid, and this can be enforced directly using the
  values in the TIP packets

- This approach yields the highest performance, but lowest security of all the Griffin
  policy types

- To store coarse-grained policy, Griffin maps one policy page for every code page at
  a fixed 8 terabyte offset from the corresponding code page in the process' virtual
  address space

- To support dynamic libraries, Griffin tracks dynamic linking and maps additional policy
  pages at runtime for shared library code

- Whenever a program makes an indirect call, Griffin looks up the policy page
  corresponding to the target address and checks its value

- A value of 1 would mean that the call is allowed, while a value of 0 would mean that
  it's denied

# P1: Coarse-Grained Policy (17)

- This figure depicts the process of coarse-grained policy enforcement in Griffin

- Griffin processes the trace packets and disassembled binary to determine the control
  flow

- When the process makes an indirect call, it looks up the corresponding policy page at
  a fixed offset from the target

- In this case, the value is a one and therefore the indirect call is legitimate

- If the value in the policy page were a zero, the call would instead be classified as
  illegitimate

# P2: Fine-Grained Policy (18)

- Griffin's fine-grained policy extends coarse-grained policy to include information about
  source addresses

- To do this, Griffin stores a policy matrix instead of just policy pages

- Specifically, this policy matrix is a sparse M by N matrix that maps source addresses to
  legitimate targets

- For fast lookup, this matrix is stored at a constant location in the process' virtual
  address space

- The main problem with fine-grained policy is that Intel PT does not expose source
  addresses in trace packets

- Since it's designed for offline use cases, Intel PT prefers to prioritize low runtime
  cost, offloading as much overhead as possible to offline processing. By not exposing
  source addresses, Intel PT significantly reduces the memory overhead of its trace
  packets.

- This means that Griffin needs to recover the source addresses at runtime by walking the
  disassembled binary using information in the trace packets.

- This results in higher security but also much lower performance due to the overhead of
  reconstructing source control flow from the trace packets

# Optimization: Parallelization (19)

- Luckily, there are a few optimizations that can significantly improve the overhead of
  processing trace packets

- It turns out that processing individual traces is an embarrassingly parallel task

- An embarrassingly parallel task is a term that describes a task which can be
  parallelized without the need for workers to synchronize and communicate

- The basic idea here is that the output of one trace is entirely independent of another,
  which means that Griffin can assign multiple worker threads to work on different traces

- This lets Griffin efficiently use CPU time, particularly when some cores are idle or the
  traced process is I/O bound and will pause its execution quite frequently

- Griffin can also back off the amount of active workers under heavy contention to ensure
  that it does not negatively impact scheduling

# Optimization: Caching Disassembly (20)

- Another optimization comes from the observation that the same code blocks are often
  executed multiple times

- Disassembling these multiple times would be inefficient

- The solution here is to store the information at runtime, so that Griffin can look it up
  later, which is in line with its goal to prioritize performance over memory

- To do this, Griffin stores eight basic block pointer pages at a fixed offset from every
  code page

- Each of these pages stores pointers into a heap allocated data structure

- At runtime, a worker thread will query the corresponding pointer page to check for
  cached information

- If the pointer is null, it will perform the disassembly and use the compare-and-swap
  primitive to atomically update the pointer

- These heap allocated structures store cached disassembly information for the
  corresponding code page

- They also cache source and destination addresses for indirect calls, allowing Griffin to
  easily query rows and columns in the policy matrix

# Optimization: Caching Disassembly (21)

- This figure depicts the process in a bit more detail

- Each code page is mapped to eight pointer pages which can store one eight-byte pointer
  for every byte in the code page

- Using these pointer pages, Griffin looks up a heap allocated data structure which stores
  the cached disassembly info along with the source and target addresses for the policy
  matrix

- In the event of a missing pointer, Griffin would simply populate the heap data structure
  before continuing

# P3: Stateful Policy (22)

- As an even more secure alternative to fine-grained policy, Griffin also offers stateful
  policy, which tracks the state of the call stack along with source and target addresses

- To implement this, Griffin simply augments the policy matrix by adding extra rows to
  store shadow stack information

- Griffin's worker threads then output a list of call and return addresses while
  processing traces, which can be compared with a shadow stack policy

# Problem: Sequential Reconstruction (23)

- Unfortunately, another natural problem arises from this new policy category, since
  enforcing a shadow stack policy would require calls and returns to be recorded in order
  but Griffin is processing multiple traces in parallel

- The way they solve this problem is by splitting trace processing into a parallel phase
  and a sequential phase, where individual traces are processed separately and then
  combined together in order

- The sequential phase incurs some additional overhead since we now need to wait for all
  trace workers to finish, but the result is a policy that is even more secure than
  fine-grained policy

# P4: Combination Policy (24)

- The final policy category in Griffin is called combination policy, which is
  a combination of stateful and fine-grained policy

- The idea is to enforce stateful policy on back-edges and fine-grained policy on
  forward-edges

- This is informed by existing research which suggests that shadow stack enforcement is
  far more valuable on returns

- Combination policy therefore allows Griffin to achieve slightly better performance on
  stateful policy without sacrificing much security

# Problem: Support for JITed Languages (25)

- One of Griffin's primary selling points that is advertised in the paper is that it
  supports CFI for just-in-time compiled languages like Javascript

- Unfortunately, many of the optimizations in modern JIT compilers totally break Griffin

- For example, consider Firefox's Javascript JIT compiler

- Firefox poisons unmapped executable memory with null bytes, which can cause issues when
  a Griffin worker thread is still processing a trace

- Its incremental garbage collector also breaks Griffin, since the JIT compiler will
  automatically insert additional instructions to mark specific memory regions as being
  freshly allocated

- Firefox's on-stack replacement mechanism and switch statement optimizations introduce
  similar issues

- In order to make Griffin work, the authors needed to manually patch Firefox's JIT
  compiler to rectify all these issues

- This is, in my opinion, one of the weakest aspects of the entire paper

- They try to wave it away, but I think this is a serious adoption barrier for JIT use
  cases

# Evaluation: Performance Overhead (26)

- To evaluate Griffin's performance, the authors employ micro and macro benchmarks,
  testing its performance and memory overhead

- They allocated six worker threads for each test, but also tested the effect of reduced
  worker counts in their macro-benchmarks

- For micro-benchmarking, they selected the SPEC CPU 2006 becnhmarking suite, a CPU
  intensive suite which has been extensively used to evaluate past work in the area

- They measured the impact of Intel PT without processing any trace buffers as a control,
  and then evaluated the overhead for coarse-grained, fine-grained, and combination
  policies for each test

- The authors also evaluated Griffin's overhead on some real world applications, including
  their modified version of Firefox, the Nginx webserver, the exim email server, and an
  FTP daemon

# Evaluation: Performance Overhead (27)

- In the SPEC CPU benchmarks, the average slowdown for the coarse-grained policy was about 5.6%,
  which is roughly inline with the base Intel PT overhead, as expected

- The average overhead for fine-grained policy was about 8.3%, while combination policy
  was about 9.5%

- The overhead for forward-edge stateful policy was not tested, but we can expect that it
  would be a bit higher than 9.5%

- Unfortunately, the worst-case overhead exceeded 30% in several cases for more complex
  benchmarks, which is certainly approaching the range of being impractical

- While the results do show that Griffin is outperformed by some existing systems, the
  authors argue that these either offer incomplete protection compared to Griffin or lack
  flexibility and support for legacy binaries

- Griffin's memory overhead in quite significant, which is expected since Griffin
  allocates multiple pages of memory per code page

- The results show hundreds of megabytes for complex applications and tens of megabytes
  for even simple ones

# Evaluation: Performance Overhead (28)

- The real-world application benchmarks tell a slightly different story

- They show about 12% overhead in the worst case for Firefox, and negligible overhead for
  most of the server applications

- The results also show that, while a reduction of worker threads has a significant impact
  on Griffin's performance, this impact backs off significantly as applications slow down
  under larger workloads

- As can be expected, I/O bound applications perform much better under Griffin, since they
  allow Griffin to catch up on processing traces while waiting for I/O

- This is quite convenient, since many of the applications that would benefit the most
  from CFI happen to be I/O bound, such as web servers and email clients

# Optimizing Intel PT for Online CFI (29)

- To further improve performance, the authors suggest an obvious design change to Intel PT
  to add source addresses to trace packets

- This would save the need to any reconstruction in fine-grained policy, which comprises
  the majority of Griffin's overhead

- This might be beneficial for online tracing use cases like Griffin, but would result in
  significantly larger memory impact at runtime

- Therefore, the authors suggest enabling a toggle in hardware for offline use cases

- To test the impact of this change, the authors manually inserted source addresses into
  the generated traces using flow update packets

- Their results showed that performance improves by 60-90%, while the traces use
  approximately 19% more memory

# Evaluation: Security (30)

- For their security evaluation, the authors chose to employ the RIPE benchmark, which
  consists of a vulnerable application and a bank of 850 memory corruption and code reuse
  exploits

- The authors only managed to get 82 of these to work, and needed to disable several
  protection mechanisms, including ASLR and data execution prevention

- Griffin was able to detect and prevent all 82 exploits under both a coarse-grained and
  a combination policy

- While this might seem encouraging, this is actually quite weak evidence for its
  effectiveness, since no exploit database can capture 100% of attacks that would be seen
  in the wild, and since none of these attacks would even have worked under ordinary
  conditions

# Adoption Barriers (31)

- I foresee a few major adoption barriers for Griffin, the most obvious of which is its
  performance and memory overhead

- This would almost certainly be prohibitive for deployment in embedded systems and might
  even be prohibitive under complex server workloads involving multiple concurrent
  processes

- It's unclear to me whether Griffin's extra flexibility justifies its overhead compared
  to static solutions

- Another obvious issue is Griffin's incompatibilities with modern JIT engines

- It seems unrealistic to me to expect applications to modify their JIT engines to support
  Griffin

- Griffin also requires a kernel patch to modify the Linux scheduler in order to save
  per-thread information on context switches. The need to patch the kernel might be
  a significant adoption barrier for production use cases

- Griffin also runs in ring 0 and assumes a trusted kernel, which may not necessarily be
  a viable assumption for multi-tenant environments like the cloud

# A Possible Attack (32)

- I was able to come up with a possible attack on Griffin while I was reading about its
  policy switching strategy

- As a quick recap, the idea it to specify a threshold for outstanding trace buffers which
  will cause Griffin to switch into a less secure but more performant policy

- All an attacker would need to do is to force the target application to run a lot of
  instructions very quickly

- For example, they could modify the process' scheduling priority or flood an I/O bound
  program with lots of small inputs

- This is possible under our threat model, since we assume untrusted user input

- By forcing the target to run quickly, the attacker can cause a spike in outstanding
  trace buffers and force Griffin into a more insecure mode, which could permit further
  attacks

# Integration with eBPF (33)

- When I was reading about Intel PT, something I immediately thought about is the
  possibility for integrating it with Linux's eBPF subsystem

- As a quick recap, eBPF is a mechanism for safe per-event tracing between userspace and
  kernelspace

- It already has integration with Linux's perf events subsystem and supports some
  hardware-backed metrics such as PMU counters

- eBPF doesn't yet offer support for Intel PT, but it would be trivial to add support

- It would just require adding a kernel helper to access the trace packets

- The key advantage of using eBPF over a patched kernel or kernel module is production
  safety due to the eBPF verifier

- eBPF also has great support for aggregating events in-kernel and then handing off to
  userspace for processing

- It also offers easy integration with other userspace and kernelspace events and metrics,
  such as system calls, function calls, or the scheduler's run queue length

# Discussion Questions (34)

(Conclude, then present discussion questions)
