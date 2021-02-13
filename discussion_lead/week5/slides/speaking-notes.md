# Title Slide

(Skip this I think, it has same info as Paper Overview)

# Paper Overview (1)

- Today I'll be presenting the paper "Spectre Attacks: Exploiting Speculative Execution"

- The paper was a collaboration of several authors, as Spectre was independently
  discovered along with Meltdown by several research groups from both industry and academia
- However, Jann Horn appears to be generally credited as the first to discover Spectre,
  circa 2018

- The paper was published at Oakland 2019, which is one of the Big Four reputable security
  conferences

- In terms of related work, Spectre is heavily related but orthogonal to Meltdown, which we
  all remember from Jonathan's presentation last week
- Meltdown is classified as a variant 3 CPU flaw, while Spectre falls into variants 1, 2, and 4

# Spectre Overview (2)

- The concept behind Spectre is actually quite simple
- It's based around exploiting branch prediction, a performance optimization feature in
  modern CPUs

- The attacker essentially tricks the processor into speculatively executing an incorrect
  branch

- Once the processor realizes its mistake, these instructions are rolled back, but they
  have already leaked information into the CPU's micro-architectural state (for example, the cache)

- The attacker can then recover this information using any number of micro-architectural
  side channels

# Goals (3)

- I divided the paper's goals up into six distinct subgoals. These were:

- To provide an overview of Spectre attacks
- To differentiate Spectre from Meltdown
- To present proof of concept exploits for Spectre variant 1 and variant 2
- To evaluate the practical risks associated with Spectre attacks
- To present future avenues for Spectre exploitation, including variant 4 and the use of
  alternative side channels
- And finally to discuss and propose mitigations against current and future Spectre-style
  attacks

# Threat Model and Assumptions (4)

- The paper assumes a generally strong threat model with limited assumptions about the
  attacker's capabilities

- The threat model here is roughly similar to that of the Meltdown paper, but varies
  slightly depending on the specific attack

- In terms of the attacker's capabilities, we assume that the attacker can either spawn or
  interact with a process in user mode and has ordinary user-level privileges

- If the victim is a separate process, we also assume the ability to pass parameters to
  the victim. For example, this can happen via RPC, system calls, sockets, file I/O, library calls or the like

- We further assume that there exists some shared memory between the attacker and the
  victim, if the victim is in a separate address space. For example this can be via
  a shared library mapped to the same physical memory

- One of the attacks I will be presenting later is against Linux KVM. In that specific
  attack, we also assume ring 0 access in the guest OS only

- Finally, we assume that the processor supports speculative execution via dynamic branch
  prediction

# Spectre vs Meltdown (5)

- Just to be clear about the differences between Spectre and Meltdown, I thought it would
  be helpful to quickly compare the two

- As we know from last class, Meltdown is an attack that allows a process to dump
  arbitrary kernel memory, and thus physical memory from user mode
- The victim is the kernel itself, meaning that no victim process is required
- Meltdown is mostly stopped by Kernel Page Table Isolation and only affects some CPUs,
  mostly Intel

- On the other hand, the idea behind Spectre is to leak secrets via speculative execution
- The victim can be the same process, another process, or the kernel
- Unlike Meltdown, Spectre is totally unaffected by the KPTI patches and affects a wide
  range of CPUs, across multiple vendors

- In short, Meltdown is easier to exploit but easier to mitigate, while Spectre is harder
  to exploit but harder to mitigate

# Spectre Building Blocks (6)

- Spectre fits into the two-stage side channel model that we discussed last class, but
  I find it a bit more intuitive to partition the attack into three distinct phases

- In the setup phase, the attacker mistrains the CPU's branch predictor to cause it to
  guess an incorrect branch
- Optionally, the attacker can also induce speculative execution by evicting a condition
  value from the cache and thus forcing the CPU to perform speculative execution while
  waiting on the condition

- In the execution phase, the CPU then mispredicts a branch on a specific
  conditional value n
  - In variant 1, this value is provided directly by the attacker, while in variant 2, this
    is implicitly chosen during the training phase
- The CPU then speculatively executes the incorrect branch, and transient instructions
  encode a secret value into micro-architectural state

- During the recovery phase, the attacker recovers information about the secret using
  a micro-architectural side channel, such as flush+reload, evict+reload, or evict+time

# Branch Prediction (7)

- Even moderately complex applications contain code branches, which depend on values in
  memory
- For a simple example, you can consider an if-statement like the one shown here, where
  which path our control flow takes depends on foo and size

