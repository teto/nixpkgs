# Setup hook to use for eggs
echo "Sourcing find-rockspec hook"

findRockspec() {
    echo "Executing eggBuildPhase"

    # TODO rename to rockspecPath ?
    # rockspecFilename
    # TODO goald is to set rockspecFilename
    if [ -z "$rockspecFilename" ]; then
        # format is rockspec_basename/source_basename
        # rockspec can set it via spec.source.dir
        folder=$(find . -mindepth 2 -maxdepth 2 -type d -path '*${name_only}*/*'|head -n1)
        sourceRoot="$folder"
    fi

}

