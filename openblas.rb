require 'formula'

# Avoid openblas downloading the LAPACK on demand.
# We want openblas to build LAPACK because it knows how to patch LAPACK,
# but *we* want to download, cache and checksum that!
class OpenblasLapack < Formula
  url 'http://www.netlib.org/lapack/lapack-3.4.2.tgz'
  sha1 '93a6e4e6639aaf00571d53a580ddc415416e868b'
end

class Openblas < Formula
  homepage 'http://xianyi.github.io/OpenBLAS/'
  # Maintainers, remember to update the LAPACK url in OpenblasLapack above.
  # See the "LAPACK_URL" in the openblas Makefile for the right version.
  url 'https://github.com/xianyi/OpenBLAS/archive/v0.2.7.tar.gz'
  sha1 '9597ffed953c3d7be022e3080532b7d8fecd499e'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  env :std

  depends_on 'gfortran'
  depends_on :fortran

  # OS X provides the Accelerate.framework, which is a BLAS/LAPACK impl.
  keg_only :provided_by_osx

  def install
    lapack = OpenblasLapack.new
    lapack.brew{}  # download and checksum
    ohai "Using LAPACK: #{lapack.cached_download}"

    inreplace 'Makefile',
              'LAPACK_URL=http://www.netlib.org/lapack/lapack-3.4.2.tgz',
              "LAPACK_URL=file://#{lapack.cached_download}"

    # Must call in two steps
    system "make"
    system "make", "PREFIX=#{prefix}", "install"
  end
end