- The problem is that fetching these values can be slow
- For example, suppose that foo is a cache hit but size is a cache miss
- If the CPU is just sitting around during that time, we lose out on performance

- Therefore, the CPU just makes a guess about which side of the branch will be taken and
  just rolls with that guess, while fetching the correct value
- If the guess is right, that's good news. We can commit the state changes and save time
- Otherwise, the CPU just retires the erroneous state changes and executes the correct
  code

# This is Fine Slide (8)

- This is totally _fiiine_ right? What could possibly go wrong?

# But There is One Small (Huge) Problem (9)

- Unfortunately, there is one problem that CPU designers forgot to consider

- The problem is that, while incorrect branch predictions are retired, micro-architectural
  effects still remain
- We call instructions that generate these effects transient instructions
- The number of transient instructions depends on the size of the CPUs reorder buffer
  as well as how quickly the CPU can realize its mistake
- In practice, this number can be quite high. In the paper, they discuss an observed upper
  limit of 192 micro ops

- So, why is this a problem?
- In principle, these erroneous effects in the micro-architecture _should_ be totally
  transparent to the architectural state
- But, attackers can transfer this micro-architectural state into architectural state
  using CPU side channels

# Branch Prediction Illustrated (10)

- This figure shows a comparison between no branch prediction and branch prediction in
  variant 1

- With no prediction, the outcome of the conditional is blocking on fetching foo and bar
  from memory
- The outcome is that either A will be executed with high delay or B will be executed with
  high delay

- With prediction, the predictor makes a guess about the truth value of the conditional,
  either true or false
- If the guess matches with reality, we get faster execution of A or B
- If the guess does not match, we get the same slow execution of either A or B
- But a guess of true and an outcome of false results in a micro-architectural leak from
  executing A while waiting, which may be beneficial to an attacker

# Mistraining the Branch Predictor (11)

- Modern CPUs use a branch prediction technique called "Dynamic Branch Prediction" which
  constantly updates the branch prediction model using historical data, stored in a branch
  history buffer
- To train the branch predictor, the attacker can repeatedly invoke a specific branch
  target
- The number of times they need to do so depends on the specific branch prediction
  implementation as well as other factors like scheduling

- After mistraining, the attacker can then supply an out-of-bounds foo
- But the branch predictor will still execute as if foo is in-bounds
- The transient code from this execution will access some secret at an offset computed
  using foo, which in turn leaks into cache memory

# Transferring Leaked Data into Architectural State (12)

- The Spectre paper primary focuses on using cache-based side channels for the final step
  of the attack, but in principle any observable effects can leak information
- For example, high contention on specific execution units or traditional side channels
  such as power draw could also work in tandem with Spectre attacks

- The paper focuses specifically on Flush and Reload, Evict and Reload, and Evict and Time
  side channels

- In flush and reload, the attacker flushes a cache line with the clflush instruction and
  then times a subsequent access to the same address
- If the access takes a short amount of time, we know there was a cache hit and thus that
  this memory has been accessed in the mean time

- An evict and reload is similar, except we evict the cache set via contention instead
- The advantage here is that this works without access to clflush

- Finally, evict and time is similar to evict and reload, except that instead of timing
  a reload directly, we time an operation that depends on the state of the cache

# Direct and Indirect Branching (13)

- Thus far, we've been informally discussing branches in terms of if-statements, but there
  are actually two distinct types of branching that we are concerned with here

- Direct branches involve branching on a conditional, a switch statement, or a ternary
  operator, where a predicted condition may not match the actual check

- Indirect branches on the other hand involve invoking a function based on a function
  pointer
- In this case, the predictor can guess a incorrect address and jump to the wrong part of
  the code

# Spectre Variants (14)

- Based on this notion of branching, we have three distinct Spectre variants

- Variant 1, conditional branch misprediction, abuses CPU speculation on Direct Branches
- The attacker tricks the CPU into guessing the wrong truth value for a conditional

- Variant 2, indirect branch poisoning, abuses speculation on indirect branches
- Here, the attacker tricks the CPU into executing a Spectre gadget in the victim's code
  instead of following a legitimate function pointer

- Variant 4 abuses speculation in the CPU's Store-To-Load forwarding logic
- The basic idea here is that the CPU speculates that a load does not depend on a previous stored value
- The paper doesn't go into huge detail about this, but we can cover this at the end if we have time

# Variant 1: Conditional Branch Misprediction (15)

