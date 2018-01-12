{ stdenv, fetchFromGitHub, bc, python, fuse, libarchive,
btrfs-progs ? null, xfsprogs ? null, stress-ng ? null
, pkgconfig
, musl-frankenlibc
# when building LKL with dceHost
, dce ? null
}:

# valid values are "dce"/"posix"
# fetch musl
# TODO export dce Headers
{ host ? "posix" }:
stdenv.mkDerivation rec {
  name = "lkl-2018-03-10";
  rev  = "8772a4da6064444c5b70766b806fe272b0287c31";

  outputs = [ "dev" "lib" "out" ];

  nativeBuildInputs = [ bc python pkgconfig ]
  ++ stdenv.lib.optionals doCheck [ btrfs-progs xfsprogs stress-ng]
  # ++ stdenv.lib.optionals (host == "dce") [dce.dev]
  ;

  buildInputs = [ fuse libarchive ];

  # src = /home/teto/lkl;
  src = fetchFromGitHub {
    inherit rev;
    owner  = "lkl";
    repo   = "linux";
    sha256 = "1m6gh4zcx1q7rv05d0knjpk3ivk2b3kc0kwjndciadqc45kws4wh";
  };

  # Fix a /usr/bin/env reference in here that breaks sandboxed builds
  prePatch = ''
    patchShebangs arch/lkl/scripts
    patchShebangs tools/lkl
  '';


  #postPatch=''
  #  #
  #'';

  installPhase = ''
    mkdir -p $out/bin $lib/lib $dev

    cp tools/lkl/bin/lkl-hijack.sh $out/bin
    sed -i $out/bin/lkl-hijack.sh \
        -e "s,LD_LIBRARY_PATH=.*,LD_LIBRARY_PATH=$lib/lib,"

    cp tools/lkl/{cptofs,fs2tar,lklfuse} $out/bin
    ln -s cptofs $out/bin/cpfromfs
    cp -r tools/lkl/include $dev/
    cp tools/lkl/liblkl*.{a,so} $lib/lib

    mkdir -p "$out/lib/pkgconfig"
    cat >"$out/lib/pkgconfig/lkl.pc" <<EOF
    prefix=$out
    libdir=$out/lib
    includedir=$out/include
    INSTALL_BIN=$out/bin
    INSTALL_INC=$out/include
    INSTALL_LIB=$out/lib
    INSTALL_MAN=$out/man/man1

    Name: LKL
    Description: The Linux Kernel Library
    Version: ${version}
    Requires:
    Libs: -L$out/lib -llkl
    Cflags: -I$out/tools/lkl/include
    EOF
  '';

  # We turn off format and fortify because of these errors (fortify implies -O2, which breaks the jitter entropy code):
  #   fs/xfs/xfs_log_recover.c:2575:3: error: format not a string literal and no format arguments [-Werror=format-security]
  #   crypto/jitterentropy.c:54:3: error: #error "The CPU Jitter random number generator must not be compiled with optimizations. See documentation. Use the compiler switch -O0 for compiling jitterentropy.c."
  hardeningDisable = [ "format" "fortify" ];

  # TODO we should have the host
  # TODO set OUTPUT_FORMAT !
  makeFlags = "-C tools/lkl";

  enableParallelBuilding = true;

  # will ask for sudo
  checkPhase=''
    make -C tools/lkl tests
  '';

  # tests require root access so they can't be automated
  doCheck=false;

  meta = with stdenv.lib; {
    description = "The Linux kernel as a library";
    longDescription = ''
      LKL (Linux Kernel Library) aims to allow reusing the Linux kernel code as
      extensively as possible with minimal effort and reduced maintenance
      overhead
    '';
    homepage    = https://github.com/lkl/linux/;
    platforms   = [ "x86_64-linux" "aarch64-linux" ]; # Darwin probably works too but I haven't tested it
    license     = licenses.gpl2;
    maintainers = with maintainers; [ copumpkin ];
  };
}
