# Title Slide

(Skip this I think, it has same info as Paper Overview)

# Paper Overview (1)

- Today I'll be presenting the paper "Griffin: Guarding Control Flows Using Intel Processor Trace"

- The paper was a collaboration between three authors from Microsoft Research and Pennsylvania State University
- The senior author, Trent Jaeger is quite well-known for his work in operating system security

- The paper was published at ASPLOS 2017, which is recognized as a flagship conference in the hardware, programming language, and operating system design space

# Goals (2)

- Control flow integrity, or CFI, is a mechanism that defenders can use to enforce correct control flow in an application and thus mitigate code reuse attacks
- The vast majority of existing CFI defences are based in software but these are either inflexible or perform poorly in practice
- The Griffin authors argue that hardware-backed CFI can offer better security and performance while maintaining flexibility

- To rectify the gap in hardware-backed CFI implementations, the authors present Griffin, which is the first online CFI implementation backed by Intel Processor Trace hardware support
- Griffin offers multiple policy granularities for flexibility, providing defenders with the ability to choose between performance and security at runtime
- Griffin's performance is shown to be comparable to the fastest software-only CFI solutions, but with better security
- They also show how Griffin can support just-in-time compiled languages, although this is a slightly dubious claim, as we will see later
- Finally, they discuss how minor changes to Intel PT's design could significantly improve performance for online CFI applications