- Looking at this toy example, our goal as an attacker is to cause the CPU to
  speculatively execute the inner part of the if statement on an out of bounds foo
- This would then encode the value of a secret into our probe array, arr2, which encodes
  data at the granularity of a cache line

- First, we flush or evict arr2 from the cache to ensure that it contains no cached values
- Next, we train the CPU by repeatedly invoking the victim function with an in-bounds value
- Then, we choose some malicious value for foo that will overflow from the base of arr1 to
  leak a secret value
- Next, we flush or evict arr1_size to induce speculative execution in the victim
  function, and subsequently invoke victim using our malicious foo
- Finally, we probe each entry in our probe array and time access
- A fast access time means a cache hit and thus a 1, and a slow access means a cache miss
  and thus a 0
- We repeat this probing over the entirety of arr2 to read an entire byte
- Then we can simply repeat the entire process to read the next byte, and so on

# Variant 1 Examples (16)

- The first practical example of variant 1 presented in the paper was an attack on the
  JavaScript V8 engine used in modern browsers
- Browsers rely on strong isolation between JavaScript and the rest of the browser to
  mitigate the risk of untrusted code from websites
- For example, JavaScript on one web page should not be able to mess with JavaScript on
  a totally different web page
- Unfortunately, a variant 1 Spectre attack can totally break this isolation

- In the paper, they demonstrated that malicious JavaScript code just a few lines long can
  leak arbitrary browser data
- There were a few caveats to this implementation since JavaScript lacks both a high
  enough resolution timer and access to the clflush instruction
- However, they were able to work around these limitations by implementing their own high
  resolution timer using web workers and using a cache eviction strategy rather than flushing the cache

- Another practical attack demonstrated in the paper was an attack on the eBPF subsystem
  in Linux
- eBPF is designed to allow userspace to make safe extensions to the running Linux kernel
  - The primary use case is for observability
  - An in-kernel verifier enforces BPF program safety, including safe memory access
  - As with JavaScript, Spectre totally breaks these safety guarantees
- This attack targets special eBPF data structures called maps, which are used to store
  per-event data and share it with userspace
- The idea is to trick the CPU into accessing arbitrary user memory instead of map entries
- The proof of concept requires a CPU without SMAP, but the authors claim that it's
  possible to work around this limitation

# Mitigating Variant 1 (17)

- Now that we've seen some examples of how variant 1 can be practically exploited, we can
  discuss potential mitigations that can be deployed in software
- The first of these mechanisms is called index masking

- The basic idea here is to apply a bitmask to indices into an array to ensure that they
  are strictly bounded by array size, steering array accesses into safe memory regions
- In JITed or interpreted code, we can inject this logic automatically where required

- Since eBPF is actually one of my primary research interests, I'll focus on it here, but
  JavaScript also applies similar mitigations

- In recent versions of Linux, the eBPF runtime now automatically injects index masking
  logic before all array accesses, made possible with the help of the verifier, which
  enforces bounds checking

- The code snippet on the left here is automatically converted into what is shown on the
  right.

- If our access is in bounds, the sign bit on the mask is a 0, which gets
  propagated across with a bitshift and then inverted via one's complement

- If our access is out of bounds, the same process results in a mask of 0,
  which results in accessing index 0 of the array

# Mitigating Variant 1 (18)

- I actually have access to a Spectre-vulnerable CPU, so I was able to try their proof of
  concept code myself

- I made a one line patch the code, adding the index masking logic I just described

- As you can see, the unpatched version on the left is able to leak secret data, while the
  patched version on the right is rendered useless

# Mitigating Variant 1 (19)

- Another mitigation for variant 1 is something called poison pointers
- The idea here is make all pointers unusable without some pseudo-random value X
- This is accomplished by simply XORing all pointers by some X, and then decoding them at
  runtime by repeating the same XOR operation

- Without the poison value, an adversary cannot follow a pointer in the speculatively
  executed code
- However, it's still possible to leak the poison value via a side channel
- Consequently, this method probably works best in combination with other defences

# Variant 1 Evaluation (20)

- In terms of requirements, variant 1 generally requires either that the attacker is in
  the same process as the victim (for example in a web browser), or that the attacker shares
  some memory with the victim and has the ability to pass parameters to the victim

- While these requirements are slightly limiting, there are a ton of real world scenarios
  where this kind of attack is problematic
- eBPF and JavaScript are both widely used
- It's not hard to imagine similar attacks targeting crypto libraries or libc for example

