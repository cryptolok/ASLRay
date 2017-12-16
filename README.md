[![Rawsec's CyberSecurity Inventory](http://list.rawsec.ml/img/badges/Rawsec-inventoried-FF5050_flat-square.svg)](http://list.rawsec.ml/tools.html#ASLRay)

# ASLRay
Linux ELF x32/x64 ASLR DEP/NX bypass exploit with stack-spraying

![](https://i.imgur.com/mBuqu8J.jpg)

Properties:
* ASLR bypass
* DEP/NX bypass
* Cross-platform
* Minimalistic
* Simplicity
* Unpatchable

Dependencies:
* **Linux 2.6.12+** - would work on any x86-64 Linux-based OS
	- BASH - the whole script

Limitations:
* Stack needs to be executable (-z execstack) for x64
* Binary has to be exploited through arguments locally (not file, socket or input)
* No support for other architectures and OSes (TODO)
* Need to know the buffer limit/size

## How it works
You might have heard of [Heap Spraying](https://www.corelan.be/index.php/2011/12/31/exploit-writing-tutorial-part-11-heap-spraying-demystified/) attack? Well, [Stack Spraying](http://j00ru.vexillium.org/?p=769) is similar, however, it was considered unpractical for most cases, especially [ASLR](https://en.wikipedia.org/wiki/Address_space_layout_randomization) on x86-64.

My work will prove the opposite.

For 32-bit, there are 2^32 (4 294 967 296) theoretical addresses, nevertheless, the kernel will allow to control about only half of bits (2^(32/2) = 65 536) for an execution in a virtualized memory, which means that if we control more that 50 000 characters in stack, we are almost sure to point to our shellcode, regardless the address, thanks to kernel redirection and retranslation. According to my tests, even 100 or 10 characters are enough if the called function doesn't contain other variable creations, which will allow ROP-style attack.

This can be achieved using shell variables, which aren't really limited to a specific length, but practical limit is about one hundrer thousand, otherwise it will saturate the TTY.

So, in order to exploit successfully with any shellcode, we need to put a [NOP sled](https://en.wikipedia.org/wiki/NOP_slide) following the shellcode into a shell variable and just exploit the binary with a random address. Note that NOP sled isn't necessary, this is just to universalise the exploit. The reason behind it is unclear to me.


In 64-bit system the situation is different, but not so much as of my discovery.

Of course, you wouldn't have to cover all 2^64 possibilities, in fact, the kernel allows only 48 bits, plus a part of them are predictable and static, which left us with about 2^(4x8+5) (137 438 953 472) possibilities.

I have mentioned the shell variables size limit, but there is also a count limit, which appears to be about 10, thus allowing us to stock a 1 000 000 character shellcode, living us with just some tenth of thousand possibilities that can be tested rapidly and automatically. This time however, you will need to bruteforce and use NOP-sleds in order to make things quicker.

That said, ASLR on both 32 and 64-bits can be easily bypassed in few minutes and with few lines of shell...

The DEP/NX on the other hand, can be bypassed on x32 using [return-to-libc](https://www.exploit-db.com/docs/28553.pdf) technique by coupling it with statistical studies of different OSes, more specifically, their ASLR limitations and implementations, which can lead to a successful exploitation for 2 reasons.
The rist one is being ASLR not so random in its choice and having some constants and poor entropy (easy to guess libC address and each OS has its own constants).
The second one is spraying the shell argument for libC into environment (easy to find and pass it to libC).

To conclude, DEP/NX on 32-bits is weakened because of ASLR.

### HowTo

If you have exploited at least one buffer overflow in your life, you can skip, but just in case:
```bash
apt install gcc libc6-dev-i386 || kill -9 $$
chmod u+x ASLRay.sh
sudo gcc -z execstack test.c -o test
sudo gcc -m32 -z execstack test.c -o test32
sudo chmod +s test test32
source ASLRay.sh test32 1024
source ASLRay.sh test 1024
source ASLRay.sh test 1024 \x31\x80...your_shellcode_here
sudo gcc -m32 test.c -o test32x
sudo chmod +s test test32
source ASLRay.sh test32x 1024
```
To prove that NOP-sled isn't necessary for Debian x32:

**!!! WARNING !!!** this will modify your /etc/passwd and change permissions of /etc/shadow, VM execution adviced
```bash
chmod u+x PoC.sh
source PoC.sh
grep ALI /etc/passwd
```
In case it still doesn't work, just add some NOPs (\x90) in the beginning.

To prove that even environmental variable isn't necessary for Debian x32:
```bash
chmod u+x PoC2.sh
source PoC.sh
```

Thus you can just put your shellcode into a variable and give random addresses to registers for a shell with ASLR, this is because the specific context where the function only has one variable which will be rewritten, so the stack will be popped to EIP just with our shellcode, which is more like a ROP attack.


For Arch/Ubuntu you will also need to disable stack smashing protection and brute-force may take much longer (execution delay, probably due to brk(NULL/0) syscall):
```bash
sudo gcc -z execstack -fno-stack-protector test.c -o test
sudo gcc -m32 -z execstack -fno-stack-protector test.c -o test32
sudo gcc -m32 -fno-stack-protector test.c -o test32x
```

#### Notes

Always rely on multiple protections and not on a single one.

We need new system security mechanisms.

> "From where we stand the rain seems random. If we could stand somewhere else, we would see the order in it. "

Tony Hillerman, *Coyote Waits*
