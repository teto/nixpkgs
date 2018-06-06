{ lib, buildPythonApplication, fetchurl, libxslt, docbook5_xsl, openssh
, prettytable, boto, boto3, hetzner, libcloud, azure-storage, azure-mgmt-compute, azure-mgmt-network, azure-mgmt-resource, azure-mgmt-storage, adal, libvirt, pysqlite, datadog, digital-ocean
, nose, coverage
, cacert
, enableDoc ? false
}:
let
# { module, revision ? "local", nixpkgs ? <nixpkgs> }:
  # extracted from nixops/resources.nix

#   systemModule = pkgs.lib.fixMergeModules [ module ]
#     { inherit pkgs; utils = {}; name = "<name>"; uuid = "<uuid>"; };

#   options = pkgs.lib.filter (opt: opt.visible && !opt.internal) (pkgs.lib.optionAttrSetToDocList systemModule.options);

#   optionsXML = builtins.toFile "options.xml" (builtins.unsafeDiscardStringContext
#     (builtins.toXML options));

#   optionsDocBook = pkgs.runCommand "options-db.xml" {} ''
#     ${pkgs.libxslt.bin or pkgs.libxslt}/bin/xsltproc \
#       --stringparam revision '${revision}' \
#       -o $out ${<nixpkgs/nixos/doc/manual/options-to-docbook.xsl>} ${optionsXML}
#   '';
in
buildPythonApplication rec {
  pname = "nixops";
  version = "1.6";

  src = fetchurl {
    url = "http://nixos.org/releases/nixops/nixops-${version}/nixops-${version}.tar.bz2";
    sha256 = "0f8ql1a9maf9swl8q054b1haxqckdn78p2xgpwl7paxc98l67i7x";
  };

  postPatch = ''
    for i in scripts/nixops setup.py doc/manual/manual.xml; do
      substituteInPlace $i --subst-var-by version ${version}
    done
  '';


  buildInputs = lib.optionals enableDoc [ libxslt docbook5_xsl ];

  postBuild = lib.optionalString enableDoc ''
        # Generate the manual and the man page.
        cp ${import ./doc/manual { revision = nixopsSrc.rev; inherit nixpkgs; }} doc/manual/machine-options.xml

        # IMPORTANT: when adding a file here, also populate doc/manual/manual.xml
        ${pkgs.lib.concatMapStrings (fn: ''
          cp ${import ./doc/manual/resource.nix { revision = nixopsSrc.rev; module = ./nix + ("/" + fn + ".nix"); inherit nixpkgs; }} doc/manual/${fn}-options.xml
        '') [ "ebs-volume" "sns-topic" "sqs-queue" "ec2-keypair" "s3-bucket" "iam-role" "ssh-keypair" "ec2-security-group" "elastic-ip"
              "cloudwatch-log-group" "cloudwatch-log-stream" "elastic-file-system" "elastic-file-system-mount-target"
              "gce-disk" "gce-image" "gce-forwarding-rule" "gce-http-health-check" "gce-network"
              "gce-static-ip" "gce-target-pool" "gse-bucket"
              "datadog-monitor" "datadog-timeboard" "datadog-screenboard"
              "azure-availability-set" "azure-blob-container" "azure-blob" "azure-directory"
              "azure-dns-record-set" "azure-dns-zone" "azure-express-route-circuit"
              "azure-file" "azure-gateway-connection" "azure-load-balancer" "azure-local-network-gateway"
              "azure-network-security-group" "azure-queue" "azure-reserved-ip-address"
              "azure-resource-group" "azure-share" "azure-storage" "azure-table"
              "azure-traffic-manager-profile"
              "azure-virtual-network" "azure-virtual-network-gateway"]}


        make -C doc/manual install docdir=$out/manual mandir=$TMPDIR/man

        # releaseName=nixops-$VERSION
        # mkdir ../$releaseName
        # cp -prd . ../$releaseName
        # rm -rf ../$releaseName/.git
        # mkdir $out/tarballs
        # tar  cvfj $out/tarballs/$releaseName.tar.bz2 -C .. $releaseName

    echo "doc manual $out/manual manual.html" >> $out/nix-support/hydra-build-products
    '';

  pythonPath = [
    prettytable
      boto
      boto3
      hetzner
      libcloud
      azure-storage
      azure-mgmt-compute
      azure-mgmt-network
      azure-mgmt-resource
      azure-mgmt-storage
      adal
      # Go back to sqlite once Python 2.7.13 is released
      pysqlite
      datadog
      digital-ocean
      libvirt
    ];

  checkInputs = [ nose coverage ];

  doCheck = true;

  # Needed by libcloud during tests
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  shellHook = ''
    export PYTHONPATH=$(pwd):$PYTHONPATH
    export PATH=$(pwd)/scripts:${openssh}/bin:$PATH
  '';

  postInstall = lib.optionalString enableDoc ''
    # make -C doc/manual install nixops.1 docbookxsl=${docbook5_xsl}/xml/xsl/docbook \
    #   docdir=$out/share/doc/nixops mandir=$out/share/man

    # version dans release.nix
    make -C doc/manual install \
      docdir=$out/share/doc/nixops mandir=$out/share/man
    ''

    + ''
    mkdir -p $out/share/nix/nixops
    cp -av "nix/"* $out/share/nix/nixops

    # Add openssh to nixops' PATH. On some platforms, e.g. CentOS and RHEL
    # the version of openssh is causing errors when have big networks (40+)
    wrapProgram $out/bin/nixops --prefix PATH : "${openssh}/bin"
  '';

  meta = {
    homepage = https://github.com/NixOS/nixops;
    description = "NixOS cloud provisioning and deployment tool";
    maintainers = with lib.maintainers; [ eelco rob domenkozar ];
    platforms = lib.platforms.unix;
  };
}