- JITed and interpreted languages have an easier time mitigating variant 1, since they
  can easily make arbitrary changes to their runtime behaviour
- However, many legacy applications (especially those that are distributed as binary
  blobs) are still vulnerable and are not strictly trivial to update
- One potential path forward is applying static analysis techniques to identify possible
  variant 1 vulnerabilities in binary blobs

# Variant 1 Evaluation (21)

- The toy example presented in the paper can read memory in the same process at a rate of
  about 10KB/s, while the eBPF attack is on the order of 2KB/s to 5KB/s

- The authors don't present the rate of the JavaScript attack, but we can expect this to
  be quite low as well, due to the lack of a high-resolution timer and a reliance on cache
  eviction rather than flushing

- Overall, the speed of the attack is not great, but is acceptable, especially if an
  attacker can amortize over a rough estimate of the secret value location

- In terms of accuracy, variant 1 suffers from similar weaknesses to Meltdown
- In particular, limited accuracy of timing measurements and unexpected caching and
  eviction can be major sources of errors
- However, the authors show that variant 1 can achieve very low error rates with multiple
  iterations, as low as 0.005%

# Variant 2: Indirect Branch Poisoning (22)

- In variant 2 attacks, the attacker relies on tricking the CPU into executing something
  called a Spectre gadget in an indirect code branch

- The CPU keeps track of visited indirect branches in something called the Branch Target
  Buffer
- The implementation details of this buffer are CPU-dependent and vary in the number of
  prior addresses tracked as well as which address bits are tracked
- This means that some additional reverse engineering effort may be required to mount more
  complex attacks

- The attacker's goal is to train the CPU's branch target buffer to point to our chosen
  target
- This training process involves mimicking the victim's access patterns and then making
  a jump to the chosen target address

- Spectre gadgets are quite similar to the gadgets used in return oriented programming
- The attacker locates a small nibble of code in the victim that performs some desirable operation
- Training is then as simple as invoking the function pointer after setting it to our
  gadget address

- Note that the gadget doesn't even need to exist in the attacker's own process
- The address we use for a target just needs to be the same as the victim's gadget address
- One final thing I'd like to point out here is that the execution of these Spectre
  gadgets is quite time sensitive, since we are racing with the CPU before it can fetch
  the correct value -- therefore Spectre gadgets need to be extremely small in most cases

# Variant 2: Indirect Branch Poisoning (23)

- In summary, the steps to mounting a variant 2 attack are as follows:

1. Identify a Spectre gadget
2. Find it in victim memory
3. Train the CPU to speculatively execute that location
4. Induce speculative execution
5. Transfer leaked data via a side channel

- The figure on the right here depicts the process of speculation on an indirect call
- Here we see that the attacker has already poisoned the target in the branch target buffer
- When our control flow reaches the indirect call, the CPU jumps to our Spectre gadget
  while fetching the real address
- When the CPU realizes its mistake, it discards the erroneous state and jumps to the
  actual target, but the gadget's side effects are left behind in the cache

# Variant 2 Examples (24)

- The paper presented two examples of variant 2, the first of which was a proof of concept
  exploit on a Windows' NT DLL, which defines userspace bindings for the NT kernel's interfaces

- They used static analysis to identify a gadget that can read victim memory using an
  attacker controlled edx and edi register
- They simply set edx and edi to the correct values and speculatively execute the gadget

- Note that ASLR is insufficient to protect the victim here, as they simply perform a few
  trial and error training iterations until they identify the correct sequence

- It's not hard to imagine that similar attacks would be possible on crypto libraries,
  resulting in leaked private keys for example

# Variant 2 Examples (25)

- The second example they presented was an attack that defeats Linux KVM isolation,
  and only requires ring 0 access in the guest OS

- The attack is quite complex and involves multiple Spectre gadgets. In the setup phase,
  they first find the hypervisor's ASLR offset, then use a Spectre gadget to leak cache
  set information as well as the location of the physical memory map

- Once they have the necessary information, they execute another gadget in the eBPF
  interpreter and use it to dump arbitrary host memory

# Mitigating Variant 2 (26)

- To mitigate variant 2, AMD and Intel introduced extensions to their ISA implementation

- IBRS prevents unprivileged branches from affecting privileged branch predictions,
  preventing an attacker from training the branch predictor on kernelspace gadgets from userspace
- When making a context switch into kernelspace, the CPU enters a special IBRS mode which
  enacts these changes

- STIBP prevents branch prediction sharing between hyperthreaded software running in the same physical core
- Since indirect branch predictors are not shared across cores, this means that it's now
  much harder for one process to influence branch predictions in another in a timely manner

