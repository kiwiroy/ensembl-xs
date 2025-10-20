carton := 'carton exec --'

[doc('Show the available recipes')]
default:
    @just --list

[doc('Build itree and XS module')]
build: dependencies
    {{carton}} perl Makefile.PL
    {{carton}} make

[doc('Install dependencies')]
dependencies:
    rm -f cpanfile.snapshot && cpm install && cpm install Bio::EnsEMBL && carton install

[doc('Create a distribution tar file')]
dist: build
    {{carton}} make manifest disttest dist

[doc('Test the build')]
test: build
    {{carton}} make test

[private]
author-dependencies:
    [ -d .ensembl-test ] || git clone --branch=main --depth=1 git@github.com:Ensembl/ensembl-test.git .ensembl-test

[doc('Run author tests')]
author-test: build author-dependencies
    env TEST_AUTHOR=1 PERL5OPT=-I.ensembl-test/modules {{carton}} make test TEST_FILES="t/*.t xt/*.t"

[doc('Clean up')]
clean:
    [ ! -f Makefile ] || make clean
    rm -rf .ensembl-test
    git clean -fx

[doc('Devel::PPPort workflow')]
ppport:
    rm -f cpanfile.snapshot && cpm install && carton install
    {{carton}} perl -MDevel::PPPort -e'Devel::PPPort::WriteFile'
    {{carton}} perl ppport.h --compat-version=5.16.1 --patch=diff.patch *.xs
    [ ! -f diff.patch ] || patch -p0 < diff.patch && rm -f diff.patch