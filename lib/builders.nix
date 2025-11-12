/**

*/
{ lib }:
# with lib;
# let
# in
{
  mkRemoteBuilderDesc = nixVersion: machine:
    lib.concatStringsSep " " (
      [
        "${lib.optionalString (machine.protocol != null) "${machine.protocol}://"}${
          lib.optionalString (machine.sshUser != null) "${machine.sshUser}@"
        }${machine.hostName}"
        (
          if machine.system != null then
            machine.system
          else if machine.systems != [ ] then
            lib.concatStringsSep "," machine.systems
          else
            "-"
        )
        (if machine.sshKey != null then machine.sshKey else "-")
        (toString machine.maxJobs)
        (toString machine.speedFactor)
        (
          let
            res = (machine.supportedFeatures ++ machine.mandatoryFeatures);
          in
          if (res == [ ]) then "-" else (lib.concatStringsSep "," res)
        )
        (
          let
            res = machine.mandatoryFeatures;
          in
          if (res == [ ]) then "-" else (lib.concatStringsSep "," machine.mandatoryFeatures)
        )
      ]
      ++ lib.optional (lib.versionAtLeast nixVersion "2.4pre") (
        if machine.publicHostKey != null then machine.publicHostKey else "-"
      )
    );
  }