# Mitigating Variant 2 (27)

- IBPB provides a manual barrier that works like IBRS
- Any software running before an IBPB barrier cannot affect branch prediction after the
  barrier

- To apply the update, users simply flash a microcode update to their firmware
- However, these mitigations also require support on the OS side, and their overhead can
  vary significantly depending on how widely the mitigations are deployed
- This variation can be from 1 to 2 percent up to a factor of 4x overhead

# Mitigating Variant 2 (28)

- Another mitigation for variant 2 is a concept called retpolines which can be implemented in software

- These work by replacing indirect calls with a return-based trampoline
- First, we push the target function address onto the stack
- We replace the indirect call with a jump into a dummy loop
- If the CPU tries to speculate, it will enter this loop instead of jumping to the
  speculated target
- When the CPU realizes its mistake, it will simply call ret and jump into the correct
  function

- A nice advantage of the retpoline technique is that it can be applied automatically
  at compile time, gated by a compiler flag

- The Linux kernel now compiles with this by default

- The assembly shown on the right is the result of compiling my indirect branch example with gcc's retpoline flag
- The indirect call is replaced with a jump into the indirect_thunk_rax label, which calls into the retpoline
  and forces speculative execution into the dummy loop

# Variant 2 Evaluation (29)

- Unlike variant 1, variant 2 has the extra requirement that the attacker needs to find
  one or more Spectre gadgets to achieve their goal, requiring static analysis or similar techniques

- The attacker also needs to defeat ASLR in order to find the correct training sequence,
  although the paper demonstrates that this can be accomplished with a simple guess and check strategy

- For the more complex KVM bypass attack, the attacker requires access to ring 0 in the
  guest OS. While this is not totally improbable, it may be unrealistic in certain cloud
  contexts, where providers often host containers running in virtual machines. In that
  situation, it may be unrealistic to expect the attacker to be able to operate in ring 0

- Mitigations for variant 2 can be applied automatically, but applying them
  everywhere can incur significant performance overhead
- Therefore, defenders need to carefully consider what parts of the system they want to
  protect

# Variant 2 Evaluation (30)

- The speed of variant 2 attacks appears to be very slow compared to variant 1
- In the KVM attack, the initial set up phase alone takes about 20-30 minutes to complete

- In general, data transfer rate also seems insanely slow
- In the Windows DLL attack, they were only able to achieve 41 bytes per second, while
  they were able to achieve 1.8KB/s in the KVM attack
- This slowness is likely due to higher error rates and increased attack difficulty

- Variant 2 has slightly higher error rates than variant 1, at 2% and 1.7%
  respectively in the example attacks
- For similar attacks, we can expect about an equivalent error rate

# Other Mitigation Strategies (31)

- In addition the variant-specific mitigation strategies I discussed earlier, the paper
  also discusses a few generally-applicable mitigation strategies

- Web browsers elected to limit the availability of high resolution timers by making
  built-in timers more granular and introducing a slight jitter
- The point here is to make it harder to perform the timing step when performing a cache
  side channel to recover data
- One issue with this approach is that it doesn't directly stop the attack, only increases
  the error rate
- This approach also wouldn't be generally applicable since high resolution timers
  are provided by CPU instructions and are critical for many applications

- Similar direct mitigations can be applied to other side channels
- For instance, future processors could potentially track sensitive data and try prevent
  leaks during speculative execution
- Unfortunately, it may be infeasible to mitigate every single side channel

- Another option is disabling speculative execution entirely, although this strategy makes
  little sense from a performance perspective
- A better idea would be to selectively disable speculation for sensitive code using
  speculation barriers

# Anomaly Detection? (32)

- Something I've been thinking about is potentially using anomaly detection as an indirect
  mitigation strategy
- This isn't really in the spirit of trusted computing, but it's something that I've been
  thinking about for some time

- This is based on the simple observation that Spectre-style attacks almost always involve
  repeated weird behaviour in the training sequence
- In turns out that anomaly detection is really good at flagging repeated weird behaviour
- An anomaly detection system could catch attackers in the act and possibly kill the
  processes they are using for training

- To my knowledge, nobody has investigated using anomaly detection against Spectre
- I think it could be a promising avenue for implementing a stop-gap mitigation
- Plus there would be something very poetic about an eBPF-based IDS stopping Spectre in
  its tracks

# Discussion (33)

(Conclude, then present discussion questions)
