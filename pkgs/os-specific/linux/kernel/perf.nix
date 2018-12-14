{ lib, stdenv, kernel, elfutils, python2, python3, perl, newt, slang, asciidoc, xmlto, makeWrapper
, docbook_xsl, docbook_xml_dtd_45, libxslt, flex, bison, pkg-config, libunwind, binutils
, libiberty, audit, libbfd, libopcodes, openssl, systemtap, numactl
, zlib, withGtk ? false, gtk2 ? null
}:

with lib;

assert withGtk -> gtk2 != null;
assert versionAtLeast kernel.version "3.12";

stdenv.mkDerivation {
  pname = "perf-linux";
  version = kernel.version;

  inherit (kernel) src;

  # patches = [
  #   ./perf.patch
  # ];

  # we could wrap it with
  # perf probe -k /nix/store/5am9gvlr7wkcwy48kibhvq16l624iw6h-linux-5.1.0-mptcp_v0.96.0-dev/vmlinux  -L tcp_cong_avoid_ai -s /home/teto/mptcp
    # substituteInPlace util/symbol.c \
    #   --replace /boot/vmlinux-%s ${kernel.dev} --

  # fix la ou il va chercher
  # - la source
  # - vmlinux OK
  # - module map_groups__set_modules_path_dir
  # /run/current-system/kernel-modules/lib/modules/5.1.0/misc
	# snprintf(modules_path, sizeof(modules_path), "%s/lib/modules/%s",
	# 	 machine->root_dir, version);
  preConfigure = ''
    cd tools/perf

    substituteInPlace Makefile \
      --replace /usr/include/elfutils $elfutils/include/elfutils

    # to find vmlinux
    sed -i '\="/boot/vmlinux"=i\    "/run/booted-system/vmlinux",' util/symbol.c

    # to find modules
    # TODO use the kernel version instead
    substituteInPlace util/machine.c \
      --replace '"%s/lib/modules/%s"' '"/run/booted-system/kernel-modules/lib/modules/%s"'

    # substituteInPlace util/symbol.c \
    #   --replace /boot/vmlinux-%s ${kernel.dev} --

    for x in util/build-id.c util/dso.c; do
      substituteInPlace $x --replace /usr/lib/debug /run/current-system/sw/lib/debug
    done

    if [ -f bash_completion ]; then
      sed -i 's,^have perf,_have perf,' bash_completion
    fi
  '';

  makeFlags = ["prefix=$(out)" "WERROR=0"] ++ kernel.makeFlags;

  hardeningDisable = [ "format" ];

  # perf refers both to newt and slang
  nativeBuildInputs = [
    asciidoc xmlto docbook_xsl docbook_xml_dtd_45 libxslt
    flex bison libiberty audit makeWrapper pkg-config python3
  ];
  buildInputs = [
    elfutils newt slang libunwind libbfd zlib openssl systemtap.stapBuild numactl
    libopcodes python3 perl
  ] ++ lib.optional withGtk gtk2
    ++ (if (versionAtLeast kernel.version "4.19") then [ python3 ] else [ python2 ]);

  # Note: we don't add elfutils to buildInputs, since it provides a
  # bad `ld' and other stuff.
  NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=cpp"
    "-Wno-error=bool-compare"
    "-Wno-error=deprecated-declarations"
    "-DOBJDUMP_PATH=\"${binutils}/bin/objdump\""
    "-Wno-error=stringop-truncation"
  ];

  postPatch = ''
    patchShebangs scripts/bpf_helpers_doc.py
  '';

  doCheck = false; # requires "sparse"
  doInstallCheck = false; # same

  separateDebugInfo = true;
  installFlags = [ "install" "install-man" "ASCIIDOC8=1" "prefix=$(out)" ];

  preFixup = ''
    wrapProgram $out/bin/perf \
      --prefix PATH : "${binutils}/bin"
  '';

  meta = {
    homepage = "https://perf.wiki.kernel.org/";
    description = "Linux tools to profile with performance counters";
    maintainers = with lib.maintainers; [viric];
    platforms = with lib.platforms; linux;
  };
}
