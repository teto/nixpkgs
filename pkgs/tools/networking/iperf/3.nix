{ stdenv, fetchurl, openssl, fetchpatch, file}:

stdenv.mkDerivation rec {
  name = "iperf-3.5";

  src = fetchurl {
    url = "http://downloads.es.net/pub/iperf/${name}.tar.gz";
    sha256 = "1m9cyycv70s8nlbgr1lqwr155ixk17np0nzqgwaw3f51vkndk6sk";
  };

  buildInputs = [ openssl file ];

  patches = stdenv.lib.optionals stdenv.hostPlatform.isMusl [
    (fetchpatch {
      url = "http://git.alpinelinux.org/cgit/aports/plain/main/iperf3/remove-pg-flags.patch";
      name = "remove-pg-flags.patch";
      sha256 = "0lnczhass24kgq59drgdipnhjnw4l1cy6gqza7f2ah1qr4q104rm";
    })
  ];


  # TODO move this to a specific dce-packages set
  postPatch=''
    substituteInPlace src/Makefile.am --replace "-pg" ""
  '';

  configureFlags= [ "--disable-shared" ];

  # try with -fPIC
  # makeFlags = [ ]

  postInstall = ''
    ln -s iperf3 $out/bin/iperf
  '';

  meta = with stdenv.lib; {
    homepage = http://software.es.net/iperf/;
    description = "Tool to measure IP bandwidth using UDP or TCP";
    platforms = platforms.unix;
    license = "as-is";
    maintainers = with maintainers; [ wkennington fpletz ];
  };
}
