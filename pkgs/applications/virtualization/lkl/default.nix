{ stdenv, fetchFromGitHub, bc, python, fuse, libarchive,
btrfs-progs ? null, xfsprogs ? null, stress-ng ? null
, pkgconfig
, gnulib
, musl-frankenlibc
, gperf
# when building LKL with dceHost
, dce ? null
}:

# valid values are "dce"/"posix"
# fetch musl
# TODO export dce Headers
{ host ? "posix" }:
stdenv.mkDerivation rec {
  name = "lkl-${version}";
  version= "2018-11-10";
  rev  = "fd7bb8a1c38b0356ffea529de7bae73905d9ca0a";

  outputs = [ "out" "dev" "lib" ];

  nativeBuildInputs = [ bc python pkgconfig ]
  ++ stdenv.lib.optionals doCheck [ btrfs-progs xfsprogs stress-ng ]
  # ++ stdenv.lib.optionals (host == "dce") [dce.dev]
  ;

  buildInputs = [ gperf fuse libarchive gnulib ];

  # src = stdenv.lib.cleanSource /home/teto/lkl;
  src = fetchFromGitHub {
    inherit rev;
    owner  = "lkl";
    repo   = "linux";
    sha256 = "1ssgj89fkhg2waq8vqnq87qaswajbjv3whdvlvxiyq9w0am9ilym";
  };

  # Fix a /usr/bin/env reference in here that breaks sandboxed builds
  prePatch = ''
    patchShebangs arch/lkl/scripts
    patchShebangs tools/lkl
    # extracted from kernel prepatch code
    for mf in $(find -name Makefile -o -name Makefile.include -o -name install.sh); do
        echo "stripping FHS paths in \`$mf'..."
        sed -i "$mf" -e 's|/usr/bin/||g ; s|/bin/||g ; s|/sbin/||g'
    done
  '';

  # preInstall=''
  #   mkdir -p $out/bin
  # '';
  dontAddPrefix = true;
  configurePhase=''
    export buildRoot=$PWD/build
    mkdir $buildRoot
  '';

  # TODO I should be able to pass my own config
  installFlags= [  "PREFIX=\${out}" "DESTDIR=" ];
  makeFlags = ["-C tools/lkl" "O=\"\${buildRoot}\""];
  postInstall = ''
    mkdir -p $lib $dev

    # TODO use $buildRoot instead here !
    mv -v $out/lib $lib
    mv -v $out/include $dev

    # il n'est pas installe de base, upstreamer ?
    cp tools/lkl/bin/lkl-hijack.sh $out/bin

    sed -i $out/bin/lkl-hijack.sh \
        -e "s,LD_LIBRARY_PATH=.*,LD_LIBRARY_PATH=$lib/lib,"

    mkdir -p "$lib/lib/pkgconfig"
    cat >"$lib/lib/pkgconfig/lkl.pc" <<EOF
    prefix=$out
    libdir=$lib/lib
    includedir=$dev/include
    INSTALL_BIN=$out/bin
    INSTALL_INC=$dev/include
    INSTALL_LIB=$lib/lib

    Name: LKL
    Description: The Linux Kernel Library
    Version: ${version}
    Requires:
    Libs: -L$lib/lib -llkl
    Cflags: -I$dev/include
    EOF
  '';

  # We turn off format and fortify because of these errors (fortify implies -O2, which breaks the jitter entropy code):
  #   fs/xfs/xfs_log_recover.c:2575:3: error: format not a string literal and no format arguments [-Werror=format-security]
  #   crypto/jitterentropy.c:54:3: error: #error "The CPU Jitter random number generator must not be compiled with optimizations. See documentation. Use the compiler switch -O0 for compiling jitterentropy.c."
  hardeningDisable = [ "format" "fortify" ];

  enableParallelBuilding = true;

  # will ask for sudo reuseflags ?
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
