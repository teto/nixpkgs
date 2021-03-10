#!/bin/sh
# temporary wrapper to avoid too many rebuilds
echo "starting wrapper"
# 1/ first generate a log file
# bazel build //simwork/pipeline-tools:porcupine-postgresql --execution_log_binary_file=/tmp/exec1.log

# 2/ in scratch folder
# ./output/bazel build  src/tools/execlog:parser_deploy.jar

#   look into javaToolchain = "@bazel_tools//tools/jdk:toolchain_${buildJdkName}";
# set to java11 in nixpkgs
# path towards java = openjdk11;
# lancer ce script dans un
# NIX_PATH=nixpkgs=. nix-shell -p openjdk11

# TODO I need to copy/paste the JAVA_RUNFILES
export JAVABIN='/nix/store/w65z8vbkzlcqzaqp9nlfmdlqink185nw-openjdk-11.0.10+9/bin/java'
export JAVA_RUNFILES=/home/teto/scratch2/bazel_src/bazel-bin/src/tools/execlog;
result/bin/execlog --singlejar --log_path=/tmp/exec1.log
