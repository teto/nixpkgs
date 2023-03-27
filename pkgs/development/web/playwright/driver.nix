{ lib
, stdenv
, chromium
, ffmpeg
, firefox
, git
, jq
, nodejs
, fetchFromGitHub
, fetchurl
, makeFontsConf
, makeWrapper
, runCommand
, unzip
}:
let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";

  driver = stdenv.mkDerivation (finalAttrs:
    let
      suffix = {
        x86_64-linux = "linux";
        aarch64-linux = "linux-arm64";
        x86_64-darwin = "mac";
        aarch64-darwin = "mac-arm64";
      }.${system} or throwSystem;
      filename = "playwright-${finalAttrs.version}-${suffix}.zip";

    in
    {
    pname = "playwright-driver";
    version = "1.27.1";

    src = fetchurl {
      url = "https://playwright.azureedge.net/builds/driver/${filename}";
      sha256 = {
        x86_64-linux = "0x71b4kb8hlyacixipgfbgjgrbmhckxpbmrs2xk8iis7n5kg7539";
        aarch64-linux = "125lih7g2gj91k7j196wy5a5746wyfr8idj3ng369yh5wl7lfcfv";
        x86_64-darwin = "0z2kww4iby1izkwn6z2ai94y87bkjvwak8awdmjm8sgg00pa9l1a";
        aarch64-darwin = "0qajh4ac5lr1sznb2c471r5c5g2r0dk2pyqz8vhvnbk36r524h1h";
      }.${system} or throwSystem;
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    postPatch = ''
      # Use Nix's NodeJS instead of the bundled one.
      substituteInPlace playwright.sh --replace '"$SCRIPT_PATH/node"' '"${nodejs}/bin/node"'
      rm node

      # Hard-code the script path to $out directory to avoid a dependency on coreutils
      substituteInPlace playwright.sh \
        --replace 'SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"' "SCRIPT_PATH=$out"

      patchShebangs playwright.sh package/bin/*.sh
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mv playwright.sh $out/bin/playwright
      mv package $out/

      runHook postInstall
    '';

    passthru = {
      inherit filename;
      browsers = {
        x86_64-linux = browsers-linux { };
        aarch64-linux = browsers-linux { };
        x86_64-darwin = browsers-mac;
        aarch64-darwin = browsers-mac;
      }.${system} or throwSystem;
      browsers-chromium = browsers-linux { withFirefox = false; };
      browsers-firefox = browsers-linux { withChromium = false; };
    };
  });

  browsers-mac = stdenv.mkDerivation {
    pname = "playwright-browsers";
    version = driver.version;

    src = runCommand "playwright-browsers-base" {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = {
        x86_64-darwin = "0z2kww4iby1izkwn6z2ai94y87bkjvwak8awdmjm8sgg00pa9l1a";
      }.${system} or throwSystem;
    } ''
      export PLAYWRIGHT_BROWSERS_PATH=$out
      ${driver}/bin/playwright install
      rm -r $out/.links
    '';

    installPhase = ''
      mkdir $out
      cp -r * $out/
    '';
  };

  browsers-linux = { withFirefox ? true, withChromium ? true }: let
    fontconfig = makeFontsConf {
      fontDirectories = [];
    };
  in runCommand ("playwright-browsers"
    + lib.optionalString (withFirefox && !withChromium) "-firefox"
    + lib.optionalString (!withFirefox && withChromium) "-chromium")
  {
    nativeBuildInputs = [
      makeWrapper
      jq
    ];
  } (''
    BROWSERS_JSON=${driver}/package/browsers.json
  '' + lib.optionalString withChromium ''
    CHROMIUM_REVISION=$(jq -r '.browsers[] | select(.name == "chromium").revision' $BROWSERS_JSON)
    mkdir -p $out/chromium-$CHROMIUM_REVISION/chrome-linux

    # See here for the Chrome options:
    # https://github.com/NixOS/nixpkgs/issues/136207#issuecomment-908637738
    makeWrapper ${chromium}/bin/chromium $out/chromium-$CHROMIUM_REVISION/chrome-linux/chrome \
      --set SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt \
      --set FONTCONFIG_FILE ${fontconfig}
  '' + lib.optionalString withFirefox ''
    FIREFOX_REVISION=$(jq -r '.browsers[] | select(.name == "firefox").revision' $BROWSERS_JSON)
    mkdir -p $out/firefox-$FIREFOX_REVISION/firefox
    ln -s ${firefox}/bin/firefox $out/firefox-$FIREFOX_REVISION/firefox/firefox
  '' + ''
    FFMPEG_REVISION=$(jq -r '.browsers[] | select(.name == "ffmpeg").revision' $BROWSERS_JSON)
    mkdir -p $out/ffmpeg-$FFMPEG_REVISION
    ln -s ${ffmpeg}/bin/ffmpeg $out/ffmpeg-$FFMPEG_REVISION/ffmpeg-linux
  '');
in
  driver
