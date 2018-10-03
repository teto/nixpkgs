# Based on recommendations from:
# http://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project#Recommended_settings
# https://wiki.gentoo.org/wiki/Hardened/Hardened_Kernel_Project
#
# Dangerous features that can be permanently (for the boot session) disabled at
# boot via sysctl or kernel cmdline are left enabled here, for improved
# flexibility.
#
# See also <nixos/modules/profiles/hardened.nix>

{ stdenv, version }:

with stdenv.lib;

assert (versionAtLeast version "4.9");

{
  # Report BUG() conditions and kill the offending process.
  BUG = yes;

  BUG_ON_DATA_CORRUPTION = versionAtLeast "4.10" yes;

  # Safer page access permissions (wrt. code injection).  Default on >=4.11.
  DEBUG_RODATA = versionOlder "4.11" yes;
  DEBUG_SET_MODULE_RONX = versionOlder "4.11" yes;

  # Mark LSM hooks read-only after init.  Conflicts with SECURITY_SELINUX_DISABLE
  # (disabling SELinux at runtime); hence, SELinux can only be disabled at boot
  # via the selinux=0 boot parameter.
  SECURITY_SELINUX_DISABLE = versionAtLeast "4.12" no;

  SECURITY_WRITABLE_HOOKS = versionBetween "4.12" "4.17" no;

  DEBUG_WX = yes; # boot-time warning on RWX mappings

  # Stricter /dev/mem
  STRICT_DEVMEM    = option yes;
  IO_STRICT_DEVMEM = option yes;

  # Perform additional validation of commonly targeted structures.
  DEBUG_CREDENTIALS     = yes;
  DEBUG_NOTIFIERS       = yes;
  DEBUG_LIST            = yes;
  DEBUG_PI_LIST         = yes; # doesn't BUG()
  DEBUG_SG              = yes;
  SCHED_STACK_END_CHECK = yes;

  REFCOUNT_FULL = versionAtLeast "4.13" yes;

  # Perform usercopy bounds checking.
  HARDENED_USERCOPY = yes;
  HARDENED_USERCOPY_FALLBACK = versionAtLeast "4.16" no;

  # Randomize allocator freelists.
  SLAB_FREELIST_RANDOM = yes;

  SLAB_FREELIST_HARDENED = versionAtLeast "4.14" yes;

  # Wipe higher-level memory allocations on free() with page_poison=1
  PAGE_POISONING           = yes;
  PAGE_POISONING_NO_SANITY = yes;
  PAGE_POISONING_ZERO      = yes;

  # Reboot devices immediately if kernel experiences an Oops.
  PANIC_ON_OOPS = yes;
  PANIC_TIMEOUT = freeform "-1";

  GCC_PLUGINS = yes; # Enable gcc plugin options

  # Gather additional entropy at boot time for systems that may = no;ot have appropriate entropy sources.
  GCC_PLUGIN_LATENT_ENTROPY = yes;

  GCC_PLUGIN_STRUCTLEAK = versionAtLeast "4.11" yes; # A port of the PaX structleak plugin
  GCC_PLUGIN_STRUCTLEAK_BYREF_ALL = versionAtLeast "4.14" yes; # Also cover structs passed by address

  # Disable various dangerous settings
  ACPI_CUSTOM_METHOD = no; # Allows writing directly to physical memory
  PROC_KCORE         = no; # Exposes kernel text image layout
  INET_DIAG          = no; # Has been used for heap based attacks in the past

  # Use -fstack-protector-strong (gcc 4.9+) for best stack canary coverage.
  CC_STACKPROTECTOR_REGULAR = no;
  CC_STACKPROTECTOR_STRONG  = yes;

  # Enable compile/run-time buffer overflow detection ala glibc's _FORTIFY_SOURCE
  FORTIFY_SOURCE = versionAtLeast "4.13" yes;
} // optionalAttrs (stdenv.hostPlatform.platform.kernelArch == "x86_64") {
  DEFAULT_MMAP_MIN_ADDR = freeform "65536";  # Prevent allocation of first 64K of memory

  # Safer page access permissions (wrt. code injection).  Default on >=4.11.
  DEBUG_RODATA = versionOlder "4.11" yes;
  DEBUG_SET_MODULE_RONX = versionOlder "4.11" yes;

  # Mark LSM hooks read-only after init.  Conflicts with SECURITY_SELINUX_DISABLE
  # (disabling SELinux at runtime); hence, SELinux can only be disabled at boot
  # via the selinux=0 boot parameter.
  SECURITY_SELINUX_DISABLE = versionAtLeast "4.12" no;

  SECURITY_WRITABLE_HOOKS = versionBetween "4.12" "4.17" no;

  DEBUG_WX = yes; # boot-time warning on RWX mappings

  # Stricter /dev/mem
  STRICT_DEVMEM    = option yes;
  IO_STRICT_DEVMEM = option yes;

  # Perform additional validation of commonly targeted structures.
  DEBUG_CREDENTIALS     = yes;
  DEBUG_NOTIFIERS       = yes;
  DEBUG_LIST            = yes;
  DEBUG_PI_LIST         = yes; # doesn't BUG()
  DEBUG_SG              = yes;
  SCHED_STACK_END_CHECK = yes;

  REFCOUNT_FULL = versionAtLeast "4.13" yes;

  # Perform usercopy bounds checking.
  HARDENED_USERCOPY = yes;
  HARDENED_USERCOPY_FALLBACK = versionAtLeast "4.16" no;

  # Randomize allocator freelists.
  SLAB_FREELIST_RANDOM = yes;

  SLAB_FREELIST_HARDENED = versionAtLeast "4.14" yes;

  # Wipe higher-level memory allocations on free() with page_poison=1
  PAGE_POISONING           = yes;
  PAGE_POISONING_NO_SANITY = yes;
  PAGE_POISONING_ZERO      = yes;

  # Reboot devices immediately if kernel experiences an Oops.
  PANIC_ON_OOPS = yes;
  PANIC_TIMEOUT = freeform "-1";

  # Disable various dangerous settings
  ACPI_CUSTOM_METHOD = no; # Allows writing directly to physical memory
  PROC_KCORE         = no; # Exposes kernel text image layout
  INET_DIAG          = no; # Has been used for heap based attacks in the past

  # Use -fstack-protector-strong (gcc 4.9+) for best stack canary coverage.

  # Enable compile/run-time buffer overflow detection ala glibc's _FORTIFY_SOURCE
  FORTIFY_SOURCE = versionAtLeast "4.13" yes;
} // optionalAttrs (versionOlder "4.18") {

  GCC_PLUGINS = yes; # Enable gcc plugin options
  # Gather additional entropy at boot time for systems that may = no;ot have appropriate entropy sources.
  GCC_PLUGIN_LATENT_ENTROPY = yes;

  GCC_PLUGIN_STRUCTLEAK = versionAtLeast "4.11" yes; # A port of the PaX structleak plugin
  GCC_PLUGIN_STRUCTLEAK_BYREF_ALL = versionAtLeast "4.14" yes; # Also cover structs passed by address

} // optionalAttrs (versionOlder "4.18") {
  # Use -fstack-protector-strong (gcc 4.9+) for best stack canary coverage.
  CC_STACKPROTECTOR_REGULAR = no;
  CC_STACKPROTECTOR_STRONG  = yes;
} // optionalAttrs (stdenv.platform.kernelArch == "x86_64") {
  DEFAULT_MMAP_MIN_ADDR = freeform "65536";  # Prevent allocation of first 64K of memory

  # Reduce attack surface by disabling various emulations
  IA32_EMULATION     = no;
  X86_X32            = no;
  MODIFY_LDT_SYSCALL = versionOlder "4.17" (optional no);
  VMAP_STACK         = yes; # Catch kernel stack overflows

  # Randomize position of kernel and memory.
  RANDOMIZE_BASE   = yes;
  RANDOMIZE_MEMORY = yes;

  # Disable legacy virtual syscalls by default (modern glibc use vDSO instead).
  #
  # Note that the vanilla default is to *emulate* the legacy vsyscall mechanism,
  # which is supposed to be safer than the native variant (wrt. ret2libc), so
  # disabling it mainly helps reduce surface.
  LEGACY_VSYSCALL_NONE = yes;
}
