require 'opener/build-tools'

include Opener::BuildTools::Requirements
include Opener::BuildTools::Python
include Opener::BuildTools::Files

# Directory of the core
CORE_DIR = File.expand_path('../../../core', __FILE__)

# Directory where packages will be installed to.
PYTHON_SITE_PACKAGES = File.expand_path(
  '../../../core/site-packages',
  __FILE__
)

# Directory containing the temporary files.
TMP_DIRECTORY = File.expand_path('../../../tmp', __FILE__)

# Path to the pip requirements file used to install requirements before
# packaging the Gem.
PRE_BUILD_REQUIREMENTS = File.expand_path(
  '../../../pre_build_requirements.txt',
  __FILE__
)

# Path to the pip requirements file used to install requirements upon Gem
# installation.
PRE_INSTALL_REQUIREMENTS = File.expand_path(
  '../../../pre_install_requirements.txt',
  __FILE__
)

# Path to the vendor directory for C code.
VENDOR_DIRECTORY = File.expand_path('../../../core/vendor', __FILE__)

# Path to the directory to install vendored C code into.
VENDOR_BUILD_DIRECTORY = File.expand_path(
  '../../../core/vendor/build',
  __FILE__
)

# Path to the directory that contains the source C code to compile.
VENDOR_SRC_DIRECTORY = File.expand_path('../../../core/vendor/src', __FILE__)


##
# Verifies the requirements to install thi Gem.
#
def verify_requirements
  require_executable('python')
  require_version('python', python_version, '2.6.0')
  require_executable('pip')
  require_version('pip', pip_version, '1.3.1')
end

##
# Compiles C code in the current directory using `make`.
#
# @param [Array] args The arguments to pass to ./configure
#
def compile(*args)
  sh "./configure #{args.join(' ')}"
  sh 'make'
  sh 'make install'
  sh 'make distclean'
end

##
# Compiles the C code found in src/vendor.
#
def compile_vendored_code
  src   = VENDOR_SRC_DIRECTORY
  build = VENDOR_BUILD_DIRECTORY

  Dir.chdir(File.join(src, "liblbfgs")) do
    compile("--prefix=#{build}")
  end

  Dir.chdir(File.join(src, "crfsuite")) do
    compile("--prefix=#{build}", "--with-liblbfgs=#{build}")
  end

  Dir.chdir(File.join(src, "svm_light")) do
    sh 'make'
    sh 'mv svm_classify svm_learn ../../build/bin'
    sh 'make clean'
  end
end
